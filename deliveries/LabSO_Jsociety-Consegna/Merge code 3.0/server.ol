include "time.iol"
include "interface.iol"
include "console.iol"
include "converter.iol"
include "semaphore_utils.iol"
include "math.iol"
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

outputPort ServerOutput{
//	Location: "socket://localhost:/"
//	Protocol: http
	Interfaces: JollarInterface
}


//insieme di correlazione, contiene un id per "non fare confusione tra i client e behaviour"
// identifica sessione (session id) tra i vari client
cset {
	sid: IndexMessage.sid BlockchainMessage.sid SidMessage.sid BMsg.sid
}

execution { concurrent }

init
{
	println@Console( "Server running" )();
	// per variabili ripetute, solo per inizializzare il blocco 0 dal server
	generaChiavi@MyKeyUtil()(chiavi);
	with(global.listaPeer.nodo) {
		.publicKey = chiavi.publicKey;
		.location = "socket://localhost:9000";
		.protocol = "http";
		.sid = new
	};
	global.rw_mutex.name = "rw_mutex";
	global.r_mutex.name = "r.mutex";
	global.sem_4peer = "sem_4peer";
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
			indexMsg.sid = csets.sid = new; //global.listaPeer.nodo[i].sid
			//se si sono connessi almeno N peer
			//allora il primo nodo inizia a fare le transazioni
			n = 2; //per semplicità, n=2.. poi sarà n=4, n --> FINAL nodo = 2 sarebbe
			if (i == n) {
				ServerOutput.protocol = global.listaPeer.nodo[1].protocol;
				ServerOutput.location = global.listaPeer.nodo[1].location;
				inAttesaDiTuttiIPeer@ServerOutput()
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
		|
		acquisisciSemaforo(nomeSemaforo)() {
			acquire@SemaphoreUtils(global.(nomeSemaforo))()
		}
		|
		{
			//ricevo blockchain da client a server
			invioBlockchain(blockchainMsg);
			global.blockchain << blockchainMsg.blockchain;
  		// incremento il semaforo solo dopo che è stato scritto il primo blocco
  		// così i nodi successivi scaricheranno una blockchain non vuota
			release@SemaphoreUtils(global.rw_mutex)()
		}
		|
  		//è simile al problema reader-writer
		downloadBlockchain(sidMsg)(bc) {
			acquire@SemaphoreUtils(global.r_mutex)();
			global.read_count++;
			if (global.read_count == 1) {
				acquire@SemaphoreUtils(global.rw_mutex)()
			};
			release@SemaphoreUtils(global.r_mutex)();
  		//scarico la blockchain
			bc << global.blockchain;
			acquire@SemaphoreUtils(global.r_mutex)();
			global.read_count--;
			if (global.read_count == 0) {
				release@SemaphoreUtils(global.rw_mutex)()
		//		release@SemaphoreUtils(global.token)()
			};
			release@SemaphoreUtils(global.r_mutex)()
		}

		|
		invioPeer(sidMsg)(lista) {
			println@Console( "sto inviando la lista con nodi (server compreso) n. " +
				#global.listaPeer.nodo )();
			//anche qui potremmo usare il reader-writer.
			//qui i reader!
						//	acquire@SemaphoreUtils(global.token)();
			lista << global.listaPeer
		}
		|
		{
			invioBlocco(b);
			println@Console( "ho ricevuto il blocco:\t" + b.b )()
		}
		|
		// TODO
		isValidChain(BMsg)(risp){
			// controllo se il nodo è gia stato registrato
			for ( i = 0, i < #global.listaPeer.nodo, i++){
				// se trovo il sid del nodo tra quelli connessi proseguo
				if(listaPeer.nodo[i].sid == BMsg.sid){
					println@Console( "Nodo " + i + " trovato" )();
					// uso funzione math pow
					op.base = 2;
					op.exponent = BMsg.b - 1;
					pow@Math(op)(potenza);
					// calcoli per la validazione del numero primo trovato
					tempOp = potenza / BMsg.b;
					tempTronc = tempOp * BMsg.b;

					// se è un numero primo ( = 1 ), allora..
					if(tempOp - tempTronc == 1){
						println@Console( "Block accepted, reward: 6 Jollar" )();
						risp = true;
						i = #global.listaPeer.nodo -1
					}
					else{
						println@Console( "Nodo " + i + " warning, blocco rejected." )();
						risp = false
					}
				}
				else{
					println@Console( "Nodo " + i + " non corrisponde" )()
				}
			}
		}
	}
}
