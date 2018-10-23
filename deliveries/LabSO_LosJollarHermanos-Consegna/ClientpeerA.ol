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

outputPort ClientA {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces: InterfaceTime2,
	Interfaceservpeer
}

outputPort Blocksender {
	Location: "socket://localhost:8001"
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
	//sleeptime per simulare una maggiore difficoltà per il calcolo dei numeri primi, 
	//in modo tale da effettuare transazioni tra la creazione di un blocco e un altro
	sleep@Time(9000)();
	//invio al network Visualizer stringhe di info
	sendString@Netview("Nodo A inizia il mining");
	//a scopo informativo stampa a cmd la location del client A
	println@Console("Location: "+ClientA.location )() ;
	LocationClientA=ClientA.location;
	//lettura file locationPorte, in modo tale che il nodo A possa conoscere gli altri nodi connessi 
	undef( req );
	req.filename="LocationPorte";
	req.format="json";
	readFile@File(req)(resLoc);
	
	for(i=1,i<=resLoc,i++){
		if(LocationClientA!=resLoc.("figlio"+i)){
			println@Console("Location Connesse: " + resLoc.("figlio"+i))()
		}
	};
	println@Console("--------------------------------------------")();
	undef( req3 );
	//Il contenuto del file Powini permette di capire la posizione del numero da andare a calcolare 
	//evitando di calcolare ogni volta tutti i valori della catena, riducendo il costo computazionale
	req3.filename="Powini";
	req3.format="json";
	readFile@File(req3)(res3);

	while(res3<8){ 
		//lettura wallet        
		undef( reqW );
		reqW.filename="WalletA";
		reqW.format="json";
		readFile@File(reqW)(wal); 
		res3=res3+1;
		req3.content<<res3;
		writeFile@File(req3)();
		
		//inizio processo di proof of work
		//controllo singolo elemento alla posizione res3
		for(i=res3,i<=res3,i++){			
			undef( req2 );
			req2.filename="Pow";
			req2.format="json";
			readFile@File(req2)(res2);
			
			//calcolo del numero pseudoprimo attraverso la formula di Cunningham del 1° tipo
			powReq.base=2;
			powReq.exponent=i-1;
			pow@Math(powReq)(result);
			p[i]=(result*(res2.p1))+(result)-1;
			
			//il nodo fa un primo controllo per verificare che il numero sia primo
			//attraverso il teorema di fermat
			powReq2.base=2;
			powReq2.exponent=p[i]-1;
			pow@Math(powReq2)(result2);
			m=result2%p[i];
			
			confp2=0;
			//se al controllo iniziale il numero risulta primo ed anche maggiore del precedente primo trovato allora:
			if(m==1 && p[i]>res2.primo){ 
				//invio agli altri nodi connessi una richiesta di verifica con controllo()()
				for(j=1,j<=resLoc,j++){
					//modifico location per comunicare con tutti gli altri server
					location2=resLoc.("figlio"+j);
					ClientA.location=location2;
					//invio dinamico del numero primo per il controllo da parte dei server
					controllo@ClientA(p[i])(confp); 
					//i nodi connessi inviano il resto ottenuto con fermat, se primo resto=1
					confp2=confp2+confp;
					//se somma dei resti (confp2) = nodi connessi allora:
					if(confp2==resLoc){
						//
						println@Console("////////////////////////////////////////////////////////////")();
						//reward 6 jollar
						wal=wal+6;
						reqW.content<<wal;
						writeFile@File(reqW)();
						//richiesta tempo al timestamp
						getTime@Timeoutput()(t);
						println@Console(t)();
						//stampa di info 
						println@Console("Numero proposto: "+p[i])();
						println@Console("CONFERMATO")();
						println@Console("Numero Primo attuale: " + p[i] + "    Numero primo precedente: "+res2.primo)();
						
						getCountBlock@Timeoutput("aggiungi count")(contblock);

						//hash del blocco precedente per blockchain
						md5@MessageDigest( "hashing"+ res2.primo )( response );
						block.previousBlockHash=response;
						block.difficulty=p[i]/1;
						//invio alla parte server della restante parte della blockchain (hash e difficulty)
						//insieme alle transazioni per quel blocco formeranno il nuovo blocco
						saveBlock@Blocksender(block);

						//Scrittura valori proof of work, ossia:
						//il numero primo trovato 
						primoPrec=res2.primo;
						//numero primo precedente
						res2.primo=p[i]; 
						//lunghezza catena 
						res2=res2+1;
						println@Console("Lunghezza catena: " + res2)();

						//catena vera e propria con i numeri primi
						res2.chain[res2]=res2.primo;
						//salvo l' albero della POW nel file POW
						req2.content<<res2;
						req.format="json";
						writeFile@File(req2)();
						//stampa di info Network Visualizer
						sendString@Netview("NODO A"+"\n"+"Numero primo trovato "+ p[i] + "\n"  +"CONFERMATO" +"\n" + "Lunghezza catena: " +res2 + "\n" + "A scrive il blocco, reward 6 jollar. Totale Wallet: " + wal + "\n"+ "BLOCKCHAIN aggiornata")
						
					}
					//rifiuto del primo nel caso i server non confermino il numero
					else if (j==resLoc){
						println@Console("////////////////////////////////////////////////////////////")();
						println@Console("Numero proposto: "+p[i])();
						println@Console("RIFIUTATO")();
						println@Console("Numero primo precedente: "+res2.primo)()
					}
				};
				
				sleep@Time(15000)();
				//reset della location del client
				ClientA.location= LocationClientA
			}
			//rifiuto del primo nel test iniziale di autoverifica
			else if(m!=1){
				println@Console("////////////////////////////////////////////////////////////")();
				println@Console("Numero proposto: "+p[i])();
				println@Console("RIFIUTATO")();
				println@Console("Numero primo precedente: "+res2.primo)()
			}
		}
	}
}
