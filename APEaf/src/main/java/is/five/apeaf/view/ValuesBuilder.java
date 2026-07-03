package is.five.apeaf.view;

import is.five.apeaf.utils.Utils;

public class ValuesBuilder {
	
	private static int MAX = 50;
	
	
	public static String[] getValues(String values) {
		
		if (values == null ) {
			String[] temp = new String[MAX];
			for (int i=0; i<MAX; i++) {
				temp[i] = "";
			}
			
			return temp;
		} 
		
		try {
		
		String[] toGo = values.split(Utils.FIELD_SEP, -1);
		if (toGo==null) {
			String[] temp = new String[MAX];
			for (int i=0; i<MAX; i++) {
				temp[i] = "";
			}
			
			return temp;
		} else return toGo;
		} 
		catch (Exception exc) {
			String[] temp = new String[MAX];
			for (int i=0; i<MAX; i++) {
				temp[i] = "";
			}
			
			return temp;
		}
		
	}
	
		
	

}
