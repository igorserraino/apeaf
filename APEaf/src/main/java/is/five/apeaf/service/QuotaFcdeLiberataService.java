package is.five.apeaf.service;

import is.five.apeaf.dao.InsDatiFCDEDAO;
import is.five.apeaf.dao.InsResiduiAttiviDAO;
import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.model.InsDatiFCDE;
import is.five.apeaf.dao.model.InsResiduiAttivi;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.service.ImportiDefinibiliService.GroupData;
import is.five.apeaf.utils.CSVUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * Prepares all data displayed by quota-fcde-liberata.jsp.
 *
 * <p>The service has no JSP or Servlet dependencies and can therefore be
 * reused by any other page or controller.</p>
 */
public class QuotaFcdeLiberataService {

    private static final int NUMBER_OF_ENTRIES = 5;
    private static final int NUMBER_OF_HYPOTHESES = 3;

    private static final String[] ENTRY_LABELS = {
        "ACCERTAMENTI ICI",
        "ACCERTAMENTI TASI",
        "ACCERTAMENTI IMU",
        "Tassa Rifiuti",
        "CDS"
    };

    private final ImportiDefinibiliService importiService;

    public QuotaFcdeLiberataService() {
        this(new ImportiDefinibiliService());
    }

    public QuotaFcdeLiberataService(
            ImportiDefinibiliService importiService) {
        this.importiService = importiService;
    }

    public ViewData load(UserView user, String selectedYearId) {
        ImportiDefinibiliService.PageData importiData =
                importiService.load(user, selectedYearId);

        if (!importiData.hasSelectedYear()) {
            return ViewData.withoutSelectedYear();
        }

        String selectedYear = importiData.getSelectedYear();
        int year = Integer.parseInt(selectedYear);

        InsDatiFCDE fcdeData = InsDatiFCDEDAO.findByUserAndAnno(
                user.getId(), year);
        InsResiduiAttivi residualData = InsResiduiAttiviDAO.findByUserAndAnno(
                user.getId(), year);

        String fcdeCsv = fcdeData == null || fcdeData.getValue() == null
                ? ""
                : fcdeData.getValue();
        String residualCsv = residualData == null || residualData.getValue() == null
                ? ""
                : residualData.getValue();

        List<TabPar> sanctionParameters = loadParameters(
                user.getId(), TabPar.TYPE_SANZIONE);
        List<TabPar> interestParameters = loadParameters(
                user.getId(), TabPar.TYPE_INTERESSI);

        DecimalFormat italianThreeDecimals = new DecimalFormat(
                "#,##0.000",
                DecimalFormatSymbols.getInstance(Locale.ITALY));
        italianThreeDecimals.setRoundingMode(RoundingMode.HALF_UP);

        double[][] sanctionCuts =
                new double[NUMBER_OF_ENTRIES][NUMBER_OF_HYPOTHESES];
        double[][] interestCuts =
                new double[NUMBER_OF_ENTRIES][NUMBER_OF_HYPOTHESES];

        int groupIndex = 0;
        for (GroupData group : importiData.getGroups()) {
            if (groupIndex >= NUMBER_OF_ENTRIES) {
                break;
            }

            for (int hypothesis = 0;
                    hypothesis < NUMBER_OF_HYPOTHESES;
                    hypothesis++) {
                sanctionCuts[groupIndex][hypothesis] =
                        group.getTotalResidualSanctionsBD().doubleValue()
                        * parameterValue(
                            sanctionParameters,
                            hypothesis
                        ).doubleValue()
                        / 100;

                interestCuts[groupIndex][hypothesis] =
                        group.getTotalResidualInterestBD().doubleValue()
                        * parameterValue(
                            interestParameters,
                            hypothesis
                        ).doubleValue()
                        / 100;
            }

            groupIndex++;
        }

        List<RowData> calculatedRows =
                new ArrayList<RowData>();

        double totalFcde = 0;
        double totalResidual = 0;

        double[] totalSanctionAndInterest =
                new double[NUMBER_OF_HYPOTHESES];

        double[] totalReleasedFcde =
                new double[NUMBER_OF_HYPOTHESES];

        for (int entryIndex = 0;
                entryIndex < NUMBER_OF_ENTRIES;
                entryIndex++) {
            double fcde = CSVUtils.getDecimalValue(
                    fcdeCsv, entryIndex).doubleValue();
            double residual = CSVUtils.getDecimalValue(
                    residualCsv, entryIndex).doubleValue();

            // This intentionally preserves the original calculation.
            double fcdePercentage = 100 * fcde / residual;

            totalFcde += fcde;
            totalResidual += residual;

            List<String> sanctionAndInterestValues =
                    new ArrayList<String>();

            List<String> releasedFcdeValues =
                    new ArrayList<String>();

            for (int hypothesis = 0;
                    hypothesis < NUMBER_OF_HYPOTHESES;
                    hypothesis++) {
                double calculatedValue =
                        fcdePercentage
                        * (residual
                            - sanctionCuts[entryIndex][hypothesis]
                            - interestCuts[entryIndex][hypothesis])
                        / 100;

                sanctionAndInterestValues.add(
                        italianThreeDecimals.format(calculatedValue));

                totalSanctionAndInterest[hypothesis] +=
                        calculatedValue;

                /*
                 * Quota FCDE liberata:
                 *
                 * quota FCDE accantonata a consuntivo
                 * - valore calcolato per sanzioni e interessi.
                 */
                double releasedFcde =
                        fcde - calculatedValue;

                releasedFcdeValues.add(
                        italianThreeDecimals.format(releasedFcde));

                totalReleasedFcde[hypothesis] +=
                        releasedFcde;
            }

            calculatedRows.add(new RowData(
                    ENTRY_LABELS[entryIndex],
                    italianThreeDecimals.format(fcde),
                    italianThreeDecimals.format(fcdePercentage),
                    sanctionAndInterestValues,
                    releasedFcdeValues));
        }

        double totalFcdePercentage =
                totalResidual != 0
                        ? 100 * totalFcde / totalResidual
                        : 0;

        TotalsData totals = new TotalsData(
                italianThreeDecimals.format(totalFcde),
                italianThreeDecimals.format(totalFcdePercentage),
                formatValues(
                        totalSanctionAndInterest,
                        italianThreeDecimals),
                formatValues(
                        totalReleasedFcde,
                        italianThreeDecimals));

        return new ViewData(
                selectedYear,
                formatParameterValues(
                        sanctionParameters,
                        italianThreeDecimals),
                formatParameterValues(
                        interestParameters,
                        italianThreeDecimals),
                calculatedRows,
                totals);
    }

    private List<TabPar> loadParameters(int userId, int type) {
        List<TabPar> loaded = TabParDAO.findByUserAndType(userId, type);
        List<TabPar> parameters = loaded == null
                ? new ArrayList<TabPar>()
                : new ArrayList<TabPar>(loaded);

        Collections.sort(parameters, new Comparator<TabPar>() {
            @Override
            public int compare(TabPar left, TabPar right) {
                BigDecimal leftValue = left == null ? null : left.getValue();
                BigDecimal rightValue = right == null ? null : right.getValue();

                if (leftValue == rightValue) {
                    return 0;
                }
                if (leftValue == null) {
                    return 1;
                }
                if (rightValue == null) {
                    return -1;
                }
                return leftValue.compareTo(rightValue);
            }
        });

        while (parameters.size() < NUMBER_OF_HYPOTHESES) {
            TabPar parameter = new TabPar();
            parameter.setValue(BigDecimal.ZERO);
            parameter.setType(type);
            parameters.add(parameter);
        }

        return parameters;
    }

    private BigDecimal parameterValue(
            List<TabPar> parameters,
            int index) {
        if (parameters == null ||
                index < 0 ||
                index >= parameters.size() ||
                parameters.get(index) == null ||
                parameters.get(index).getValue() == null) {
            return BigDecimal.ZERO;
        }

        return parameters.get(index).getValue();
    }

    private List<String> formatParameterValues(
            List<TabPar> parameters,
            DecimalFormat formatter) {
        List<String> values = new ArrayList<String>();

        for (int index = 0; index < NUMBER_OF_HYPOTHESES; index++) {
            values.add(formatter.format(
                    parameterValue(parameters, index)));
        }

        return values;
    }

    private List<String> formatValues(
            double[] source,
            DecimalFormat formatter) {
        List<String> values = new ArrayList<String>();

        for (double value : source) {
            values.add(formatter.format(value));
        }

        return values;
    }

    public static final class ViewData {
        private final String selectedYear;
        private final List<String> sanctionPercentages;
        private final List<String> interestPercentages;
        private final List<RowData> rows;
        private final TotalsData totals;

        private ViewData(
                String selectedYear,
                List<String> sanctionPercentages,
                List<String> interestPercentages,
                List<RowData> rows,
                TotalsData totals) {
            this.selectedYear = selectedYear;
            this.sanctionPercentages = Collections.unmodifiableList(
                    new ArrayList<String>(sanctionPercentages));
            this.interestPercentages = Collections.unmodifiableList(
                    new ArrayList<String>(interestPercentages));
            this.rows = Collections.unmodifiableList(
                    new ArrayList<RowData>(rows));
            this.totals = totals;
        }

        private static ViewData withoutSelectedYear() {
            return new ViewData(
                    "",
                    Collections.<String>emptyList(),
                    Collections.<String>emptyList(),
                    Collections.<RowData>emptyList(),
                    TotalsData.empty());
        }

        public boolean hasSelectedYear() {
            return selectedYear != null && !selectedYear.trim().isEmpty();
        }

        public String getSelectedYear() { return selectedYear; }
        public List<String> getSanctionPercentages() { return sanctionPercentages; }
        public List<String> getInterestPercentages() { return interestPercentages; }
        public List<RowData> getRows() { return rows; }
        public TotalsData getTotals() { return totals; }
    }

    public static final class RowData {
        private final String entry;
        private final String fcde;
        private final String fcdePercentage;
        private final List<String> sanctionAndInterestValues;
        private final List<String> releasedFcdeValues;

        private RowData(
                String entry,
                String fcde,
                String fcdePercentage,
                List<String> sanctionAndInterestValues,
                List<String> releasedFcdeValues) {
            this.entry = entry;
            this.fcde = fcde;
            this.fcdePercentage = fcdePercentage;
            this.sanctionAndInterestValues = Collections.unmodifiableList(
                    new ArrayList<String>(sanctionAndInterestValues));
            this.releasedFcdeValues = Collections.unmodifiableList(
                    new ArrayList<String>(releasedFcdeValues));
        }

        public String getEntry() { return entry; }
        public String getFcde() { return fcde; }
        public String getFcdePercentage() { return fcdePercentage; }
        public List<String> getSanctionAndInterestValues() {
            return sanctionAndInterestValues;
        }
        public List<String> getReleasedFcdeValues() {
            return releasedFcdeValues;
        }
    }

    public static final class TotalsData {
        private final String fcde;
        private final String fcdePercentage;
        private final List<String> sanctionAndInterestValues;
        private final List<String> releasedFcdeValues;

        private TotalsData(
                String fcde,
                String fcdePercentage,
                List<String> sanctionAndInterestValues,
                List<String> releasedFcdeValues) {
            this.fcde = fcde;
            this.fcdePercentage = fcdePercentage;
            this.sanctionAndInterestValues =
                    Collections.unmodifiableList(
                        new ArrayList<String>(
                            sanctionAndInterestValues));
            this.releasedFcdeValues =
                    Collections.unmodifiableList(
                        new ArrayList<String>(
                            releasedFcdeValues));
        }

        private static TotalsData empty() {
            return new TotalsData(
                    "0,000",
                    "0,000",
                    Collections.<String>emptyList(),
                    Collections.<String>emptyList());
        }

        public String getFcde() { return fcde; }
        public String getFcdePercentage() { return fcdePercentage; }
        public List<String> getSanctionAndInterestValues() {
            return sanctionAndInterestValues;
        }
        public List<String> getReleasedFcdeValues() {
            return releasedFcdeValues;
        }
    }
}
