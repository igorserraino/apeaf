package is.five.apeaf.service;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.utils.Utils;


public class ValutazioneGeneraleService {


    private final RiflessiBilancioService riflessiService =
            new RiflessiBilancioService();


    /* =========================================================
       LOAD
       ========================================================= */

    public ViewData load(
            UserView user,
            String selectedYearId) {


        /* =====================================================
           RIFLESSI SUL BILANCIO

           Tutti i dati necessari sono già calcolati
           correttamente nel service precedente.
           ===================================================== */

        RiflessiBilancioService.ViewData riflessiData =
                riflessiService.load(
                        user,
                        selectedYearId
                );


        if (!riflessiData.hasSelectedYear()) {

            return ViewData.withoutSelectedYear();
        }


        String selectedYear =
                riflessiData.getSelectedYear();


        RiflessiBilancioService.TotalsData riflessiTotals =
                riflessiData.getTotals();


        /* =====================================================
           NESSUN TOTALE
           ===================================================== */

        if (riflessiTotals == null) {

            return new ViewData(
                    selectedYear,
                    riflessiData.getHypothesisLabels(),
                    new ArrayList<String>(),
                    new ArrayList<String>(),
                    new ArrayList<String>(),
                    new ArrayList<String>(),
                    new ArrayList<String>()
            );
        }


        /* =====================================================
           FORMATTAZIONE
           ===================================================== */

        DecimalFormat moneyFormat =
                new DecimalFormat(
                        "#,##0.00",
                        DecimalFormatSymbols.getInstance(
                                Locale.ITALY
                        )
                );


        /* =====================================================
           1. TOTALE RESIDUI

           Proviene dalla TOTALI AREA di Riflessi Bilancio,
           che a sua volta deriva da Ins. Residui Attivi.
           ===================================================== */

        List<String> totaleResidui =
                copyValues(
                        riflessiTotals.getResidualValues()
                );


        /* =====================================================
           2. TOTALE TAGLI

           TOTALI AREA di Riflessi Bilancio.
           ===================================================== */

        List<String> totaleTagli =
                copyValues(
                        riflessiTotals.getCutValues()
                );


        /* =====================================================
           3. RESIDUI AL NETTO

           TOTALI AREA di Riflessi Bilancio.
           ===================================================== */

        List<String> residuiNetti =
                copyValues(
                        riflessiTotals.getNewResidualValues()
                );


        /* =====================================================
           4. MINOR ACCANTONAMENTO FCDE

           TOTALI AREA di Riflessi Bilancio.
           ===================================================== */

        List<String> minorAccantonamentoFcde =
                copyValues(
                        riflessiTotals.getMinorFcdeValues()
                );


        /* =====================================================
           5. TOTALE

           Formula richiesta:

           -TOTALE TAGLI N
           +
           MINOR ACCANTONAMENTO FCDE N
           ===================================================== */

        List<String> totali =
                new ArrayList<String>();


        int numberOfHypotheses =
                Math.max(
                        totaleTagli.size(),
                        minorAccantonamentoFcde.size()
                );


        for (int i = 0;
             i < numberOfHypotheses;
             i++) {


            BigDecimal taglio =
                    i < totaleTagli.size()

                            ? parseNumber(
                                    totaleTagli.get(i)
                              )

                            : BigDecimal.ZERO;


            BigDecimal minorFcde =
                    i < minorAccantonamentoFcde.size()

                            ? parseNumber(
                                    minorAccantonamentoFcde.get(i)
                              )

                            : BigDecimal.ZERO;


            BigDecimal totale =
            		minorFcde.subtract(
                            taglio
                    );


            totali.add(
                    moneyFormat.format(
                            totale
                    )
            );
        }


        /* =====================================================
           VIEW DATA
           ===================================================== */

        return new ViewData(

                selectedYear,

                copyValues(
                        riflessiData
                            .getHypothesisLabels()
                ),

                totaleResidui,

                totaleTagli,

                residuiNetti,

                minorAccantonamentoFcde,

                totali
        );
    }


    /* =========================================================
       PARSE NUMERO ITALIANO
       ========================================================= */

    private BigDecimal parseNumber(
            String value) {


        if (value == null ||
            value.trim().isEmpty()) {

            return BigDecimal.ZERO;
        }


        try {

            /*
             * Gestione anche di eventuali stringhe già formattate:
             *
             * - 22.652,57
             * + 10.000,00
             */
            String normalized =
                    value
                        .trim()
                        .replace("+", "")
                        .trim();


            BigDecimal parsed =
                    Utils.parseItalianNumber(
                            normalized
                    );


            return parsed != null
                    ? parsed
                    : BigDecimal.ZERO;


        } catch (Exception exc) {

            return BigDecimal.ZERO;
        }
    }


    /* =========================================================
       COPY LIST

       Evitiamo di esporre direttamente le liste del
       service precedente.
       ========================================================= */

    private List<String> copyValues(
            List<String> source) {


        if (source == null) {

            return new ArrayList<String>();
        }


        return new ArrayList<String>(
                source
        );
    }


    /* =========================================================
       VIEW DATA
       ========================================================= */

    public static class ViewData {


        private final String selectedYear;

        private final List<String> hypothesisLabels;

        private final List<String> totalResidualValues;

        private final List<String> totalCutValues;

        private final List<String> netResidualValues;

        private final List<String> minorFcdeValues;

        private final List<String> totalValues;


        public ViewData(
                String selectedYear,
                List<String> hypothesisLabels,
                List<String> totalResidualValues,
                List<String> totalCutValues,
                List<String> netResidualValues,
                List<String> minorFcdeValues,
                List<String> totalValues) {


            this.selectedYear =
                    selectedYear;


            this.hypothesisLabels =
                    hypothesisLabels;


            this.totalResidualValues =
                    totalResidualValues;


            this.totalCutValues =
                    totalCutValues;


            this.netResidualValues =
                    netResidualValues;


            this.minorFcdeValues =
                    minorFcdeValues;


            this.totalValues =
                    totalValues;
        }


        public static ViewData withoutSelectedYear() {


            return new ViewData(

                    "",

                    new ArrayList<String>(),

                    new ArrayList<String>(),

                    new ArrayList<String>(),

                    new ArrayList<String>(),

                    new ArrayList<String>(),

                    new ArrayList<String>()
            );
        }


        public boolean hasSelectedYear() {


            return selectedYear != null &&
                   !selectedYear.trim().isEmpty();
        }


        public boolean hasData() {


            return totalResidualValues != null &&
                   !totalResidualValues.isEmpty();
        }


        public String getSelectedYear() {

            return selectedYear;
        }


        public List<String> getHypothesisLabels() {

            return hypothesisLabels;
        }


        public List<String> getTotalResidualValues() {

            return totalResidualValues;
        }


        public List<String> getTotalCutValues() {

            return totalCutValues;
        }


        public List<String> getNetResidualValues() {

            return netResidualValues;
        }


        public List<String> getMinorFcdeValues() {

            return minorFcdeValues;
        }


        public List<String> getTotalValues() {

            return totalValues;
        }
    }
}