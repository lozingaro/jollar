include "time.iol"
include "console.iol"
include "InterfaceTime2.iol"
include "file.iol"
include "TransInterface.iol"

execution { concurrent }

inputPort In {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: InterfaceTime2
}

outputPort Out {
	Protocol:  sodep
	Interfaces: TransInterface 
}

init{
	//contatore che indica transazioni avvenute
	global.contatoreTran=0;
	//contatore che indica il numero di blocchi presenti nella chain
	contBlockchain=0;

	//cancellazione iniziale dei file per il riavvio del progetto
	delete@File("Pow")();
	delete@File("Powini")();
	delete@File("Blockchain")();
	delete@File("TransazioniA")();
	delete@File("TransazioniB")();
	delete@File("TransazioniC")();
	delete@File("TransazioniD")();
	delete@File("WalletA")();
	delete@File("WalletB")();
	delete@File("WalletC")();
	delete@File("WalletD")();
	
	//inizializzazioni valori per proof of work e hash
	c=1;
	n=1;
	n.p1=2;
	n.primo=2;       
	n.chain[1]=2;
	n.hash[1]="null";
	// creazione dei file contenenti i numeri primi (Pow) e un file d'appoggio (powini)
	req.filename="Pow";
	req.content<<n;
	req.format="json";
	
	req2.filename="Powini";
	req2.content<<c;
	req2.format="json";

	writeFile@File(req)();
	writeFile@File(req2)()
	
}

main
{   
	//metodo per richiesta tempo
	[getTime(void)(block.timestamp){
		getCurrentTimeMillis@Time()(millis);
		block.timestamp=millis
	}]
	//metodo per la scrittura del file LocationPorte contenente tutti i peer
	//iscritti alla rete
	[getLocation(s)]{
  		if( global.contatore>=2 ){
  			undef( req );
  			req.filename="LocationPorte";
  			req.format="json";
  			readFile@File(req)(res);
  			res=global.contatore;
  			res.("figlio"+global.contatore)=s;
  			println@Console("Server connessi: ")();
  			for(i=1,i<=global.contatore,i++){
  				//stampo a video nel cmd del timestamp le socket dei nodi connessi
  				println@Console(i+"figlio: " + res.("figlio"+i))()
  			};
            req.content<<res;
            writeFile@File(req)()
        }
        else{
            delete@File("LocationPorte.json")();
        	albero=global.contatore;
        	albero.("figlio"+global.contatore)=s;
        	println@Console("figlio: " + albero.("figlio"+global.contatore))();
        	//per ogni nodo che si connette viene inserita la rispettiva socket nel file
  			req.filename="LocationPorte";
            req.content<<albero;
            req.format="json";
            writeFile@File(req)()
            
        }
    }
    
  	//Contatore dei peer
  	[count(a)]{ 
  		global.contatore=global.contatore+1
  	}
  	//incremento contatore blockchain quando viene minato blocco
  	[getCountBlock(flag)(contatore){
  		global.contBlockchain=global.contBlockchain+1;
  		contatore=global.contBlockchain;
  		println@Console(global.contBlockchain)()
  	}]
}