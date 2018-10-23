include "time.iol"
include "semaphore_utils.iol"
include "interface.iol"
include "message_digest.iol"
include "console.iol"

outputPort OutPort {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

inputPort InPort {
	Location: "socket://localhost:9001/"
	Protocol: http
	Interfaces: JollarInterface
}

init{
	println@Console( "Connessione stabilita con: \"socket://localhost:9000\" " )();
	publicKey = "a";
	privateKey = "aa";
	walletAmount = 0;
	with (info) {
		.publicKey = publicKey;
		.location = "socket://localhost:9001";
		.protocol = "http";
		.sid = "0"
	}
}

main{
	aggiungiPeer@OutPort(info)(msg);
	println@Console("Nodo aggiunto con successo:\n" + info.location + " " +
	 "Prot:" + info.protocol + " Wallet: " + info.wallet)();
    //se sono il primo nodo...
	if (msg.i == 1) {
		println@Console( "sono il primo nodo, creo il primo blocco" )();
		//receiveTime riceve il tempo in millisec inviato dal server
		receiveTime@OutPort()( result );
		//stampo su console il valore ottenuto
		println@Console("Time ms: " + result)();

     	//creo il primo blocco
		with( transazione ){
			.nodeSeller.publicKey = publicKey; // sarebbe il wallet !?
			.nodeSeller.wallet.amount = 1000000;
			.nodeBuyer.publicKey = publicKey;
			.nodeBuyer.walletAmount += 6; // ammontare jollar al block corrente
			.jollar = 6
		}|
		md5@MessageDigest("0")(hash_start);
		with(msg.blockchain.block) {
			.previousBlockHash =  hash_start;
        	.difficulty = 5; //numeri di zeri da calcolare
        	.transaction << transazione;
        	.timeStamp = result
        };
   		// Da client a server
        invioBlockchain@OutPort(msg);
        invioPeer@OutPort()(listaPeer) //;
        for( i = 0, i < #listaPeer, i++){
        	isValidChain@listaPeer.nodo[i]()
        }
    }
    //se non sono il primo nodo
    else {
    	downloadBlockchain@OutPort(msg)(blockchain);
    	println@Console( "ho scaricato la blockchain ")()
    }
}