include "time.iol"
include "interface.iol"
include "console.iol"
include "converter.iol"
include "semaphore_utils.iol"

include "MyUtilInterface.iol"

outputPort MyKeyUtil {
	Interfaces: MyUtilInterface
}

embedded {
	Java: "myUtil.MyKeyUtil" in MyKeyUtil
}

inputPort JollarCore {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

outputPort CoreOutput{
	Interfaces: JollarInterface
}


//insieme di correlazione, contiene un id per "non fare confusione tra i client e behaviour"
// identifica sessione (session id) tra i vari client
cset {
	sid: IndexMessage.sid SidMessage.sid BlockMsg.sid
}

constants {
	NUMERO_MIN_PEER = 4
}
execution { concurrent }

init
{
	println@Console( "Server running" )();
	// per variabili ripetute, solo per inizializzare il blocco 0 dal server
	generaChiavi@MyKeyUtil()(chiavi);
	//inizializzazione della lista dei nodi
	with(global.listaPeer.nodo) {
		.publicKey = chiavi.publicKey;
		.location = "socket://localhost:9000";
		.protocol = "http"
	//	.sid = new
	};
	//inizializzazione dell'array wallet
	wallet = 6; //il nodo Core ha sei jollar
	global.rw_mutex.name = "rw_mutex";
	global.r_mutex.name = "r.mutex";
//	global.token.name = "token"; //questo semaforo va sistemato per bene
	release@SemaphoreUtils(global.r_mutex)()
}

main
{
	//invio il tempo al client che me lo ha richiesto
	aggiungiPeer(peer)(indexMsg) {
		//Reader-writer problem?
		//Qui writer! --> Togliere il synchronized
		synchronized( token_lista ) {
			i = #global.listaPeer.nodo;
			with(global.listaPeer.nodo[i]) {
				.publicKey = peer.publicKey;
				.location = peer.location;
				.protocol = peer.protocol
				// per creare un sid nuovo generato mai stato usato
		//		.sid = csets.sid = new
			};
			// result.i solo per inviare il numero blocco
			indexMsg.index = i;
			indexMsg.sid = csets.sid = new;
			println@Console( "index e' " + indexMsg.index )();
			//global.listaPeer.nodo[i].sid
		//	indexMsg.wallet << wallet;
			//se si sono connessi almeno N peer
			//allora il primo nodo inizia a fare le transazioni
		//	n =4 ; //per semplicità, n=2.. poi sarà n=4, n --> FINAL nodo = 2 sarebbe
			if (i == NUMERO_MIN_PEER) {
				CoreOutput.protocol = global.listaPeer.nodo[1].protocol;
				CoreOutput.location = global.listaPeer.nodo[1].location;
				println@Console( "** ci sono n peer, niente piu attesa" )();
				println@Console( "server output è: " + CoreOutput.protocol )();
				inAttesaDiTuttiIPeer@CoreOutput()
			}
		}
	}
	;
	{
		receiveTime(sidMsg)( millis ) {
			println@Console( "il sid ricevuto e' " + sid )();
			//interrogo Time per sapere i millisecondi di tempo attuale
			getCurrentTimeMillis@Time()( time );
			//stampo a quale client ho inviato il tempo
			println@Console("Current time: " + time)();
			millis = time
		}
/*		|
		acquisisciSemaforo(nomeSemaforo)() {
			acquire@SemaphoreUtils(global.(nomeSemaforo))()
		}
*/		|
		{
			//ricevo blockchain da client a server
			invioPrimoBlocco(bloccoMsg);
			global.blockchain.block << bloccoMsg.block;
			// incremento il semaforo solo dopo che è stato scritto il primo blocco
	  	// così i nodi successivi scaricheranno una blockchain non vuota
			release@SemaphoreUtils(global.rw_mutex)()

		}
		|
		//{
  		//è simile al problema reader-writer
		downloadBlockchain(sidMsg)(downloadMsg) {
			acquire@SemaphoreUtils(global.r_mutex)();
			global.read_count++;
			if (global.read_count == 1) {
				acquire@SemaphoreUtils(global.rw_mutex)()
			};
			release@SemaphoreUtils(global.r_mutex)();
  		//scarico la blockchain
			downloadMsg.blockchain << global.blockchain;
			downloadMsg.wallet << wallet;
			acquire@SemaphoreUtils(global.r_mutex)();
			global.read_count--;
			if (global.read_count == 0) {
				release@SemaphoreUtils(global.rw_mutex)()
		//		release@SemaphoreUtils(global.token)()
			};
			release@SemaphoreUtils(global.r_mutex)()
		}

		|
		while( true ) {
			invioPeer(sidMsg)(lista) {
				println@Console( "sto inviando la lista con nodi (server compreso) n. " +
					#global.listaPeer.nodo )();
				//anche qui potremmo usare il reader-writer.
				//qui i reader!
							//	acquire@SemaphoreUtils(global.token)();
				lista << global.listaPeer
			}
		}
		|
		{
			invioBlocco(bMsg);
			println@Console( "ho ricevuto un blocco" )()
			//qui ci va una convalida ecc simile a quella dei peer
		}
		|
		// TODO
		isValidChain(sidMsg)(risp){
			if(true){
				println@Console( "Block accepted, reward: 6 Jollar" )();
				risp = true //Attualmente il calcolo andrà sempre bene
			}
			else{
				for ( i = 0, i < #listaPeer.nodo, i++) {
					if(listaPeer.nodo[i].sid == sidMsg.sid)
						println@Console( "Nodo " + i + " warning, blocco rejected." )()
					else
						println@Console( "Nodo connesso non registrato." )();
					risp = false
				}
			}
		}
	}
}
