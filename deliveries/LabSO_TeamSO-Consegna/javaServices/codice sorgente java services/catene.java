package catene;
import java.math.*;
import java.math.BigInteger;
import java.math.BigDecimal;
import java.util.Random;
import jolie.runtime.JavaService;


public class catene extends JavaService
{

    private final static Random rand = new Random();
    public static int maxIterations=1000;

    private static BigInteger getRandomFermatBase(BigInteger n)
    {
        // Rejection method: ask for a random integer but reject it if it isn't
        // in the acceptable set.

        while (true)
        {

            final BigInteger a = new BigInteger (n.bitLength(), rand);

            // must have 1 <= a < n
            if (BigInteger.ONE.compareTo(a) <= 0 && a.compareTo(n) < 0)
            {
                return a;
            }
        }
    }

    public static Integer checkPrime(Integer inn )
    {
                                System.out.println("Bye bye!!!");

        BigInteger n = BigInteger.valueOf(inn.intValue());



        if (n.equals(BigInteger.ONE))
            return 0;

        for (int i = 0; i < maxIterations; i++)
        {
            BigInteger a = getRandomFermatBase(n);
            a = a.modPow(n.subtract(BigInteger.ONE), n);

            if (!a.equals(BigInteger.ONE)){
                return 0;
            }else{
                        System.out.println("remainder e':"+a);
            }
        }
        return 1;
    }


public static Integer getChainMember(int numero,int posizione){
        int primoaddendo = (int)Math.pow(2, posizione-1);
        primoaddendo=primoaddendo*numero;
        int secondoaddendo = (int)Math.pow(2, posizione-1);
        secondoaddendo=secondoaddendo-1;
        return primoaddendo+secondoaddendo;

}

public static Double checkChainD(Integer i){
        if(checkPrime(i)==0){
            return 0D;
        }else if(checkPrime(i)==1){
            return 1D+checkChainD(i*2+1);
        }else{  
            int tempbase=i-1;
            BigInteger base = BigInteger.valueOf(tempbase);
            BigInteger modulo= BigInteger.valueOf(i);
            BigDecimal big = new BigDecimal(modulo.modPow(base,modulo));
            BigDecimal bigreturn = big.divide(new BigDecimal(100D));

        
            return 0D+big.doubleValue();}
    }

public static Integer checkChain(Integer i){

        if(checkPrime(i)==0){
            return 0;
        }else if(checkPrime(i)==1){
            return 1+checkChain(i*2+1);
        }else{            
            System.out.println("Last number checked:+"+i);
            return 0;}
    }

    public static Integer acheck(Integer h){
        int temppos= checkChain(h);
        temppos=temppos+1;
        int cazzo= getChainMember(h,temppos);
        cazzo= cazzo+100;
        return 100;
    }

}






