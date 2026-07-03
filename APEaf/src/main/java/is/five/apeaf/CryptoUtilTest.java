package is.five.apeaf;

import javax.crypto.SecretKey;

public class CryptoUtilTest {

	public static void main(String[] args) {

		try {
			SecretKey key = CryptoUtil.getKeyFromString("BH5QFI2Dc+yaKbBlRx9zdysLIaLlLyJVAppXxnxAecE=");

			String encryptedPassword = CryptoUtil.encrypt("abc", key);
			System.out.println(encryptedPassword);
			System.out.println(CryptoUtil.decrypt(encryptedPassword, key));
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		

	}

}
