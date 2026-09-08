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
import is.five.apeaf.utils.CSVUtils;
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

        /* =========================================================
           IMPORTI DEFINIBILI
           ========================================================= */

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


        /* =========================================================
           TIPOLOGIE DEFINITE

           Queste sono le UNICHE categorie che devono essere
           considerate nei calcoli.
           ========================================================= */

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


        /*
         * Il DAO le restituisce già ordinate per value ASC,
         * quindi entryLabels conserva l'ordine configurato.
         */


        /* =========================================================
           FCDE / RESIDUI
           ========================================================= */

        InsDatiFCDE fcdeData =
                InsDatiFCDEDAO.findByUserAndAnno(
                        user.getId(),
                        year
                );


        InsResiduiAttivi residualData =
                InsResiduiAttiviDAO.findByUserAndAnno(
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


        String residualCsv =
                residualData == null ||
                residualData.getValue() == null
                        ? ""
                        : residualData
                            .getValue()
                            .trim();


        /* =========================================================
           PARSING PER NOME TIPOLOGIA

           Niente più accesso tramite indice.
           ========================================================= */

        Map<String, BigDecimal> fcdePerTipologia =
                parseFcdeValues(
                        fcdeCsv,
                        tipologieValide
                );


        Map<String, BigDecimal> residuiPerTipologia =
                parseResidualValues(
                        residualCsv,
                        tipologieValide
                );


        /* =========================================================
           PARAMETRI SANZIONI / INTERESSI
           ========================================================= */

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


        /* =========================================================
           FORMATO
           ========================================================= */

        DecimalFormat italianThreeDecimals =
                new DecimalFormat(
                        "#,##0.000",
                        DecimalFormatSymbols.getInstance(
                                Locale.ITALY
                        )
                );


        italianThreeDecimals.setRoundingMode(
                RoundingMode.HALF_UP
        );


        /* =========================================================
           GRUPPI IMPORTI DEFINIBILI PER TIPOLOGIA

           Anche qui niente più groupIndex.
           ========================================================= */

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


                /*
                 * Consideriamo solo categorie ancora definite.
                 */
                if (!tipologieValide.contains(nome)) {

                    continue;
                }


                groupsByEntry.put(
                        nome,
                        group
                );
            }
        }


        /* =========================================================
           OUTPUT
           ========================================================= */

        List<RowData> calculatedRows =
                new ArrayList<RowData>();


        BigDecimal totalFcde =
                BigDecimal.ZERO;


        BigDecimal totalResidual =
                BigDecimal.ZERO;


        BigDecimal[] totalSanctionAndInterest =
                new BigDecimal[NUMBER_OF_HYPOTHESES];


        BigDecimal[] totalReleasedFcde =
                new BigDecimal[NUMBER_OF_HYPOTHESES];


        for (int hypothesis = 0;
             hypothesis < NUMBER_OF_HYPOTHESES;
             hypothesis++) {


            totalSanctionAndInterest[hypothesis] =
                    BigDecimal.ZERO;


            totalReleasedFcde[hypothesis] =
                    BigDecimal.ZERO;
        }


        /* =========================================================
           CALCOLO PER OGNI TIPOLOGIA DEFINITA
           ========================================================= */

        for (String entryLabel :
                entryLabels) {


            /* -----------------------------------------------------
               FCDE
               ----------------------------------------------------- */

            BigDecimal fcde =
                    fcdePerTipologia.get(
                            entryLabel
                    );


            if (fcde == null) {

                fcde =
                        BigDecimal.ZERO;
            }


            /* -----------------------------------------------------
               RESIDUO ATTIVO
               ----------------------------------------------------- */

            BigDecimal residual =
                    residuiPerTipologia.get(
                            entryLabel
                    );


            if (residual == null) {

                residual =
                        BigDecimal.ZERO;
            }


            /* -----------------------------------------------------
               GRUPPO RUOLI / IMPORTI DEFINIBILI
               ----------------------------------------------------- */

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


            /* -----------------------------------------------------
               % FCDE

               IMPORTANTISSIMO:
               evitiamo divisione per zero / Infinity / NaN.
               ----------------------------------------------------- */

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
                                10,
                                RoundingMode.HALF_UP
                            );
            }


            /* -----------------------------------------------------
               TOTALI BASE
               ----------------------------------------------------- */

            totalFcde =
                    totalFcde.add(
                            fcde
                    );


            totalResidual =
                    totalResidual.add(
                            residual
                    );


            List<String> sanctionAndInterestValues =
                    new ArrayList<String>();


            List<String> releasedFcdeValues =
                    new ArrayList<String>();


            /* =====================================================
               IPOTESI TAGLI
               ===================================================== */

            for (int hypothesis = 0;
                 hypothesis < NUMBER_OF_HYPOTHESES;
                 hypothesis++) {


                /* -------------------------------------------------
                   % SANZIONE
                   ------------------------------------------------- */

                BigDecimal sanctionPercentage =
                        parameterValue(
                                sanctionParameters,
                                hypothesis
                        );


                if (sanctionPercentage == null) {

                    sanctionPercentage =
                            BigDecimal.ZERO;
                }


                /* -------------------------------------------------
                   % INTERESSI
                   ------------------------------------------------- */

                BigDecimal interestPercentage =
                        parameterValue(
                                interestParameters,
                                hypothesis
                        );


                if (interestPercentage == null) {

                    interestPercentage =
                            BigDecimal.ZERO;
                }


                /* -------------------------------------------------
                   TAGLIO SANZIONI
                   ------------------------------------------------- */

                BigDecimal sanctionCut =
                        residualSanctions
                            .multiply(
                                sanctionPercentage
                            )
                            .divide(
                                BigDecimal.valueOf(100),
                                10,
                                RoundingMode.HALF_UP
                            );


                /* -------------------------------------------------
                   TAGLIO INTERESSI
                   ------------------------------------------------- */

                BigDecimal interestCut =
                        residualInterest
                            .multiply(
                                interestPercentage
                            )
                            .divide(
                                BigDecimal.valueOf(100),
                                10,
                                RoundingMode.HALF_UP
                            );


                /* -------------------------------------------------
                   RESIDUO DOPO TAGLI
                   ------------------------------------------------- */

                BigDecimal residualAfterCuts =
                        residual
                            .subtract(
                                sanctionCut
                            )
                            .subtract(
                                interestCut
                            );


                /* -------------------------------------------------
                   VALORE FCDE DOPO SANZIONI + INTERESSI

                   Formula originale:

                   fcdePercentage
                   * (residual - sanctionCut - interestCut)
                   / 100
                   ------------------------------------------------- */

                BigDecimal calculatedValue =
                        fcdePercentage
                            .multiply(
                                residualAfterCuts
                            )
                            .divide(
                                BigDecimal.valueOf(100),
                                10,
                                RoundingMode.HALF_UP
                            );


                sanctionAndInterestValues.add(
                        italianThreeDecimals.format(
                                calculatedValue
                        )
                );


                totalSanctionAndInterest[hypothesis] =
                        totalSanctionAndInterest[hypothesis]
                            .add(
                                calculatedValue
                            );


                /* -------------------------------------------------
                   QUOTA FCDE LIBERATA

                   FCDE accantonato - FCDE ricalcolato
                   ------------------------------------------------- */

                BigDecimal releasedFcde =
                        fcde.subtract(
                                calculatedValue
                        );


                releasedFcdeValues.add(
                        italianThreeDecimals.format(
                                releasedFcde
                        )
                );


                totalReleasedFcde[hypothesis] =
                        totalReleasedFcde[hypothesis]
                            .add(
                                releasedFcde
                            );
            }


            /* =====================================================
               RIGA
               ===================================================== */

            calculatedRows.add(
                    new RowData(
                            entryLabel,
                            italianThreeDecimals.format(
                                    fcde
                            ),
                            italianThreeDecimals.format(
                                    fcdePercentage
                            ),
                            sanctionAndInterestValues,
                            releasedFcdeValues
                    )
            );
        }


        /* =========================================================
           % FCDE TOTALE
           ========================================================= */

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
                            10,
                            RoundingMode.HALF_UP
                        );
        }


        /* =========================================================
           TOTALI
           ========================================================= */

        TotalsData totals =
                new TotalsData(
                        italianThreeDecimals.format(
                                totalFcde
                        ),
                        italianThreeDecimals.format(
                                totalFcdePercentage
                        ),
                        formatValues(
                                totalSanctionAndInterest,
                                italianThreeDecimals
                        ),
                        formatValues(
                                totalReleasedFcde,
                                italianThreeDecimals
                        )
                );


        /* =========================================================
           VIEW DATA
           ========================================================= */

        return new ViewData(
                selectedYear,
                formatParameterValues(
                        sanctionParameters,
                        italianThreeDecimals
                ),
                formatParameterValues(
                        interestParameters,
                        italianThreeDecimals
                ),
                calculatedRows,
                totals
        );
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
            BigDecimal[] values,
            DecimalFormat format) {


        List<String> result =
                new ArrayList<String>();


        if (values == null) {

            return result;
        }


        for (BigDecimal value : values) {

            result.add(
                    format.format(
                            value != null
                                    ? value
                                    : BigDecimal.ZERO
                    )
            );
        }


        return result;
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
    
    private Map<String, BigDecimal> parseResidualValues(
            String csv,
            Set<String> tipologieValide) {


        Map<String, BigDecimal> result =
                new TreeMap<String, BigDecimal>(
                        String.CASE_INSENSITIVE_ORDER
                );


        if (csv == null ||
            csv.trim().isEmpty()) {

            return result;
        }


        String[] tokens =
                csv.split(";", -1);


        boolean nuovoFormato =
                false;


        for (String token : tokens) {

            if (token != null &&
                token.contains("=")) {

                nuovoFormato =
                        true;

                break;
            }
        }


        /* =========================================================
           NUOVO FORMATO
           ========================================================= */

        if (nuovoFormato) {


            for (String token : tokens) {


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


                String nome =
                        parts[0] != null
                                ? parts[0].trim()
                                : "";


                if (nome.isEmpty()) {
                    continue;
                }


                /*
                 * Ignoriamo completamente tipologie
                 * non più configurate.
                 */
                if (!tipologieValide.contains(nome)) {
                    continue;
                }


                String valoreString =
                        parts.length > 1 &&
                        parts[1] != null
                                ? parts[1].trim()
                                : "0";


                BigDecimal valore =
                        parseNumber(
                                valoreString
                        );


                result.put(
                        nome,
                        valore
                );
            }


            return result;
        }


        /* =========================================================
           VECCHIO FORMATO POSIZIONALE

           Utilizzato SOLO quando non esiste alcun "=".
           ========================================================= */

        int position =
                0;


        for (String token : tokens) {


            if (position >=
                InsResiduiAttivi.TIPOLOGIE.length) {

                break;
            }


            String nome =
                    InsResiduiAttivi
                        .TIPOLOGIE[position];


            position++;


            if (nome == null ||
                nome.trim().isEmpty()) {

                continue;
            }


            nome =
                    nome.trim();


            /*
             * Legacy category non più configurata:
             * viene ignorata.
             */
            if (!tipologieValide.contains(nome)) {

                continue;
            }


            BigDecimal valore =
                    parseNumber(
                            token
                    );


            result.put(
                    nome,
                    valore
            );
        }


        return result;
    }
    
    private Map<String, BigDecimal> parseFcdeValues(
            String csv,
            Set<String> tipologieValide) {


        Map<String, BigDecimal> result =
                new TreeMap<String, BigDecimal>(
                        String.CASE_INSENSITIVE_ORDER
                );


        if (csv == null ||
            csv.trim().isEmpty()) {

            return result;
        }


        String[] tokens =
                csv.split(";", -1);


        boolean nuovoFormato =
                false;


        for (String token : tokens) {

            if (token != null &&
                token.contains("=")) {

                nuovoFormato =
                        true;

                break;
            }
        }


        /* =========================================================
           NUOVO FORMATO
           ========================================================= */

        if (nuovoFormato) {


            for (String token : tokens) {


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


                String nome =
                        parts[0] != null
                                ? parts[0].trim()
                                : "";


                if (nome.isEmpty()) {
                    continue;
                }


                if (!tipologieValide.contains(nome)) {

                    continue;
                }


                String valoreString =
                        parts.length > 1 &&
                        parts[1] != null
                                ? parts[1].trim()
                                : "0";


                BigDecimal valore =
                        parseNumber(
                                valoreString
                        );


                result.put(
                        nome,
                        valore
                );
            }


            return result;
        }


        /* =========================================================
           LEGACY
           ========================================================= */

        int position =
                0;


        for (String token : tokens) {


            if (position >=
                InsDatiFCDE.TIPOLOGIE.length) {

                break;
            }


            String nome =
                    InsDatiFCDE
                        .TIPOLOGIE[position];


            position++;


            if (nome == null ||
                nome.trim().isEmpty()) {

                continue;
            }


            nome =
                    nome.trim();


            if (!tipologieValide.contains(nome)) {

                continue;
            }


            BigDecimal valore =
                    parseNumber(
                            token
                    );


            result.put(
                    nome,
                    valore
            );
        }


        return result;
    }
    
    private BigDecimal parseNumber(String value) {

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
}
