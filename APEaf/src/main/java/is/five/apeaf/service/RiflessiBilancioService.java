package is.five.apeaf.service;

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

import is.five.apeaf.dao.InsResiduiAttiviDAO;
import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.TipologieDAO;

import is.five.apeaf.dao.model.InsResiduiAttivi;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.Tipologia;
import is.five.apeaf.dao.model.UserView;

import is.five.apeaf.service.ImportiDefinibiliService.GroupData;

import is.five.apeaf.utils.Utils;


public class RiflessiBilancioService {

    private static final int NUMBER_OF_HYPOTHESES = 3;


    private final ImportiDefinibiliService importiService =
            new ImportiDefinibiliService();


    private final QuotaFcdeLiberataService quotaFcdeService =
            new QuotaFcdeLiberataService();


    /* =========================================================
       LOAD
       ========================================================= */

    public ViewData load(
            UserView user,
            String selectedYearId) {


        /* =====================================================
           IMPORTI DEFINIBILI

           È la sorgente dei residui sanzioni/interessi usati
           anche in IPOTESI TAGLI.
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
           TIPOLOGIE DEFINITE

           SOLO queste categorie devono essere prodotte.
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
           PARAMETRI

           Le tre colonne vengono lette dalla TABELLA PARAMETRI.

           Per i calcoli:
           - parametro sanzioni indice N
           - parametro interessi indice N
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
           LABEL COLONNE

           50 / 80 / 100, ad esempio.
           ===================================================== */

        List<String> hypothesisLabels =
                new ArrayList<String>();


        DecimalFormat parameterFormat =
                new DecimalFormat(
                        "0.##",
                        DecimalFormatSymbols.getInstance(
                                Locale.ITALY
                        )
                );


        for (int i = 0;
             i < NUMBER_OF_HYPOTHESES;
             i++) {


            BigDecimal value =
                    parameterValue(
                            sanctionParameters,
                            i
                    );


            hypothesisLabels.add(
                    parameterFormat.format(
                            value
                    )
            );
        }


        /* =====================================================
           FORMATTAZIONE MONETARIA
           ===================================================== */

        DecimalFormat moneyFormat =
                new DecimalFormat(
                        "#,##0.00",
                        DecimalFormatSymbols.getInstance(
                                Locale.ITALY
                        )
                );


        moneyFormat.setRoundingMode(
                RoundingMode.HALF_UP
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


        Map<String, BigDecimal> residualByEntry =
                parseResidualValues(
                        residualCsv,
                        tipologieValide
                );


        /* =====================================================
           IMPORTI DEFINIBILI PER TIPOLOGIA
           ===================================================== */

        Map<String, GroupData> importiByEntry =
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


                if (nome.isEmpty() ||
                    !tipologieValide.contains(nome)) {

                    continue;
                }


                importiByEntry.put(
                        nome,
                        group
                );
            }
        }


        /* =====================================================
           QUOTA FCDE LIBERATA

           Recuperiamo i valori già calcolati dal service
           precedente, così il risultato rimane IDENTICO
           alla relativa pagina.
           ===================================================== */

        QuotaFcdeLiberataService.ViewData quotaData =
                quotaFcdeService.load(
                        user,
                        selectedYearId
                );


        Map<String, QuotaFcdeLiberataService.RowData>
                quotaByEntry =
                    new TreeMap<String,
                        QuotaFcdeLiberataService.RowData>(
                            String.CASE_INSENSITIVE_ORDER
                    );


        if (quotaData != null &&
            quotaData.getRows() != null) {


            for (QuotaFcdeLiberataService.RowData row :
                    quotaData.getRows()) {


                if (row == null ||
                    row.getEntry() == null) {

                    continue;
                }


                String nome =
                        row.getEntry().trim();


                if (nome.isEmpty() ||
                    !tipologieValide.contains(nome)) {

                    continue;
                }


                quotaByEntry.put(
                        nome,
                        row
                );
            }
        }


        /* =====================================================
           OUTPUT
           ===================================================== */

        List<RowData> rows =
                new ArrayList<RowData>();


        BigDecimal[] totalResidual =
                zeroArray();


        BigDecimal[] totalCut =
                zeroArray();


        BigDecimal[] totalNewResidual =
                zeroArray();


        BigDecimal[] totalMinorFcde =
                zeroArray();


        BigDecimal[] totalBudgetImpact =
                zeroArray();


        /* =====================================================
           CALCOLO PER TIPOLOGIA
           ===================================================== */

        for (String entryLabel :
                entryLabels) {


            BigDecimal residual =
                    residualByEntry.get(
                            entryLabel
                    );


            if (residual == null) {

                residual =
                        BigDecimal.ZERO;
            }


            GroupData importiGroup =
                    importiByEntry.get(
                            entryLabel
                    );


            BigDecimal residualSanctions =
                    BigDecimal.ZERO;


            BigDecimal residualInterest =
                    BigDecimal.ZERO;


            if (importiGroup != null) {


                if (importiGroup
                        .getTotalResidualSanctionsBD() != null) {


                    residualSanctions =
                            importiGroup
                                .getTotalResidualSanctionsBD();
                }


                if (importiGroup
                        .getTotalResidualInterestBD() != null) {


                    residualInterest =
                            importiGroup
                                .getTotalResidualInterestBD();
                }
            }


            /* =================================================
               QUOTA FCDE LIBERATA PER QUESTA TIPOLOGIA
               ================================================= */

            QuotaFcdeLiberataService.RowData quotaRow =
                    quotaByEntry.get(
                            entryLabel
                    );


            List<String> releasedFcdeSource =
                    quotaRow != null
                            ? quotaRow
                                .getReleasedFcdeValues()
                            : null;


            BigDecimal[] residualValues =
                    zeroArray();


            BigDecimal[] cuts =
                    zeroArray();


            BigDecimal[] newResiduals =
                    zeroArray();


            BigDecimal[] minorFcde =
                    zeroArray();


            BigDecimal[] budgetImpact =
                    zeroArray();


            /* =================================================
               TRE IPOTESI
               ================================================= */

            for (int hypothesis = 0;
                 hypothesis < NUMBER_OF_HYPOTHESES;
                 hypothesis++) {


                /* =============================================
                   RESIDUI ATTIVI

                   Come nel foglio Excel:
                   stesso valore per ogni ipotesi.
                   ============================================= */

                residualValues[hypothesis] =
                        residual;


                /* =============================================
                   TAGLIO

                   Stessa formula di IPOTESI TAGLI:

                   residuo sanzioni * % sanzioni
                   +
                   residuo interessi * % interessi
                   ============================================= */

                BigDecimal sanctionPercentage =
                        parameterValue(
                                sanctionParameters,
                                hypothesis
                        );


                BigDecimal interestPercentage =
                        parameterValue(
                                interestParameters,
                                hypothesis
                        );


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


                BigDecimal cut =
                        sanctionCut.add(
                                interestCut
                        );


                cuts[hypothesis] =
                        cut;


                /* =============================================
                   NUOVI RESIDUI
                   ============================================= */

                newResiduals[hypothesis] =
                        residual.subtract(
                                cut
                        );


                /* =============================================
                   MINOR ACCANTONAMENTO FCDE

                   Stesso valore della pagina
                   QUOTA FCDE LIBERATA.
                   ============================================= */

                BigDecimal minor =
                        BigDecimal.ZERO;


                if (releasedFcdeSource != null &&
                    hypothesis <
                        releasedFcdeSource.size()) {


                    minor =
                            parseNumber(
                                releasedFcdeSource.get(
                                    hypothesis
                                )
                            );
                }


                minorFcde[hypothesis] =
                        minor;


                /* =============================================
                   IMPATTO SUL BILANCIO

                   Il TAGLIO è un impatto negativo.
                   Il minor accantonamento è positivo.

                   quindi:

                   (-taglio) + minor

                   equivalente:

                   minor - taglio
                   ============================================= */

                budgetImpact[hypothesis] =
                        minor.subtract(
                                cut
                        );


                /* =============================================
                   TOTALI
                   ============================================= */

                totalResidual[hypothesis] =
                        totalResidual[hypothesis]
                            .add(
                                residual
                            );


                totalCut[hypothesis] =
                        totalCut[hypothesis]
                            .add(
                                cut
                            );


                totalNewResidual[hypothesis] =
                        totalNewResidual[hypothesis]
                            .add(
                                newResiduals[hypothesis]
                            );


                totalMinorFcde[hypothesis] =
                        totalMinorFcde[hypothesis]
                            .add(
                                minor
                            );


                totalBudgetImpact[hypothesis] =
                        totalBudgetImpact[hypothesis]
                            .add(
                                budgetImpact[hypothesis]
                            );
            }


            rows.add(
                    new RowData(
                            entryLabel,

                            formatValues(
                                    residualValues,
                                    moneyFormat
                            ),

                            formatValues(
                                    cuts,
                                    moneyFormat
                            ),

                            formatValues(
                                    newResiduals,
                                    moneyFormat
                            ),

                            formatValues(
                                    minorFcde,
                                    moneyFormat
                            ),

                            formatSignedValues(
                                    budgetImpact,
                                    moneyFormat
                            )
                    )
            );
        }


        /* =====================================================
           TOTALI
           ===================================================== */

        TotalsData totals =
                new TotalsData(

                        formatValues(
                                totalResidual,
                                moneyFormat
                        ),

                        formatValues(
                                totalCut,
                                moneyFormat
                        ),

                        formatValues(
                                totalNewResidual,
                                moneyFormat
                        ),

                        formatValues(
                                totalMinorFcde,
                                moneyFormat
                        ),

                        formatSignedValues(
                                totalBudgetImpact,
                                moneyFormat
                        )
                );


        return new ViewData(
                selectedYear,
                hypothesisLabels,
                rows,
                totals
        );
    }


    /* =========================================================
       PARAMETRI
       ========================================================= */

    private List<TabPar> loadParameters(
            Integer userId,
            Integer type) {


        List<TabPar> values =
                TabParDAO.findByUserAndType(
                        userId,
                        type
                );


        if (values == null) {

            values =
                    new ArrayList<TabPar>();
        }


        Collections.sort(
                values,
                new Comparator<TabPar>() {

                    @Override
                    public int compare(
                            TabPar left,
                            TabPar right) {


                        BigDecimal l =
                                left != null &&
                                left.getValue() != null
                                    ? left.getValue()
                                    : BigDecimal.ZERO;


                        BigDecimal r =
                                right != null &&
                                right.getValue() != null
                                    ? right.getValue()
                                    : BigDecimal.ZERO;


                        return l.compareTo(r);
                    }
                }
        );


        return values;
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


    /* =========================================================
       RESIDUI ATTIVI

       Gestisce:
       - nuovo formato nome=valore
       - vecchio formato posizionale puro

       Se esiste almeno un "=", ignora tutti i token legacy.
       ========================================================= */

    private Map<String, BigDecimal> parseResidualValues(
            String csv,
            Set<String> validTypes) {


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


        boolean newFormat =
                false;


        for (String token : tokens) {

            if (token != null &&
                token.contains("=")) {


                newFormat =
                        true;

                break;
            }
        }


        /* =====================================================
           NUOVO FORMATO
           ===================================================== */

        if (newFormat) {


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
                        parseNumber(value)
                );
            }


            return result;
        }


        /* =====================================================
           LEGACY PURO
           ===================================================== */

        int position =
                0;


        for (String token :
                tokens) {


            if (position >=
                InsResiduiAttivi.TIPOLOGIE.length) {

                break;
            }


            String name =
                    InsResiduiAttivi
                        .TIPOLOGIE[position];


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
                    parseNumber(token)
            );
        }


        return result;
    }


    /* =========================================================
       NUMERO ITALIANO
       ========================================================= */

    private BigDecimal parseNumber(
            String value) {


        if (value == null ||
            value.trim().isEmpty()) {

            return BigDecimal.ZERO;
        }


        try {

            BigDecimal result =
                    Utils.parseItalianNumber(
                            value.trim()
                    );


            return result != null
                    ? result
                    : BigDecimal.ZERO;


        } catch (Exception exc) {

            return BigDecimal.ZERO;
        }
    }


    /* =========================================================
       ARRAY ZERO
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


    /* =========================================================
       FORMAT VALUES
       ========================================================= */

    private List<String> formatValues(
            BigDecimal[] values,
            DecimalFormat format) {


        List<String> result =
                new ArrayList<String>();


        for (BigDecimal value :
                values) {


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


    /* =========================================================
       FORMAT CON SEGNO

       Produce:
          - 4.927,61
          + 500,00
            0,00
       ========================================================= */

    private List<String> formatSignedValues(
            BigDecimal[] values,
            DecimalFormat format) {


        List<String> result =
                new ArrayList<String>();


        for (BigDecimal value :
                values) {


            if (value == null) {

                value =
                        BigDecimal.ZERO;
            }


            if (value.signum() < 0) {


                result.add(
                        "- " +
                        format.format(
                            value.abs()
                        )
                );


            } else if (value.signum() > 0) {


                result.add(
                        "+ " +
                        format.format(
                            value
                        )
                );


            } else {


                result.add(
                        format.format(
                            BigDecimal.ZERO
                        )
                );
            }
        }


        return result;
    }


    /* =========================================================
       VIEW DATA
       ========================================================= */

    public static class ViewData {


        private final String selectedYear;

        private final List<String> hypothesisLabels;

        private final List<RowData> rows;

        private final TotalsData totals;


        public ViewData(
                String selectedYear,
                List<String> hypothesisLabels,
                List<RowData> rows,
                TotalsData totals) {


            this.selectedYear =
                    selectedYear;

            this.hypothesisLabels =
                    hypothesisLabels;

            this.rows =
                    rows;

            this.totals =
                    totals;
        }


        public static ViewData withoutSelectedYear() {

            return new ViewData(
                    "",
                    new ArrayList<String>(),
                    new ArrayList<RowData>(),
                    null
            );
        }


        public boolean hasSelectedYear() {

            return selectedYear != null &&
                   !selectedYear.trim().isEmpty();
        }


        public String getSelectedYear() {

            return selectedYear;
        }


        public List<String> getHypothesisLabels() {

            return hypothesisLabels;
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

    public static class RowData {


        private final String entry;

        private final List<String> residualValues;

        private final List<String> cutValues;

        private final List<String> newResidualValues;

        private final List<String> minorFcdeValues;

        private final List<String> budgetImpactValues;


        public RowData(
                String entry,
                List<String> residualValues,
                List<String> cutValues,
                List<String> newResidualValues,
                List<String> minorFcdeValues,
                List<String> budgetImpactValues) {


            this.entry =
                    entry;

            this.residualValues =
                    residualValues;

            this.cutValues =
                    cutValues;

            this.newResidualValues =
                    newResidualValues;

            this.minorFcdeValues =
                    minorFcdeValues;

            this.budgetImpactValues =
                    budgetImpactValues;
        }


        public String getEntry() {

            return entry;
        }


        public List<String> getResidualValues() {

            return residualValues;
        }


        public List<String> getCutValues() {

            return cutValues;
        }


        public List<String> getNewResidualValues() {

            return newResidualValues;
        }


        public List<String> getMinorFcdeValues() {

            return minorFcdeValues;
        }


        public List<String> getBudgetImpactValues() {

            return budgetImpactValues;
        }
    }


    /* =========================================================
       TOTALS DATA
       ========================================================= */

    public static class TotalsData {


        private final List<String> residualValues;

        private final List<String> cutValues;

        private final List<String> newResidualValues;

        private final List<String> minorFcdeValues;

        private final List<String> budgetImpactValues;


        public TotalsData(
                List<String> residualValues,
                List<String> cutValues,
                List<String> newResidualValues,
                List<String> minorFcdeValues,
                List<String> budgetImpactValues) {


            this.residualValues =
                    residualValues;

            this.cutValues =
                    cutValues;

            this.newResidualValues =
                    newResidualValues;

            this.minorFcdeValues =
                    minorFcdeValues;

            this.budgetImpactValues =
                    budgetImpactValues;
        }


        public List<String> getResidualValues() {

            return residualValues;
        }


        public List<String> getCutValues() {

            return cutValues;
        }


        public List<String> getNewResidualValues() {

            return newResidualValues;
        }


        public List<String> getMinorFcdeValues() {

            return minorFcdeValues;
        }


        public List<String> getBudgetImpactValues() {

            return budgetImpactValues;
        }
    }
}