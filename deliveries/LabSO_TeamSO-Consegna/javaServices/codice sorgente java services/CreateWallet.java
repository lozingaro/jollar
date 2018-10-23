package wallet;
import java.util.Random;
import jolie.runtime.JavaService;
import java.io.*;
import java.security.*;
import java.security.spec.*;


public class CreateWallet extends JavaService
{
public byte[] res;
    public String CreateWall(String filename)
    {

        if (filename!=null)
        {
        try{
        	KeyPairGenerator keyGen = KeyPairGenerator.getInstance("DSA", "SUN");
            SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
            keyGen.initialize(1024, random);
            KeyPair pair = keyGen.generateKeyPair();

            //salva private key

            PrivateKey priv = pair.getPrivate();
			byte[] privakey = priv.getEncoded();
			
			while(checkIfExistsFile(filename)!=filename){

			filename=checkIfExistsFile(filename);			}
			FileOutputStream keyfout = new FileOutputStream(filename+"privk");


			

			// se il filename non esiste, allora write..
			//altrimenti NON devi sovrascrivere !
			//trova un altra soluzione..
			//come ad esempio, stesso nome + "bak"
			keyfout.write(privakey);
			keyfout.close();
            System.out.println("Private key File created yu and saved in : "+filename+"privk");


            //salva public key

            PublicKey pub = pair.getPublic();
            byte[] pubakey = pub.getEncoded();
			FileOutputStream keypfout = new FileOutputStream(filename+"publick");
			keypfout.write(pubakey);
			keypfout.close();
			 System.out.println("Public key File created yu and saved in : "+filename+"publick");

			 

        }catch( Exception e ){
            e.printStackTrace();
            return "0";
        }

        }else{
        	System.out.println("Insert filename");
        	return "0";
        }
        return filename;
    }

		public String checkIfExistsFile(String nomefile){
				if(new File(nomefile+"privk").exists() ) {return nomefile+"2";}
				else{
					return nomefile;
				}			
			}

}