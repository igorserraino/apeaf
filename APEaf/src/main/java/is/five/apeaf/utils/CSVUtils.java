package is.five.apeaf.utils;

public class CSVUtils {

    private CSVUtils() {
    }

    public static String getValue(String csv, int index) {

        if (csv == null || csv.isEmpty()) {
            return "";
        }

        String[] values = csv.split(";", -1); // keep empty fields

        if (index < 0 || index >= values.length) {
            return "";
        }

        return values[index].trim();
    } 
}  