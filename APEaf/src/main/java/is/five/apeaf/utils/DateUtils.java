package is.five.apeaf.utils;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class DateUtils {
	public static String getCurrentTimestamp() {
		LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String formattedTimestamp = now.format(formatter);
		return formattedTimestamp;
	}
	
	public static String formatString(LocalDateTime date) {
        LocalDate dateTime = date.toLocalDate();
        String formatted = dateTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        
        return formatted;
	}
	
	public static long daysInterval(LocalDateTime start , LocalDateTime end) {

        // Convert to LocalDate to ignore time part
        long daysBetween = ChronoUnit.DAYS.between(start.toLocalDate(), end.toLocalDate());

        return daysBetween; 
    }
	
	public static Integer modeSingle(List<Integer> values) {
        if (values == null || values.isEmpty()) return null;

        Map<Integer, Integer> frequencyMap = new LinkedHashMap<>();
        for (Integer val : values) {
            frequencyMap.put(val, frequencyMap.getOrDefault(val, 0) + 1);
        }

        int maxFrequency = 0;
        Integer mode = null;

        for (Map.Entry<Integer, Integer> entry : frequencyMap.entrySet()) {
            int count = entry.getValue();
            if (count > maxFrequency) {
                maxFrequency = count;
                mode = entry.getKey();  // first value with highest frequency
            }
        }

        return (maxFrequency > 1) ? mode : null; // match Excel behavior: #N/A if no value repeats
    }
	
	 private static final DateTimeFormatter TIMESTAMP_FORMAT =

	            DateTimeFormatter.ofPattern(

	                    "dd-MMM-yyyy HH:mm:ss",

	                    Locale.ITALIAN);

	    public static String formatTimestamp(Timestamp timestamp) {

	        if (timestamp == null) {

	            return "";

	        }

	        return timestamp.toInstant()

	                .atZone(ZoneId.systemDefault())

	                .format(TIMESTAMP_FORMAT);

	    }
}
