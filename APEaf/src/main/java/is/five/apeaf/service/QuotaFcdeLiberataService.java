package is.five.apeaf.service;

import is.five.apeaf.dao.InsDatiFCDEDAO;
import is.five.apeaf.dao.InsResiduiAttiviDAO;
import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.TipologieDAO;

import is.five.apeaf.dao.model.InsDatiFCDE;
import is.five.apeaf.dao.model.InsResiduiAttivi;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.Tipologia;
import is.five.apeaf.dao.model.UserView;

import is.five.apeaf.service.ImportiDefinibiliService.GroupData;

import is.five.apeaf.utils.Utils;

import java.math.BigDecimal;
import java.math.RoundingMode;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;


public class QuotaFcdeLiberataService {


    private static final int NUMBER_OF_HYPOTHESES = 3;


    private final ImportiDefinibiliService importiService;


    public QuotaFcdeLiberataService() {

        this(
            new ImportiDefinibiliService()
        );
    }


    public QuotaFcdeLiberataService(
            ImportiDefinibiliService importiService) {

        this.importiService =
            importiService;
    }


    /* =========================================================
       LOAD
       ========================================================= */

    public ViewData load(
            UserView user,
            String selectedYearId) {


        /* =====================================================
           IMPORTI DEFINIBILI
           ===================================================== */

        ImportiDefinibiliService.PageData importiData =
            importiService.load(
                user,
                selectedYearId
            );


        if (!importiData.hasSelectedYear()) {

            return ViewData.withoutSelectedYear();
        }


        String selectedYear =
            importiData.getSelectedYear();


        int year =
            Integer.parseInt(
                selectedYear
            );


        /* =====================================================
           TIPOLOGIE VALIDE
           ===================================================== */

        List<Tipologia> tipologie =
            TipologieDAO.findByUserAndAnno(
                user.getId(),
                year
            );


        List<String> entryLabels =
            new ArrayList<String>();


        Set<String> tipologieValide =
            new TreeSet<String>(
                String.CASE_INSENSITIVE_ORDER
            );


        if (tipologie != null) {

            for (Tipologia tipologia : tipologie) {


                if (tipologia == null ||
                    tipologia.getValue() == null) {

                    continue;
                }


                String nome =
                    tipologia
                        .getValue()
                        .trim();


                if (nome.isEmpty()) {

                    continue;
                }


                if (tipologieValide.add(nome)) {

                    entryLabels.add(nome);
                }
            }
        }


        Collections.sort(
            entryLabels,
            String.CASE_INSENSITIVE_ORDER
        );


        /* =====================================================
           RESIDUI ATTIVI
           ===================================================== */

        InsResiduiAttivi residualData =
            InsResiduiAttiviDAO.findByUserAndAnno(
                user.getId(),
                year
            );


        String residualCsv =
            residualData == null ||
            residualData.getValue() == null

                ? ""

                : residualData
                    .getValue()
                    .trim();


        Map<String, BigDecimal> residuiPerTipologia =
            parseResidualValues(
                residualCsv,
                tipologieValide
            );


        /* =====================================================
           DATI FCDE
           ===================================================== */

        InsDatiFCDE fcdeData =
            InsDatiFCDEDAO.findByUserAndAnno(
                user.getId(),
                year
            );


        String fcdeCsv =
            fcdeData == null ||
            fcdeData.getValue() == null

                ? ""

                : fcdeData
                    .getValue()
                    .trim();


        Map<String, BigDecimal> fcdePerTipologia =
            parseFcdeValues(
                fcdeCsv,
                tipologieValide
            );


        /* =====================================================
           PARAMETRI

           IMPORTANTISSIMO:
           sono due serie diverse.
           ===================================================== */

        List<TabPar> sanctionParameters =
            loadParameters(
                user.getId(),
                TabPar.TYPE_SANZIONE
            );


        List<TabPar> interestParameters =
            loadParameters(
                user.getId(),
                TabPar.TYPE_INTERESSI
            );


        /* =====================================================
           GROUP DATA
           ===================================================== */

        Map<String, GroupData> groupsByEntry =
            new TreeMap<String, GroupData>(
                String.CASE_INSENSITIVE_ORDER
            );


        if (importiData.getGroups() != null) {

            for (GroupData group :
                    importiData.getGroups()) {


                if (group == null ||
                    group.getEntry() == null) {

                    continue;
                }


                String nome =
                    group
                        .getEntry()
                        .trim();


                if (nome.isEmpty()) {

                    continue;
                }


                if (!tipologieValide.contains(nome)) {

                    continue;
                }


                groupsByEntry.put(
                    nome,
                    group
                );
            }
        }


        /* =====================================================
           FORMAT
           ===================================================== */

        DecimalFormatSymbols symbols =
            DecimalFormatSymbols.getInstance(
                Locale.ITALY
            );


        DecimalFormat moneyFormat =
            new DecimalFormat(
                "#,##0.000",
                symbols
            );


        moneyFormat.setRoundingMode(
            RoundingMode.HALF_UP
        );


        DecimalFormat percentageFormat =
            new DecimalFormat(
                "#,##0.000",
                symbols
            );


        percentageFormat.setRoundingMode(
            RoundingMode.HALF_UP
        );


        /* =====================================================
           OUTPUT
           ===================================================== */

        List<RowData> rows =
            new ArrayList<RowData>();


        BigDecimal totalFcde =
            BigDecimal.ZERO;


        BigDecimal totalResidual =
            BigDecimal.ZERO;


        BigDecimal[] totalCalculatedFcde =
            zeroArray();


        BigDecimal[] totalReleasedFcde =
            zeroArray();


        /* =====================================================
           CALCOLO PER TIPOLOGIA
           ===================================================== */

        for (String entryLabel :
                entryLabels) {


            BigDecimal residual =
                residuiPerTipologia.get(
                    entryLabel
                );


            if (residual == null) {

                residual =
                    BigDecimal.ZERO;
            }


            BigDecimal fcde =
                fcdePerTipologia.get(
                    entryLabel
                );


            if (fcde == null) {

                fcde =
                    BigDecimal.ZERO;
            }


            /* -------------------------------------------------
               % FCDE

               Excel:
               FCDE / RESIDUO * 100
               ------------------------------------------------- */

            BigDecimal fcdePercentage =
                BigDecimal.ZERO;


            if (residual.compareTo(
                    BigDecimal.ZERO) != 0) {


                fcdePercentage =
                    fcde
                        .multiply(
                            BigDecimal.valueOf(100)
                        )
                        .divide(
                            residual,
                            15,
                            RoundingMode.HALF_UP
                        );
            }


            /* -------------------------------------------------
               SANZIONI / INTERESSI RESIDUI
               ------------------------------------------------- */

            GroupData group =
                groupsByEntry.get(
                    entryLabel
                );


            BigDecimal residualSanctions =
                BigDecimal.ZERO;


            BigDecimal residualInterest =
                BigDecimal.ZERO;


            if (group != null) {


                if (group.getTotalResidualSanctionsBD() != null) {

                    residualSanctions =
                        group.getTotalResidualSanctionsBD();
                }


                if (group.getTotalResidualInterestBD() != null) {

                    residualInterest =
                        group.getTotalResidualInterestBD();
                }
            }


            totalFcde =
                totalFcde.add(
                    fcde
                );


            totalResidual =
                totalResidual.add(
                    residual
                );


            List<String> calculatedValues =
                new ArrayList<String>();


            List<String> releasedValues =
                new ArrayList<String>();


            /* =================================================
               LE TRE IPOTESI

               QUESTA È LA STESSA LOGICA DI IPOTESI-TAGLI.JSP
               ================================================= */

            for (int hypothesis = 0;
                 hypothesis < NUMBER_OF_HYPOTHESES;
                 hypothesis++) {


                /* =============================================
                   PARAMETRO SANZIONE
                   ============================================= */

                BigDecimal sanctionPercentage =
                    parameterValue(
                        sanctionParameters,
                        hypothesis
                    );


                /* =============================================
                   PARAMETRO INTERESSI
                   ============================================= */

                BigDecimal interestPercentage =
                    parameterValue(
                        interestParameters,
                        hypothesis
                    );


                /* =============================================
                   TAGLIO SANZIONI

                   stessa formula di ipotesi-tagli.jsp
                   ============================================= */

                BigDecimal sanctionCut =
                    residualSanctions
                        .multiply(
                            sanctionPercentage
                        )
                        .divide(
                            BigDecimal.valueOf(100),
                            15,
                            RoundingMode.HALF_UP
                        );


                /* =============================================
                   TAGLIO INTERESSI

                   stessa formula di ipotesi-tagli.jsp
                   ============================================= */

                BigDecimal interestCut =
                    residualInterest
                        .multiply(
                            interestPercentage
                        )
                        .divide(
                            BigDecimal.valueOf(100),
                            15,
                            RoundingMode.HALF_UP
                        );


                
                
                
                
                /* =============================================
                   FORMULA EXCEL

                   =
                   (residuo
                    - taglio sanzioni
                    - taglio interessi)
                   / 100
                   * %FCDE
                   ============================================= */

                BigDecimal newResidual =
                    residual
                        .subtract(
                            sanctionCut
                        )
                        .subtract(
                            interestCut
                        );


                BigDecimal calculatedFcde =
                    newResidual
                        .multiply(
                            fcdePercentage
                        )
                        .divide(
                            BigDecimal.valueOf(100),
                            15,
                            RoundingMode.HALF_UP
                        );


                /* =============================================
                   QUOTA FCDE LIBERATA
                   ============================================= */

                BigDecimal releasedFcde =
                    fcde.subtract(
                        calculatedFcde
                    );


                calculatedValues.add(
                    moneyFormat.format(
                        calculatedFcde
                    )
                );


                releasedValues.add(
                    moneyFormat.format(
                        releasedFcde
                    )
                );


                totalCalculatedFcde[hypothesis] =
                    totalCalculatedFcde[hypothesis]
                        .add(
                            calculatedFcde
                        );


                totalReleasedFcde[hypothesis] =
                    totalReleasedFcde[hypothesis]
                        .add(
                            releasedFcde
                        );
            }


            rows.add(
                new RowData(

                    entryLabel,

                    moneyFormat.format(
                        fcde
                    ),

                    percentageFormat.format(
                        fcdePercentage
                    ),

                    calculatedValues,

                    releasedValues
                )
            );
        }


        /* =====================================================
           TOTAL % FCDE
           ===================================================== */

        BigDecimal totalFcdePercentage =
            BigDecimal.ZERO;


        if (totalResidual.compareTo(
                BigDecimal.ZERO) != 0) {


            totalFcdePercentage =
                totalFcde
                    .multiply(
                        BigDecimal.valueOf(100)
                    )
                    .divide(
                        totalResidual,
                        15,
                        RoundingMode.HALF_UP
                    );
        }


        /* =====================================================
           TOTALI
           ===================================================== */

        TotalsData totals =
            new TotalsData(

                moneyFormat.format(
                    totalFcde
                ),

                percentageFormat.format(
                    totalFcdePercentage
                ),

                formatValues(
                    totalCalculatedFcde,
                    moneyFormat
                ),

                formatValues(
                    totalReleasedFcde,
                    moneyFormat
                )
            );


        return new ViewData(

            selectedYear,

            formatParameterValues(
                sanctionParameters,
                percentageFormat
            ),

            formatParameterValues(
                interestParameters,
                percentageFormat
            ),

            rows,

            totals
        );
    }


    /* =========================================================
       PARAMETRI
       ========================================================= */

    private List<TabPar> loadParameters(
            int userId,
            int type) {


        List<TabPar> loaded =
            TabParDAO.findByUserAndType(
                userId,
                type
            );


        List<TabPar> parameters =
            loaded == null

                ? new ArrayList<TabPar>()

                : new ArrayList<TabPar>(
                    loaded
                  );


        Collections.sort(
            parameters,
            new Comparator<TabPar>() {

                @Override
                public int compare(
                        TabPar left,
                        TabPar right) {


                    BigDecimal leftValue =
                        left != null
                            ? left.getValue()
                            : null;


                    BigDecimal rightValue =
                        right != null
                            ? right.getValue()
                            : null;


                    if (leftValue == rightValue) {

                        return 0;
                    }


                    if (leftValue == null) {

                        return 1;
                    }


                    if (rightValue == null) {

                        return -1;
                    }


                    return leftValue.compareTo(
                        rightValue
                    );
                }
            }
        );


        while (parameters.size() >
               NUMBER_OF_HYPOTHESES) {


            parameters.remove(
                parameters.size() - 1
            );
        }


        while (parameters.size() <
               NUMBER_OF_HYPOTHESES) {


            TabPar parameter =
                new TabPar();


            parameter.setValue(
                BigDecimal.ZERO
            );


            parameter.setType(
                type
            );


            parameters.add(
                parameter
            );
        }


        return parameters;
    }


    private BigDecimal parameterValue(
            List<TabPar> parameters,
            int index) {


        if (parameters == null ||
            index < 0 ||
            index >= parameters.size()) {

            return BigDecimal.ZERO;
        }


        TabPar parameter =
            parameters.get(index);


        if (parameter == null ||
            parameter.getValue() == null) {

            return BigDecimal.ZERO;
        }


        return parameter.getValue();
    }


    private List<String> formatParameterValues(
            List<TabPar> parameters,
            DecimalFormat formatter) {


        List<String> result =
            new ArrayList<String>();


        for (int i = 0;
             i < NUMBER_OF_HYPOTHESES;
             i++) {


            result.add(
                formatter.format(
                    parameterValue(
                        parameters,
                        i
                    )
                )
            );
        }


        return result;
    }


    /* =========================================================
       PARSING RESIDUI / FCDE
       ========================================================= */

    private Map<String, BigDecimal> parseResidualValues(
            String csv,
            Set<String> validTypes) {


        return parseNamedOrLegacyValues(
            csv,
            validTypes,
            InsResiduiAttivi.TIPOLOGIE
        );
    }


    private Map<String, BigDecimal> parseFcdeValues(
            String csv,
            Set<String> validTypes) {


        return parseNamedOrLegacyValues(
            csv,
            validTypes,
            InsDatiFCDE.TIPOLOGIE
        );
    }


    private Map<String, BigDecimal> parseNamedOrLegacyValues(
            String csv,
            Set<String> validTypes,
            String[] legacyTypes) {


        Map<String, BigDecimal> result =
            new TreeMap<String, BigDecimal>(
                String.CASE_INSENSITIVE_ORDER
            );


        if (csv == null ||
            csv.trim().isEmpty()) {

            return result;
        }


        String[] tokens =
            csv.split(
                ";",
                -1
            );


        boolean namedFormat =
            false;


        for (String token :
                tokens) {


            if (token != null &&
                token.contains("=")) {


                namedFormat =
                    true;

                break;
            }
        }


        /* =====================================================
           NUOVO FORMATO
           ===================================================== */

        if (namedFormat) {


            for (String token :
                    tokens) {


                if (token == null) {

                    continue;
                }


                token =
                    token.trim();


                if (token.isEmpty() ||
                    !token.contains("=")) {

                    continue;
                }


                String[] parts =
                    token.split(
                        "=",
                        2
                    );


                String name =
                    parts[0] != null
                        ? parts[0].trim()
                        : "";


                if (name.isEmpty() ||
                    !validTypes.contains(name)) {

                    continue;
                }


                String value =
                    parts.length > 1 &&
                    parts[1] != null

                        ? parts[1].trim()

                        : "0";


                result.put(
                    name,
                    parseNumber(
                        value
                    )
                );
            }


            return result;
        }


        /* =====================================================
           LEGACY PURO
           ===================================================== */

        if (legacyTypes == null) {

            return result;
        }


        int position =
            0;


        for (String token :
                tokens) {


            if (position >=
                legacyTypes.length) {

                break;
            }


            String name =
                legacyTypes[position];


            position++;


            if (name == null ||
                name.trim().isEmpty()) {

                continue;
            }


            name =
                name.trim();


            if (!validTypes.contains(name)) {

                continue;
            }


            result.put(
                name,
                parseNumber(
                    token
                )
            );
        }


        return result;
    }


    private BigDecimal parseNumber(
            String value) {


        if (value == null ||
            value.trim().isEmpty()) {

            return BigDecimal.ZERO;
        }


        try {

            BigDecimal parsed =
                Utils.parseItalianNumber(
                    value.trim()
                );


            return parsed != null
                ? parsed
                : BigDecimal.ZERO;


        } catch (Exception exc) {

            return BigDecimal.ZERO;
        }
    }


    /* =========================================================
       HELPERS
       ========================================================= */

    private BigDecimal[] zeroArray() {


        BigDecimal[] result =
            new BigDecimal[
                NUMBER_OF_HYPOTHESES
            ];


        for (int i = 0;
             i < result.length;
             i++) {


            result[i] =
                BigDecimal.ZERO;
        }


        return result;
    }


    private List<String> formatValues(
            BigDecimal[] values,
            DecimalFormat formatter) {


        List<String> result =
            new ArrayList<String>();


        if (values == null) {

            return result;
        }


        for (BigDecimal value :
                values) {


            result.add(
                formatter.format(
                    value != null
                        ? value
                        : BigDecimal.ZERO
                )
            );
        }


        return result;
    }


    /* =========================================================
       VIEW DATA
       ========================================================= */

    public static final class ViewData {


        private final String selectedYear;

        private final List<String>
            sanctionPercentages;

        private final List<String>
            interestPercentages;

        private final List<RowData>
            rows;

        private final TotalsData
            totals;


        private ViewData(
                String selectedYear,
                List<String> sanctionPercentages,
                List<String> interestPercentages,
                List<RowData> rows,
                TotalsData totals) {


            this.selectedYear =
                selectedYear;


            this.sanctionPercentages =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        sanctionPercentages
                    )
                );


            this.interestPercentages =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        interestPercentages
                    )
                );


            this.rows =
                Collections.unmodifiableList(
                    new ArrayList<RowData>(
                        rows
                    )
                );


            this.totals =
                totals;
        }


        private static ViewData withoutSelectedYear() {


            return new ViewData(

                "",

                Collections
                    .<String>emptyList(),

                Collections
                    .<String>emptyList(),

                Collections
                    .<RowData>emptyList(),

                TotalsData.empty()
            );
        }


        public boolean hasSelectedYear() {

            return selectedYear != null &&
                   !selectedYear.trim().isEmpty();
        }


        public String getSelectedYear() {

            return selectedYear;
        }


        public List<String> getSanctionPercentages() {

            return sanctionPercentages;
        }


        public List<String> getInterestPercentages() {

            return interestPercentages;
        }


        public List<RowData> getRows() {

            return rows;
        }


        public TotalsData getTotals() {

            return totals;
        }
    }


    /* =========================================================
       ROW DATA
       ========================================================= */

    public static final class RowData {


        private final String entry;

        private final String fcde;

        private final String fcdePercentage;

        private final List<String>
            sanctionAndInterestValues;

        private final List<String>
            releasedFcdeValues;


        private RowData(
                String entry,
                String fcde,
                String fcdePercentage,
                List<String> sanctionAndInterestValues,
                List<String> releasedFcdeValues) {


            this.entry =
                entry;


            this.fcde =
                fcde;


            this.fcdePercentage =
                fcdePercentage;


            this.sanctionAndInterestValues =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        sanctionAndInterestValues
                    )
                );


            this.releasedFcdeValues =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        releasedFcdeValues
                    )
                );
        }


        public String getEntry() {

            return entry;
        }


        public String getFcde() {

            return fcde;
        }


        public String getFcdePercentage() {

            return fcdePercentage;
        }


        public List<String>
                getSanctionAndInterestValues() {

            return sanctionAndInterestValues;
        }


        public List<String>
                getReleasedFcdeValues() {

            return releasedFcdeValues;
        }
    }


    /* =========================================================
       TOTAL DATA
       ========================================================= */

    public static final class TotalsData {


        private final String fcde;

        private final String fcdePercentage;

        private final List<String>
            sanctionAndInterestValues;

        private final List<String>
            releasedFcdeValues;


        private TotalsData(
                String fcde,
                String fcdePercentage,
                List<String> sanctionAndInterestValues,
                List<String> releasedFcdeValues) {


            this.fcde =
                fcde;


            this.fcdePercentage =
                fcdePercentage;


            this.sanctionAndInterestValues =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        sanctionAndInterestValues
                    )
                );


            this.releasedFcdeValues =
                Collections.unmodifiableList(
                    new ArrayList<String>(
                        releasedFcdeValues
                    )
                );
        }


        private static TotalsData empty() {


            return new TotalsData(

                "0,000",

                "0,000",

                Collections
                    .<String>emptyList(),

                Collections
                    .<String>emptyList()
            );
        }


        public String getFcde() {

            return fcde;
        }


        public String getFcdePercentage() {

            return fcdePercentage;
        }


        public List<String>
                getSanctionAndInterestValues() {

            return sanctionAndInterestValues;
        }


        public List<String>
                getReleasedFcdeValues() {

            return releasedFcdeValues;
        }
    }
}