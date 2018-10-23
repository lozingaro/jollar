/********************************************************************
 * JavaService che offre le operation relative alla firma digitale,
 * in particolare la generazione della coppia di chiavi, la firma del
 * messaggio e la verifica della firma.
 ********************************************************************/

package myUtil;

import jolie.runtime.JavaService;
import jolie.runtime.Value;
import java.security.*;
import java.security.spec.*;
import java.util.*;

public class MyKeyUtil extends JavaService {

	/**
	 * Metodo che genera una coppia di chiavi usando l'algoritmo RSA
	 * @return un albero contenente una chiave pubblica e una privata
	 */
	public Value generaChiavi() {
		Value chiavi = Value.create();
		try {
			//creo un generatore di chiavi che usa l'algoritmo RSA
			KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
			kpg.initialize(1024);
			//genero una coppia di chiavi
			KeyPair kp = kpg.generateKeyPair();
			//aggiungo le chiavi come nodi dell'albero
			chiavi.getNewChild("publicKey").setValue(byteToString(kp.getPublic().getEncoded()));
			chiavi.getNewChild("privateKey").setValue(byteToString(kp.getPrivate().getEncoded()));
		}
		catch(Exception e) {
			System.out.println(e.getMessage());
		}
		return chiavi;
	}

	/**
	 * Metodo che permette di firmare un messaggio in chiaro usando
	 * l'algoritmo RSA.
	 * @param freq un albero contenente la chiave privata e il plaintext
	 * @return il messaggio cifrato
	 */
	public String firma(Value req) {
		String ciphertext = "";
		try {
			String privateKey = req.getFirstChild("privateKey").strValue();
			String plaintext = req.getFirstChild("plaintext").strValue();
			Signature sig = Signature.getInstance("SHA256withRSA");
			sig.initSign(stringToPrivKey(privateKey));
			sig.update(plaintext.getBytes());
			ciphertext = byteToString(sig.sign());
		}
		catch(Exception e) {
			System.out.println(e.getMessage());
		}
		return ciphertext;
	}

	/**
	 * Metodo che permette di verificare che il proprietario della chiave
	 * pubblica abbia firmato (con RSA) un messaggio uguale a quello in chiaro.
	 * Permette quindi di verificare l'autenticazione del mittente e l'integrità
	 * del messaggio.
	 * @param req un albero contenente la chiave pubblica, il plaintext e il ciphertext
	 * @return true/false se integrità e autenticazione sono verificate
	 */
	public Boolean verifica(Value req) {
		boolean verificato = false;
		try {
			String publicKey = req.getFirstChild("publicKey").strValue();
			String plaintext = req.getFirstChild("plaintext").strValue();
			String ciphertext = req.getFirstChild("ciphertext").strValue();
			Signature sig = Signature.getInstance("SHA256withRSA");
			sig.initVerify(stringToPubKey(publicKey));
			sig.update(plaintext.getBytes());
			verificato = sig.verify(stringToByte(ciphertext));
		}
		catch(Exception e) {
			System.out.println(e.getMessage());
		}
		return verificato;
	}

	/**
	 * Metodo che converte una chiave pubblica dal formato String a PublicKey.
	 * @param pubKey la chiave pubblica in String
	 * @return la chiave pubblica in PublicKey
	 */
	public PublicKey stringToPubKey(String publicKey) throws Exception {
		KeyFactory kf = KeyFactory.getInstance("RSA");
		return kf.generatePublic(new X509EncodedKeySpec(stringToByte(publicKey)));
	}

	/**
	 * Metodo che converte una chiave privata dal formato String a PrivateKey.
	 * @param stringKey la chiave privata in String
	 * @return la chiave privata in PrivateKey
	 */
	public PrivateKey stringToPrivKey(String privateKey) throws Exception {
		KeyFactory kf= KeyFactory.getInstance("RSA");
		return kf.generatePrivate(new PKCS8EncodedKeySpec(stringToByte(privateKey)));
	}

	/**
	 * Metodo che converte un array di byte in stringa
	 */
	public String byteToString(byte[] b) {
		return Base64.getEncoder().encodeToString(b);
	}

	/**
	 * Metodo che converte una stringa in un array di byte
	 */
	public byte[] stringToByte(String s) {
		return Base64.getDecoder().decode(s);
	}

}
