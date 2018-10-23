include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "InterfaceTime2.iol"
include "file.iol"
include "math.iol"
include "TransInterface.iol"
include "interfaceChiavi.iol"


inputPort chiaviPort {
	Location: "socket://localhost:8009"
	Protocol: sodep
	Interfaces: TransInterface
}
main{
	     
		start=true;
		println@Console("Sto calcolando...")();
		while(start){
			go=true;
			while(go){
				random@Math()(result);
				p = int((result * (100)) + 1);
				random@Math()(result2);
				q = int((result2 * (100)) + 1);
				powReq.base=2;
				powReq.exponent=p-1;
				pow@Math(powReq)(r);
				m=r%p;
				powReq2.base=2;
				powReq2.exponent=q-1;
				pow@Math(powReq2)(r2);
				m2=r2%q;
				if(m==1 && m2==1){
					if (p>2 && q>2 ){
						go=false
					} 
				}
			};
			n=p*q;
			z=(p-1)*(q-1);
			run=true;
			while(run){
				t=0;
				random@Math()(result);
				e = int((result * (n-1)) + 1);
				for(i=1,i<=e,i++){
					x=e%i;
					y=z%i;
					if(x==y && x==1 || x!=y){
						t=1
					}else { 
						random@Math()(result);
						e = int((result * (n-1)) + 1);
						i=1
					};
					if(x==y && t==1){
						run=true;
						t=2
					};
					if(i==e && t==1){
						run=false
					}	
				}
			};
			
			run2=true;
			while(run2){
				t2=0;
				random@Math()(result);
				d = int((result * (n)) + 1);
				w=e*d;
				w2=w%z;
				if(w2==1){
					run2=false
				}else {
					random@Math()(result);
					d = int((result * (n)) + 1)   
				}
				
			};
			mess=9;
			powReq.base=mess;
			powReq.exponent=e;
			pow@Math(powReq)(result);
			c=result%n;
			powReq.base=c;
			powReq.exponent=d;
			pow@Math(powReq)(result2);
			mess2 =result2%n;
			if(mess==mess2 && e!=d && c!=mess ){
				println@Console("p: "+p+"   q: "+q+"   n: "+n+"   z: "+z+"   e: "+e+"   d: "+d)();
				println@Console("chiave pubblica: ("+n+","+e+")   chiave privata: ("+n+","+d+")")();
				println@Console("mess inviato: "+mess)();
				println@Console("mess criptato: "+c)();
				println@Console("mess decriptato: "+mess2)();
				start=false;
				chiavi.pubb= (n + e);
				chiavi.priv= (n + d)
			}	
		}
	}
