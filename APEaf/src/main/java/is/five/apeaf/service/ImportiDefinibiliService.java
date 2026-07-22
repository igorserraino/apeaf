package is.five.apeaf.service;

import is.five.apeaf.dao.AnnoFinanziarioDAO;
import is.five.apeaf.dao.InsTabRuoliDAO;
import is.five.apeaf.dao.TabParDAO;
import is.five.apeaf.dao.model.InsTabRuoli;
import is.five.apeaf.dao.model.TabPar;
import is.five.apeaf.dao.model.UserView;
import is.five.apeaf.service.TabRuoliPageService.GroupData;
import is.five.apeaf.utils.Utils;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

/**
 * Prepares all data displayed by importi-definibili.jsp.
 *
 * <p>The class does not depend on JSP/Servlet APIs, so the same result can be
 * reused by another page, a servlet or a controller.</p>
 */
public class ImportiDefinibiliService {

    private static final int IDX_ENTRATA = 0;
    private static final int IDX_ANNO_RUOLO = 3;
    private static final int IDX_NUMERO_RUOLO = 4;
    private static final int IDX_IMPOSTA_RUOLO = 5;
    private static final int IDX_SANZIONI_RUOLO = 6;
    private static final int IDX_INTERESSI_RUOLO = 7;
    private static final int IDX_IMPOSTA_RISCOSSA = 9;
    private static final int IDX_SANZIONI_RISCOSSE = 10;
    private static final int IDX_INTERESSI_RISCOSSI = 11;

    public PageData load(UserView user, String selectedYearId) {
        String selectedYear = findSelectedYear(selectedYearId);

        if (selectedYear.trim().isEmpty()) {
            return PageData.withoutSelectedYear();
        }

        // Retained because the original page loads these parameter lists.
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
                String entry = parsedRole.entry.isEmpty()
                        ? "ENTRATA NON DEFINITA"
                        : parsedRole.entry;

                List<ParsedRole> group = rolesByEntry.get(entry);
                if (group == null) {
                    group = new ArrayList<ParsedRole>();
                    rolesByEntry.put(entry, group);
                }
                group.add(parsedRole);
            }
        }

        DecimalFormat moneyFormat = new DecimalFormat(
                "#,##0.00", DecimalFormatSymbols.getInstance(Locale.ITALY));

        List<GroupData> groups = new ArrayList<GroupData>();
        BigDecimal globalTax = BigDecimal.ZERO;
        BigDecimal globalSanctions = BigDecimal.ZERO;
        BigDecimal globalInterest = BigDecimal.ZERO;
        BigDecimal globalTotal = BigDecimal.ZERO;

        for (Map.Entry<String, List<ParsedRole>> entry : rolesByEntry.entrySet()) {
            List<ParsedRole> groupRoles = entry.getValue();
            Collections.sort(groupRoles, new Comparator<ParsedRole>() {
                @Override
                public int compare(ParsedRole left, ParsedRole right) {
                    return Integer.compare(left.sortYear, right.sortYear);
                }
            });

            List<RowData> rows = new ArrayList<RowData>();
            BigDecimal groupTax = BigDecimal.ZERO;
            BigDecimal groupSanctions = BigDecimal.ZERO;
            BigDecimal groupInterest = BigDecimal.ZERO;
            BigDecimal groupTotal = BigDecimal.ZERO;

            for (ParsedRole role : groupRoles) {
                BigDecimal residualTax = role.tax.subtract(role.collectedTax);
                BigDecimal residualSanctions = role.sanctions.subtract(role.collectedSanctions);
                BigDecimal residualInterest = role.interest.subtract(role.collectedInterest);
                BigDecimal residualTotal = residualTax
                        .add(residualSanctions)
                        .add(residualInterest);

                groupTax = groupTax.add(residualTax);
                groupSanctions = groupSanctions.add(residualSanctions);
                groupInterest = groupInterest.add(residualInterest);
                groupTotal = groupTotal.add(residualTotal);

                rows.add(new RowData(
                        role.entry,
                        role.roleYear,
                        role.roleNumber,
                        moneyFormat.format(residualTax),
                        moneyFormat.format(residualSanctions),
                        moneyFormat.format(residualInterest),
                        moneyFormat.format(residualTotal)));
            }

            globalTax = globalTax.add(groupTax);
            globalSanctions = globalSanctions.add(groupSanctions);
            globalInterest = globalInterest.add(groupInterest);
            globalTotal = globalTotal.add(groupTotal);

            groups.add(new GroupData(
                    entry.getKey(),
                    rows,
                    moneyFormat.format(groupTax),
                    moneyFormat.format(groupSanctions),
                    moneyFormat.format(groupInterest),
                    moneyFormat.format(groupTotal)));
            
            Map<String, Integer> ordineEntrate = new HashMap<>();

            ordineEntrate.put("ICI", 0);
            ordineEntrate.put("TASI", 1);
            ordineEntrate.put("IMU", 2);
            ordineEntrate.put("TARI", 3);
            ordineEntrate.put("SANZIONI CDS", 4);

            groups.sort(
                Comparator
                    .comparingInt(
                        (GroupData group) -> ordineEntrate.getOrDefault(
                            group.getEntry().trim().toUpperCase(Locale.ROOT),
                            Integer.MAX_VALUE
                        )
                    )
                    .thenComparing(
                        GroupData::getEntry,
                        String.CASE_INSENSITIVE_ORDER
                    )
            );
        }

        return new PageData(
                selectedYear,
                groups,
                moneyFormat.format(globalTax),
                moneyFormat.format(globalSanctions),
                moneyFormat.format(globalInterest),
                moneyFormat.format(globalTotal),
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
            // Same behavior as the original JSP: an invalid year is treated as absent.
            return "";
        }
    }

    private ParsedRole parseRole(InsTabRuoli role) {
        String csv = role.getValues() == null ? "" : role.getValues();
        String[] values = csv.split(";", -1);

        return new ParsedRole(
                csvValue(values, IDX_ENTRATA),
                csvValue(values, IDX_ANNO_RUOLO),
                csvValue(values, IDX_NUMERO_RUOLO),
                csvInteger(values, IDX_ANNO_RUOLO),
                csvDecimal(values, IDX_IMPOSTA_RUOLO),
                csvDecimal(values, IDX_SANZIONI_RUOLO),
                csvDecimal(values, IDX_INTERESSI_RUOLO),
                csvDecimal(values, IDX_IMPOSTA_RISCOSSA),
                csvDecimal(values, IDX_SANZIONI_RISCOSSE),
                csvDecimal(values, IDX_INTERESSI_RISCOSSI));
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

    private static final class ParsedRole {
        private final String entry;
        private final String roleYear;
        private final String roleNumber;
        private final int sortYear;
        private final BigDecimal tax;
        private final BigDecimal sanctions;
        private final BigDecimal interest;
        private final BigDecimal collectedTax;
        private final BigDecimal collectedSanctions;
        private final BigDecimal collectedInterest;

        private ParsedRole(
                String entry,
                String roleYear,
                String roleNumber,
                int sortYear,
                BigDecimal tax,
                BigDecimal sanctions,
                BigDecimal interest,
                BigDecimal collectedTax,
                BigDecimal collectedSanctions,
                BigDecimal collectedInterest) {
            this.entry = entry;
            this.roleYear = roleYear;
            this.roleNumber = roleNumber;
            this.sortYear = sortYear;
            this.tax = tax;
            this.sanctions = sanctions;
            this.interest = interest;
            this.collectedTax = collectedTax;
            this.collectedSanctions = collectedSanctions;
            this.collectedInterest = collectedInterest;
        }
    }

    public static final class PageData {
        private final String selectedYear;
        private final List<GroupData> groups;
        private final String totalResidualTax;
        private final String totalResidualSanctions;
        private final String totalResidualInterest;
        private final String totalRoleAmount;
        private final List<TabPar> sanctionValues;
        private final List<TabPar> interestValues;

        private PageData(
                String selectedYear,
                List<GroupData> groups,
                String totalResidualTax,
                String totalResidualSanctions,
                String totalResidualInterest,
                String totalRoleAmount,
                List<TabPar> sanctionValues,
                List<TabPar> interestValues) {
            this.selectedYear = selectedYear;
            this.groups = Collections.unmodifiableList(new ArrayList<GroupData>(groups));
            this.totalResidualTax = totalResidualTax;
            this.totalResidualSanctions = totalResidualSanctions;
            this.totalResidualInterest = totalResidualInterest;
            this.totalRoleAmount = totalRoleAmount;
            this.sanctionValues = sanctionValues;
            this.interestValues = interestValues;
        }

        private static PageData withoutSelectedYear() {
            return new PageData(
                    "", Collections.<GroupData>emptyList(),
                    "0,00", "0,00", "0,00", "0,00",
                    Collections.<TabPar>emptyList(),
                    Collections.<TabPar>emptyList());
        }

        public boolean hasSelectedYear() { return !selectedYear.trim().isEmpty(); }
        public String getSelectedYear() { return selectedYear; }
        public List<GroupData> getGroups() { return groups; }
        public boolean hasGroups() { return !groups.isEmpty(); }
        public String getTotalResidualTax() { return totalResidualTax; }
        public String getTotalResidualSanctions() { return totalResidualSanctions; }
        public String getTotalResidualInterest() { return totalResidualInterest; }
        public String getTotalRoleAmount() { return totalRoleAmount; }
        public List<TabPar> getSanctionValues() { return sanctionValues; }
        public List<TabPar> getInterestValues() { return interestValues; }
    }

    public static final class GroupData {
        private final String entry;
        private final List<RowData> rows;
        private final String totalResidualTax;
        private final String totalResidualSanctions;
        private final String totalResidualInterest;
        private final String totalRoleAmount;

        private GroupData(
                String entry,
                List<RowData> rows,
                String totalResidualTax,
                String totalResidualSanctions,
                String totalResidualInterest,
                String totalRoleAmount) {
            this.entry = entry;
            this.rows = Collections.unmodifiableList(new ArrayList<RowData>(rows));
            this.totalResidualTax = totalResidualTax;
            this.totalResidualSanctions = totalResidualSanctions;
            this.totalResidualInterest = totalResidualInterest;
            this.totalRoleAmount = totalRoleAmount;
        }

        public String getEntry() { return entry; }
        public List<RowData> getRows() { return rows; }
        public String getTotalResidualTax() { return totalResidualTax; }
        public String getTotalResidualSanctions() { return totalResidualSanctions; }
        public BigDecimal getTotalResidualSanctionsBD() { return Utils.toBigDecimal(totalResidualSanctions); }

        public String getTotalResidualInterest() { return totalResidualInterest; }
        public BigDecimal getTotalResidualInterestBD() { return Utils.toBigDecimal(totalResidualInterest); }

        public String getTotalRoleAmount() { return totalRoleAmount; }
    }

    public static final class RowData {
        private final String entry;
        private final String roleYear;
        private final String roleNumber;
        private final String residualTax;
        private final String residualSanctions;
        private final String residualInterest;
        private final String total;

        private RowData(
                String entry,
                String roleYear,
                String roleNumber,
                String residualTax,
                String residualSanctions,
                String residualInterest,
                String total) {
            this.entry = entry;
            this.roleYear = roleYear;
            this.roleNumber = roleNumber;
            this.residualTax = residualTax;
            this.residualSanctions = residualSanctions;
            this.residualInterest = residualInterest;
            this.total = total;
        }

        public String getEntry() { return entry; }
        public String getRoleYear() { return roleYear; }
        public String getRoleNumber() { return roleNumber; }
        public String getResidualTax() { return residualTax; }
        public String getResidualSanctions() { return residualSanctions; }
        public String getResidualInterest() { return residualInterest; }
        public String getTotal() { return total; }
    }
}
