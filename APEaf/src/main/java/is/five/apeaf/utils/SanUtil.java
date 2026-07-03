package is.five.apeaf.utils;

import org.apache.commons.text.StringEscapeUtils;

public class SanUtil {
	public static String sanitizeAlphanumeric(String input) {
	    return input.replaceAll("[^a-zA-Z0-9_\\s]", "");
	}
	
	public static String sanitizeFilename(String input) {
	    return input.replaceAll("[^a-zA-Z0-9._-]", "_");
	}
	
	public static String sanitizeHtml(String input) {
	    return StringEscapeUtils.escapeHtml4(input);
	}

	public static String sanitize(String input) {
	    if (input == null) return null;
	    return input
	        .replaceAll("<", "&lt;")
	        .replaceAll(">", "&gt;")
	        .replaceAll("\"", "&quot;")
	        .replaceAll("&", "&amp;")
	        .trim();
	}


}
