package is.five.apeaf.utils;

import java.math.BigDecimal;

public class CSVUtils {

    private CSVUtils() {
    }

    public static String getValue(String csv, int index) {

        try {
            if (csv == null || csv.trim().isEmpty()) {
                return "0";
            }

            String[] values = csv.split(";", -1);

            if (index < 0 || index >= values.length) {
                return "0";
            }

            String value = values[index];

            if (value == null || value.trim().isEmpty()) {
                return "0";
            }

            return value.trim();

        } catch (Exception exception) {
            return "0";
        }
    }
    
    
    public static BigDecimal getDecimalValue(String csv, int index) {
        try {
            return new BigDecimal(getValue(csv, index));
        } catch (Exception exception) {
            return BigDecimal.ZERO;
        }
    }
}  