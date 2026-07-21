package is.five.apeaf.service;

import is.five.apeaf.dao.AnnoFinanziarioDAO;
import is.five.apeaf.dao.InsTabRuoliDAO;
import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.model.Entrata;
import is.five.apeaf.dao.model.InsTabRuoli;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.UserView;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

/**
 * Loads and prepares all server-side data used by ins-tab-ruoli.jsp.
 * It has no dependency on JSP or Servlet APIs and can be reused by other pages.
 */
public class TabRuoliPageService {

    private static final int IDX_ENTRATA = 0;
    private static final int IDX_CONCESSIONARIO = 1;
    private static final int IDX_DATA_CONSEGNA = 2;
    private static final int IDX_ANNO_RUOLO = 3;
    private static final int IDX_NUMERO_RUOLO = 4;
    private static final int IDX_IMPOSTA_RUOLO = 5;
    private static final int IDX_SANZIONI_RUOLO = 6;
    private static final int IDX_INTERESSI_RUOLO = 7;
    private static final int IDX_IMPORTO_RUOLO = 8;
    private static final int IDX_IMPOSTA_RISCOSSA = 9;
    private static final int IDX_SANZIONI_RISCOSSE = 10;
    private static final int IDX_INTERESSI_RISCOSSI = 11;
    private static final int IDX_IMPORTO_RISCOSSO = 12;
    private static final int IDX_RESIDUI = 13;
    private static final int IDX_PERCENTUALE_RISCOSSO = 14;

    public PageData load(UserView user, String selectedYearId) {
        String selectedYear = findSelectedYear(selectedYearId);

        if (selectedYear.trim().isEmpty()) {
            return PageData.withoutSelectedYear();
        }

        // These two calls are retained because they were present in the JSP.
        List<TabPar> sanctionValues = TabParDAO.findByUserAndType(
                user.getId(), TabPar.TYPE_SANZIONE);
        List<TabPar> interestValues = TabParDAO.findByUserAndType(
                user.getId(), TabPar.TYPE_INTERESSI);

        List<InsTabRuoli> roles = InsTabRuoliDAO.findByUserAndAnno(
                user.getId(), Integer.parseInt(selectedYear));

        Map<String, List<ParsedRole>> rolesByEntry =
                new TreeMap<String, List<ParsedRole>>(String.CASE_INSENSITIVE_ORDER);

        if (roles != null) {
            for (InsTabRuoli role : roles) {
                ParsedRole parsedRole = parseRole(role);
                String groupName = parsedRole.entry.isEmpty()
                        ? "ENTRATA NON DEFINITA"
                        : parsedRole.entry;

                List<ParsedRole> group = rolesByEntry.get(groupName);
                if (group == null) {
                    group = new ArrayList<ParsedRole>();
                    rolesByEntry.put(groupName, group);
                }

                group.add(parsedRole);
            }
        }

        DecimalFormatSymbols symbols = DecimalFormatSymbols.getInstance(Locale.ITALY);
        DecimalFormat moneyFormat = new DecimalFormat("#,##0.00", symbols);
        DecimalFormat percentFormat = new DecimalFormat("#,##0.00", symbols);

        List<GroupData> groups = new ArrayList<GroupData>();
        TotalsAccumulator overallTotals = new TotalsAccumulator();

        for (Map.Entry<String, List<ParsedRole>> entry : rolesByEntry.entrySet()) {
            List<ParsedRole> groupRoles = entry.getValue();
            Collections.sort(groupRoles, new Comparator<ParsedRole>() {
                @Override
                public int compare(ParsedRole left, ParsedRole right) {
                    return Integer.compare(left.sortYear, right.sortYear);
                }
            });

            List<RowData> rows = new ArrayList<RowData>();
            TotalsAccumulator groupTotals = new TotalsAccumulator();

            for (ParsedRole role : groupRoles) {
                groupTotals.add(role);
                overallTotals.add(role);

                rows.add(new RowData(
                        role.id,
                        role.entry,
                        role.concessionaire,
                        role.deliveryDate,
                        role.roleYear,
                        role.roleNumber,
                        moneyFormat.format(role.roleTax),
                        moneyFormat.format(role.roleSanctions),
                        moneyFormat.format(role.roleInterest),
                        moneyFormat.format(role.roleAmount),
                        moneyFormat.format(role.collectedTax),
                        moneyFormat.format(role.collectedSanctions),
                        moneyFormat.format(role.collectedInterest),
                        moneyFormat.format(role.collectedAmount),
                        moneyFormat.format(role.residual),
                        role.percentageStored.isEmpty()
                                ? null
                                : percentFormat.format(role.percentage)));
            }

            groups.add(new GroupData(
                    entry.getKey(),
                    rows,
                    groupTotals.toData(moneyFormat, percentFormat)));
        }

        List<String> entryOptions = new ArrayList<String>(
                Arrays.asList(Entrata.values));

        return new PageData(
                selectedYear,
                entryOptions,
                groups,
                overallTotals.toData(moneyFormat, percentFormat),
                sanctionValues,
                interestValues);
    }

    private String findSelectedYear(String selectedYearId) {
        if (selectedYearId == null || selectedYearId.trim().isEmpty()) {
            return "";
        }

        try {
            AnnoFinanziarioDAO yearsDao = new AnnoFinanziarioDAO();
            return String.valueOf(
                    yearsDao.findByID(Integer.parseInt(selectedYearId)).getAnno());
        } catch (Exception ignored) {
            // Same behavior as the original JSP.
            return "";
        }
    }

    private ParsedRole parseRole(InsTabRuoli role) {
        String csv = role.getValues() == null ? "" : role.getValues();
        String[] values = csv.split(";", -1);

        return new ParsedRole(
                role.getId(),
                csvValue(values, IDX_ENTRATA),
                csvValue(values, IDX_CONCESSIONARIO),
                csvValue(values, IDX_DATA_CONSEGNA),
                csvValue(values, IDX_ANNO_RUOLO),
                csvValue(values, IDX_NUMERO_RUOLO),
                csvInteger(values, IDX_ANNO_RUOLO),
                csvDecimal(values, IDX_IMPOSTA_RUOLO),
                csvDecimal(values, IDX_SANZIONI_RUOLO),
                csvDecimal(values, IDX_INTERESSI_RUOLO),
                csvDecimal(values, IDX_IMPORTO_RUOLO),
                csvDecimal(values, IDX_IMPOSTA_RISCOSSA),
                csvDecimal(values, IDX_SANZIONI_RISCOSSE),
                csvDecimal(values, IDX_INTERESSI_RISCOSSI),
                csvDecimal(values, IDX_IMPORTO_RISCOSSO),
                csvDecimal(values, IDX_RESIDUI),
                csvValue(values, IDX_PERCENTUALE_RISCOSSO),
                csvDecimal(values, IDX_PERCENTUALE_RISCOSSO));
    }

    private String csvValue(String[] values, int index) {
        if (values == null || index < 0 || index >= values.length) {
            return "";
        }

        return values[index] == null ? "" : values[index].trim();
    }

    private BigDecimal csvDecimal(String[] values, int index) {
        String value = csvValue(values, index);
        if (value.isEmpty()) {
            return BigDecimal.ZERO;
        }

        try {
            value = value
                    .replace("€", "")
                    .replace("%", "")
                    .replace("\u00A0", "")
                    .replace(" ", "");

            if (value.contains(",") && value.contains(".")) {
                value = value.replace(".", "").replace(",", ".");
            } else if (value.contains(",")) {
                value = value.replace(",", ".");
            }

            return new BigDecimal(value);
        } catch (NumberFormatException ignored) {
            return BigDecimal.ZERO;
        }
    }

    private int csvInteger(String[] values, int index) {
        String value = csvValue(values, index);
        if (value.isEmpty()) {
            return Integer.MAX_VALUE;
        }

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ignored) {
            return Integer.MAX_VALUE;
        }
    }

    private static final class TotalsAccumulator {
        private BigDecimal roleTax = BigDecimal.ZERO;
        private BigDecimal roleSanctions = BigDecimal.ZERO;
        private BigDecimal roleInterest = BigDecimal.ZERO;
        private BigDecimal roleAmount = BigDecimal.ZERO;
        private BigDecimal collectedTax = BigDecimal.ZERO;
        private BigDecimal collectedSanctions = BigDecimal.ZERO;
        private BigDecimal collectedInterest = BigDecimal.ZERO;
        private BigDecimal collectedAmount = BigDecimal.ZERO;
        private BigDecimal residual = BigDecimal.ZERO;
        private BigDecimal percentageSum = BigDecimal.ZERO;
        private int percentageCount;

        private void add(ParsedRole role) {
            roleTax = roleTax.add(role.roleTax);
            roleSanctions = roleSanctions.add(role.roleSanctions);
            roleInterest = roleInterest.add(role.roleInterest);
            roleAmount = roleAmount.add(role.roleAmount);
            collectedTax = collectedTax.add(role.collectedTax);
            collectedSanctions = collectedSanctions.add(role.collectedSanctions);
            collectedInterest = collectedInterest.add(role.collectedInterest);
            collectedAmount = collectedAmount.add(role.collectedAmount);
            residual = residual.add(role.residual);

            if (!role.percentageStored.isEmpty()) {
                percentageSum = percentageSum.add(role.percentage);
                percentageCount++;
            }
        }

        private TotalsData toData(
                DecimalFormat moneyFormat,
                DecimalFormat percentFormat) {
            String averagePercentage = null;

            if (percentageCount > 0) {
                BigDecimal average = percentageSum.divide(
                        BigDecimal.valueOf(percentageCount),
                        2,
                        RoundingMode.HALF_UP);
                averagePercentage = percentFormat.format(average);
            }

            return new TotalsData(
                    moneyFormat.format(roleTax),
                    moneyFormat.format(roleSanctions),
                    moneyFormat.format(roleInterest),
                    moneyFormat.format(roleAmount),
                    moneyFormat.format(collectedTax),
                    moneyFormat.format(collectedSanctions),
                    moneyFormat.format(collectedInterest),
                    moneyFormat.format(collectedAmount),
                    moneyFormat.format(residual),
                    averagePercentage);
        }
    }

    private static final class ParsedRole {
        private final int id;
        private final String entry;
        private final String concessionaire;
        private final String deliveryDate;
        private final String roleYear;
        private final String roleNumber;
        private final int sortYear;
        private final BigDecimal roleTax;
        private final BigDecimal roleSanctions;
        private final BigDecimal roleInterest;
        private final BigDecimal roleAmount;
        private final BigDecimal collectedTax;
        private final BigDecimal collectedSanctions;
        private final BigDecimal collectedInterest;
        private final BigDecimal collectedAmount;
        private final BigDecimal residual;
        private final String percentageStored;
        private final BigDecimal percentage;

        private ParsedRole(
                int id,
                String entry,
                String concessionaire,
                String deliveryDate,
                String roleYear,
                String roleNumber,
                int sortYear,
                BigDecimal roleTax,
                BigDecimal roleSanctions,
                BigDecimal roleInterest,
                BigDecimal roleAmount,
                BigDecimal collectedTax,
                BigDecimal collectedSanctions,
                BigDecimal collectedInterest,
                BigDecimal collectedAmount,
                BigDecimal residual,
                String percentageStored,
                BigDecimal percentage) {
            this.id = id;
            this.entry = entry;
            this.concessionaire = concessionaire;
            this.deliveryDate = deliveryDate;
            this.roleYear = roleYear;
            this.roleNumber = roleNumber;
            this.sortYear = sortYear;
            this.roleTax = roleTax;
            this.roleSanctions = roleSanctions;
            this.roleInterest = roleInterest;
            this.roleAmount = roleAmount;
            this.collectedTax = collectedTax;
            this.collectedSanctions = collectedSanctions;
            this.collectedInterest = collectedInterest;
            this.collectedAmount = collectedAmount;
            this.residual = residual;
            this.percentageStored = percentageStored;
            this.percentage = percentage;
        }
    }

    public static final class PageData {
        private final String selectedYear;
        private final List<String> entryOptions;
        private final List<GroupData> groups;
        private final TotalsData overallTotals;
        private final List<TabPar> sanctionValues;
        private final List<TabPar> interestValues;

        private PageData(
                String selectedYear,
                List<String> entryOptions,
                List<GroupData> groups,
                TotalsData overallTotals,
                List<TabPar> sanctionValues,
                List<TabPar> interestValues) {
            this.selectedYear = selectedYear;
            this.entryOptions = Collections.unmodifiableList(
                    new ArrayList<String>(entryOptions));
            this.groups = Collections.unmodifiableList(
                    new ArrayList<GroupData>(groups));
            this.overallTotals = overallTotals;
            this.sanctionValues = sanctionValues;
            this.interestValues = interestValues;
        }

        private static PageData withoutSelectedYear() {
            return new PageData(
                    "",
                    Collections.<String>emptyList(),
                    Collections.<GroupData>emptyList(),
                    TotalsData.zero(),
                    Collections.<TabPar>emptyList(),
                    Collections.<TabPar>emptyList());
        }

        public boolean hasSelectedYear() { return !selectedYear.trim().isEmpty(); }
        public String getSelectedYear() { return selectedYear; }
        public List<String> getEntryOptions() { return entryOptions; }
        public List<GroupData> getGroups() { return groups; }
        public boolean hasGroups() { return !groups.isEmpty(); }
        public TotalsData getOverallTotals() { return overallTotals; }
        public List<TabPar> getSanctionValues() { return sanctionValues; }
        public List<TabPar> getInterestValues() { return interestValues; }
    }

    public static final class GroupData {
        private final String entry;
        private final List<RowData> rows;
        private final TotalsData totals;

        private GroupData(String entry, List<RowData> rows, TotalsData totals) {
            this.entry = entry;
            this.rows = Collections.unmodifiableList(new ArrayList<RowData>(rows));
            this.totals = totals;
        }

        public String getEntry() { return entry; }
        public List<RowData> getRows() { return rows; }
        public TotalsData getTotals() { return totals; }
    }

    public static final class RowData {
        private final int id;
        private final String entry;
        private final String concessionaire;
        private final String deliveryDate;
        private final String roleYear;
        private final String roleNumber;
        private final String roleTax;
        private final String roleSanctions;
        private final String roleInterest;
        private final String roleAmount;
        private final String collectedTax;
        private final String collectedSanctions;
        private final String collectedInterest;
        private final String collectedAmount;
        private final String residual;
        private final String percentage;

        private RowData(
                int id,
                String entry,
                String concessionaire,
                String deliveryDate,
                String roleYear,
                String roleNumber,
                String roleTax,
                String roleSanctions,
                String roleInterest,
                String roleAmount,
                String collectedTax,
                String collectedSanctions,
                String collectedInterest,
                String collectedAmount,
                String residual,
                String percentage) {
            this.id = id;
            this.entry = entry;
            this.concessionaire = concessionaire;
            this.deliveryDate = deliveryDate;
            this.roleYear = roleYear;
            this.roleNumber = roleNumber;
            this.roleTax = roleTax;
            this.roleSanctions = roleSanctions;
            this.roleInterest = roleInterest;
            this.roleAmount = roleAmount;
            this.collectedTax = collectedTax;
            this.collectedSanctions = collectedSanctions;
            this.collectedInterest = collectedInterest;
            this.collectedAmount = collectedAmount;
            this.residual = residual;
            this.percentage = percentage;
        }

        public int getId() { return id; }
        public String getEntry() { return entry; }
        public String getConcessionaire() { return concessionaire; }
        public String getDeliveryDate() { return deliveryDate; }
        public String getRoleYear() { return roleYear; }
        public String getRoleNumber() { return roleNumber; }
        public String getRoleTax() { return roleTax; }
        public String getRoleSanctions() { return roleSanctions; }
        public String getRoleInterest() { return roleInterest; }
        public String getRoleAmount() { return roleAmount; }
        public String getCollectedTax() { return collectedTax; }
        public String getCollectedSanctions() { return collectedSanctions; }
        public String getCollectedInterest() { return collectedInterest; }
        public String getCollectedAmount() { return collectedAmount; }
        public String getResidual() { return residual; }
        public String getPercentage() { return percentage; }
        public boolean hasPercentage() { return percentage != null; }
    }

    public static final class TotalsData {
        private final String roleTax;
        private final String roleSanctions;
        private final String roleInterest;
        private final String roleAmount;
        private final String collectedTax;
        private final String collectedSanctions;
        private final String collectedInterest;
        private final String collectedAmount;
        private final String residual;
        private final String averagePercentage;

        private TotalsData(
                String roleTax,
                String roleSanctions,
                String roleInterest,
                String roleAmount,
                String collectedTax,
                String collectedSanctions,
                String collectedInterest,
                String collectedAmount,
                String residual,
                String averagePercentage) {
            this.roleTax = roleTax;
            this.roleSanctions = roleSanctions;
            this.roleInterest = roleInterest;
            this.roleAmount = roleAmount;
            this.collectedTax = collectedTax;
            this.collectedSanctions = collectedSanctions;
            this.collectedInterest = collectedInterest;
            this.collectedAmount = collectedAmount;
            this.residual = residual;
            this.averagePercentage = averagePercentage;
        }

        private static TotalsData zero() {
            return new TotalsData(
                    "0,00", "0,00", "0,00", "0,00",
                    "0,00", "0,00", "0,00", "0,00",
                    "0,00", null);
        }

        public String getRoleTax() { return roleTax; }
        public String getRoleSanctions() { return roleSanctions; }
        public String getRoleInterest() { return roleInterest; }
        public String getRoleAmount() { return roleAmount; }
        public String getCollectedTax() { return collectedTax; }
        public String getCollectedSanctions() { return collectedSanctions; }
        public String getCollectedInterest() { return collectedInterest; }
        public String getCollectedAmount() { return collectedAmount; }
        public String getResidual() { return residual; }
        public String getAveragePercentage() { return averagePercentage; }
        public boolean hasAveragePercentage() { return averagePercentage != null; }
    }
}
