include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "InterfaceTime2.iol"
include "file.iol"
include "math.iol"
include "time.iol"
include "message_digest.iol"
include "Interfaceservpeer.iol"
include "TransInterface.iol"
include "interfaceChiavi.iol"
include "NetworkInterface.iol"

outputPort ClientD {
	Location: "socket://localhost:8004"
	Protocol: sodep
	Interfaces: InterfaceTime2,
	Interfaceservpeer
}

outputPort Blocksender {
	Location: "socket://localhost:8004"
	Protocol: sodep
	Interfaces: InterfaceTime2,
	Interfaceservpeer,
	TransInterface
}

outputPort Timeoutput {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: InterfaceTime2
}

outputPort Netview {
	Location: "socket://localhost:8010"
	Protocol: sodep
	Interfaces: NetworkInterface
}

main
{
	sleep@Time(22000)();
	sendString@Netview("Nodo D inizia il mining");
	println@Console("Location: "+ClientD.location )() ;
	LocationClientD=ClientD.location;
	undef( req );
	req.filename="LocationPorte";
	req.format="json";
	readFile@File(req)(resLoc);
	
	for(i=1,i<=resLoc,i++){
		if(LocationClientD!=resLoc.("figlio"+i)){
			println@Console("Location Connesse: " + resLoc.("figlio"+i))()
		}
	};
	println@Console("--------------------------------------------")();
	undef( req3 );
	req3.filename="Powini"; //contiene num. primi
	req3.format="json";
	readFile@File(req3)(res3);

	while(res3<8){ 
		//lettura wallet        
		undef( reqW );
		reqW.filename="WalletD";
		reqW.format="json";
		readFile@File(reqW)(wal); 

		res3=res3+1;
		req3.content<<res3;
		writeFile@File(req3)();
		
		for(i=res3,i<=res3,i++){
			undef( req2 );
			req2.filename="Pow";
			req2.format="json";
			readFile@File(req2)(res2);
			
			powReq.base=2;
			powReq.exponent=i-1;
			pow@Math(powReq)(result);
			p[i]=(result*(res2.p1))+(result)-1;
			
			powReq2.base=2;
			powReq2.exponent=p[i]-1;
			pow@Math(powReq2)(result2);
			m=result2%p[i];
			
			confp2=0;
			if(m==1 && p[i]>res2.primo){ 
				for(j=1,j<=resLoc,j++){
					location2=resLoc.("figlio"+j);
					ClientD.location=location2;
					controllo@ClientD(p[i])(confp); 
					confp2=confp2+confp;
					if(confp2==resLoc){
						println@Console("////////////////////////////////////////////////////////////")();
						wal=wal+6;
						reqW.content<<wal;
						writeFile@File(reqW)();
						
						getTime@Timeoutput()(t);
						println@Console(t)();
						println@Console("Numero proposto: "+p[i])();
						println@Console("CONFERMATO")();
						println@Console("Numero Primo attuale: " + p[i] + "    Numero primo precedente: "+res2.primo)();
						
						//invio al server A della restante parte della blockchain
						//e il server scriverà il blocco nella blockchain
						getCountBlock@Timeoutput("aggiungi count")(contblock);
						md5@MessageDigest( "hashing"+ res2.primo )( response );
						
						block.previousBlockHash=response;
						block.difficulty=p[i]/1;
						saveBlock@Blocksender(block);
					
						//cancellazione dei blocchi temporanei!
						primoPrec=res2.primo;
						res2.primo=p[i];
						res2=res2+1;
						println@Console("Lunghezza catena: " + res2)();

						res2.chain[res2]=res2.primo;
						
						res2.ind=i;
						req2.content<<res2;
						req.format="json";
						
						writeFile@File(req2)();
						sendString@Netview("NODO D"+"\n"+"Numero primo trovato "+ p[i] + "\n"  +"CONFERMATO" +"\n" + "Lunghezza catena: " +res2 + "\n" + "A scrive il blocco, reward 6 jollar. Totale Wallet: " + wal + "\n"+ "BLOCKCHAIN aggiornata")
					}
					else if (j==resLoc){
						println@Console("////////////////////////////////////////////////////////////")();
						println@Console("Numero proposto: "+p[i])();
						println@Console("RIFIUTATO")();
						println@Console("Numero primo precedente: "+res2.primo)()
						
					}
				};
				sleep@Time(15000)();
				ClientA.location= LocationClientA
			}
			else if(m!=1){
				println@Console("////////////////////////////////////////////////////////////")();
				println@Console("Numero proposto: "+p[i])();
				println@Console("RIFIUTATO")();
				println@Console("Numero primo precedente: "+res2.primo)()
			}
		}
	}
}
