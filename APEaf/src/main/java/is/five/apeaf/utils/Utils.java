package is.five.apeaf.utils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.time.LocalDate;


public class Utils {
	
	public static String FIELD_SEP = ";";
	public static String FIELD_PREFIX = "val_";
	
	
	public static String getCSVValueFromString(String csvData, int row, int col) {
        // Split the CSV data into rows using a newline as the delimiter
        String[] rows = csvData.split("\n");

        // Check if the requested row exists
        if (row >= 0 && row < rows.length) {
            // Split the specific row into columns using commas as the delimiter
            String[] columns = rows[row].split(FIELD_SEP);

            // Check if the requested column exists in the row
            if (col >= 0 && col < columns.length) {
                return columns[col].trim();  // Trim any extra whitespace
            }
        }
        return null;  // Return null if the row or column doesn't exist
    }
	public static String readSSOResourceFile() {
		InputStream inputStream = Utils.class.getClassLoader().getResourceAsStream("sso_");

        if (inputStream != null) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    return line;
                }
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        } else {
            System.out.println("File not found!");
            return null;
        }
		return null;
	}

	public static String addYears(String date, String years) {
		
		try {
			int years_ = Integer.parseInt(years);
		    LocalDate d = LocalDate.parse(date);
		    return d.plusYears(years_).toString();
		    
			} catch (Exception exc) {
				return "n.d.";
			}

	}
}
