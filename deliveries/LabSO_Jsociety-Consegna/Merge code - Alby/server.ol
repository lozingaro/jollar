include "time.iol"
include "interface.iol"
include "console.iol"
include "converter.iol"
include "semaphore_utils.iol"

inputPort ServerInput {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

outputPort ServerOutput{
	Location: "socket://localhost:9001/"
	Protocol: http
	Interfaces: JollarInterface
}

//insieme di correlazione, contiene un id per "non fare confusione tra i client e behaviour"
// identifica sessione (session id) tra i vari client
cset {
	sid: OpMessage.sid
}

execution{ concurrent }

init{
	println@Console( "Server running" )();
	// per variabili ripetute, solo per inizializzare il blocco 0 dal server
	with(global.listaPeer.nodo) {
		.publicKey = "start";
		.location = "socket://localhost:9000";
		.protocol = "http";
		.sid = ""
	};
	global.rw_mutex.name = "rw_mutex";
	global.r_mutex.name = "r.mutex";
	global.token.name = "token";
	release@SemaphoreUtils(global.r_mutex)()
}

main{
	//invio il tempo al client che me lo ha richiesto
	receiveTime()( millis ) {
		//interrogo Time per sapere i millisecondi di tempo attuale
		getCurrentTimeMillis@Time()( time );
		//stampo a quale client ho inviato il tempo
		println@Console("Current time: " + time)();
		millis = time
	}
	;
	aggiungiPeer(peer)(result) {
		synchronized( token ) {
			i = #global.listaPeer.nodo;
			with(global.listaPeer.nodo[i]) {
				.publicKey = peer.publicKey;
				.location = peer.location;
				.protocol = peer.protocol;
				// per creare un sid nuovo generato mai stato usato
				.sid = csets.sid = new
			};
			// result.i solo per inviare il numero blocco
			result.i = i;
			result.sid = listaPeer.nodo[i].sid
		}
	}
	;
	{
		{
			//ricevo blockchain da client a server
			invioBlockchain(msg);
			global.blockchain << msg.blockchain;
      		// incremento il semaforo solo dopo che è stato scritto il primo blocco
     		// così i nodi successivi scaricheranno una blockchain non vuota
			release@SemaphoreUtils(global.rw_mutex)()
		}
		|
		{
    		//è simile al problema reader-writer
			downloadBlockchain(info)(bc) {
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
					release@SemaphoreUtils(global.rw_mutex)();
					release@SemaphoreUtils(global.token)()
				};
				release@SemaphoreUtils(global.r_mutex)()
			}
		}
	}
	;
	{
		invioPeer()(lista) {
			acquire@SemaphoreUtils(global.token)();
			lista = listaPeer
		}
	}
}