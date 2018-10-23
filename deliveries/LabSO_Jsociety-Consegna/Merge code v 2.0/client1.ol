include "time.iol"
include "semaphore_utils.iol"
include "interface.iol"
include "message_digest.iol"
include "console.iol"
//interfaccia per il servizio di crittografia
include "MyUtilInterface.iol"

outputPort MyKeyUtil {
	Interfaces: MyUtilInterface
}
embedded {
	Java: "myUtil.MyKeyUtil" in MyKeyUtil
}

outputPort JollarCore {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

inputPort InPort {
	Location: "socket://localhost:9001/"
	Protocol: http
	Interfaces: JollarInterface
}

outputPort portaBroadcast {
	Interfaces: JollarInterface
}

init {
	println@Console( "Connessione stabilita con: \"socket://localhost:9000\" " )();
	generaChiavi@MyKeyUtil()(chiavi);
	publicKey = chiavi.publicKey;
	privateKey = chiavi.privateKey;
	walletAmount = 0;
	with (info) {
		.publicKey = publicKey;
		.location = "socket://localhost:9001";
		.protocol = "http"
	//	.sid = "0"
	}
}

main
{
	aggiungiPeer@JollarCore(info)(indexMsg);
	println@Console("Nodo aggiunto con successo:\nLoc: " + info.location +
	 "\nProt:" + info.protocol + "\nWallet: " + info.wallet + "\nPubK: " + info.publicKey)();
  sidMsg.sid = indexMsg.sid;

	//se sono il primo nodo...
	if (indexMsg.index == 1) {
		global.sem_peer.name = "sem_peer";
		println@Console( "sono il primo nodo, creo il primo blocco" )();

		println@Console( "il mio sid è \t" + sidMsg.sid)();
		//receiveTime riceve il tempo in millisec inviato dal server
		receiveTime@JollarCore(sidMsg)( result );
		//stampo su console il valore ottenuto
		println@Console("Time ms: " + result)();

    //creo il primo blocco
		//(l'ho messo in una procedura perché era lungo)
		creazionePrimoBlocco;
		// Da client a server
  	invioBlockchain@JollarCore(blockchainMsg);

		//Resto in attesa che si connettano tutti i peer
		println@Console( "sono il nodo 1 e sono in attesa di n nodi connessi" )();
		inAttesaDiTuttiIPeer();
  	invioPeer@JollarCore(sidMsg)(listaPeer);
		println@Console( "la lista dei peer contiene nodi n." + #listaPeer.nodo )();
		for ( i = 0, i < #listaPeer.nodo, i++) {
			if (i != indexMsg.index) {
				//binding dinamico:
				//ad ogni iterazione cambio location e protocol
				//della portaBroadcast
				portaBroadcast.location = listaPeer.nodo[i].location;
				portaBroadcast.protocol = listaPeer.nodo[i].protocol;
				println@Console( "invio il nuovo blocco a\t" + i + " -- " +
					portaBroadcast.location + " " + portaBroadcast.protocol )();
				// da terminare
				bloccoMsg.sid = sidMsg.sid;
				bloccoMsg.b = "Ciao dovrei essere un blocco!";
				invioBlocco@portaBroadcast(bloccoMsg)
			}
		}
  	/*  for( i = 0, i < #listaPeer, i++){
  		isValidChain@listaPeer.nodo[i]()
    } */

	}
	//se non sono il primo nodo
	else {
		downloadBlockchain@JollarCore(sidMsg)(blockchain);
		println@Console( "**ho scaricato la blockchain con blocchi n. " + #blockchain.block)();
		println@Console( "**Aspetto che mi arrivi qualche blocco" )();
		invioBlocco(b);
		println@Console( "ho ricevuto il blocco : " + b.b )()
	}
}

define creazionePrimoBlocco
{
	with (nS) {
		.publicKey = publicKey; //in realtà ci andrebbe la pubKey del Server
		.walletAmount = 1000000 //valore simbolico
	};
	with (nB) {
		.publicKey = publicKey;
		.walletAmount = 6
	};
	with( transazione ){
	.nodeSeller << nS;
	.nodeBuyer << nB;
	.jollar = 6
	};
	md5@MessageDigest("0")(hash_start);
	with(blockchainMsg.blockchain.block) {
		.previousBlockHash = hash_start;
		.difficulty = 5; //numeri di zeri da calcolare
		.transaction << transazione;
		.timeStamp = result
	}
	|
	blockchainMsg.sid = sidMsg.sid
}
