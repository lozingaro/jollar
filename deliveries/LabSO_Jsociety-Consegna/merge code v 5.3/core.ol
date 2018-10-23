include "time.iol"
include "interface.iol"
include "console.iol"
include "converter.iol"
include "semaphore_utils.iol"
include "math.iol"
include "json_utils.iol"
include "message_digest.iol"
include "exec.iol"

include "MyUtilInterface.iol"

outputPort MyKeyUtil {
	Interfaces: MyUtilInterface
}

embedded {
	// Inserire pacchetto jar in C:\Jolie
	Java: "myUtil.MyKeyUtil" in MyKeyUtil
}

inputPort JollarCore {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

outputPort ServerOutput{
	Interfaces: JollarInterface
}

//insieme di correlazione, contiene un id per identificare l'istanza di
//behaviour con la quale il client sta interagendo
cset {
	sid: IndexMessage.sid SidMessage.sid BlockMsg.sid
}

constants {
	INDICE_MIN_PEER = 5
}

execution { concurrent }

init
{
	global.contNodi = 0;
	println@Console( "Server running" )();
	generaChiavi@MyKeyUtil()(chiavi);
	//inizializzazione della lista dei nodi
	with(global.listaPeer.nodo) {
		.publicKey = chiavi.publicKey;
		.location = "socket://localhost:9000";
		.protocol = "http"
	};
	global.letturaPrimoBlocco.name = "letturaPrimoBlocco";
	with(richiestaComando) {
		// windows
		.args[0] = "start_service.bat";
		// linux & mac
		.args[1] = "gnome_terminal jolie networkVisualizer.ol && gnome_terminal jolie peer1.ol | gnome_terminal jolie peer2.ol | gnome_terminal jolie peer3.ol | gnome_terminal jolie peer4.ol"
	};
	println@Console( "Avvio del network visualizer e dei nodi in corso.." )();
	sleep@Time(2000)();
	exec@Exec(richiestaComando.args)();
	sleep@Time(1000)();
	println@Console( "Avvio dei 4 peers.." )()
}

main
{
	//invio il tempo al client che me lo ha richiesto
	aggiungiPeer(peer)(indexMsg) {
		synchronized( token_lista ) {
			i = #global.listaPeer.nodo;
			with(global.listaPeer.nodo[i]) {
				.publicKey = peer.publicKey;
				.location = peer.location;
				.protocol = peer.protocol
			};
			indexMsg.index = i;
			indexMsg.sid = csets.sid = new;
			//se si sono connessi almeno INDICE_MIN_PEER peer
			//allora il primo nodo inizia a fare le transazioni
			println@Console( "-- In attesa di " + (INDICE_MIN_PEER-i+1) + " peer connessi.." )();
			if (i == INDICE_MIN_PEER) {
				println@Console( "** Peer connessi: "+ INDICE_MIN_PEER +", resume.." )();
				synchronized( token_lista ){
					ServerOutput.protocol = global.listaPeer.nodo[2].protocol;
					ServerOutput.location = global.listaPeer.nodo[2].location
				};
				inAttesaDiTuttiIPeer@ServerOutput()
			}
		}
	}
	;
	{
		while( true ) {
			receiveTime(sidMsg)( millis ) {
				//interrogo Time per sapere i millisecondi di tempo attuale
				getCurrentTimeMillis@Time()( time );
				//stampo a quale client ho inviato il tempo
				println@Console("Current time: " + time)();
				getDateTime@Time(time)(date);
				println@Console("Current date: " + date)();
				// Array che memorizza la data di arrivo dei nodi per poi buttare in
				// output al momento della richiesta del network visualizer
				global.dateNodeTime[global.contNodi] = date;
				global.contNodi++;
				millis = time
			}
		}
		|
		/*networkVisualizer(sidNV)(infoNet){
			getCurrentTimeMillis@Time()( time );
			getDateTime@Time(time)(date);
			infoNet.dateReq = string(date);
			infoNet.listaPeer << global.listaPeer
			//infoNet.dateNodeTime = global.dateNodeTime
		}
		|
		aggiungiNV(nv)(indexMsg) {
			with(global.netVis) {
				.publicKey = nv.publicKey;
				.location = nv.location;
				.protocol = nv.protocol
			};
			ServerOutput.protocol = global.netVis.protocol;
			ServerOutput.location = global.netVis.location;
			indexMsg.sid = csets.sid = new
		}
		|*/
		{
			//ricevo blockchain da client a server
			invioPrimoBlocco(primoBlocco);
			verificaPrimoBlocco
		}
		|
		downloadBlockchain(sidMsg)(blockchain) {
			acquire@SemaphoreUtils(global.letturaPrimoBlocco)();
			synchronized( token_blockchain ){
				blockchain << global.blockchain
			};
			release@SemaphoreUtils(global.letturaPrimoBlocco)()
		}
		|
		while( true ) {
			invioPeer(sidMsg)(lista) {
				synchronized( token_lista ){
					println@Console( "sto inviando la lista con " +	#global.listaPeer.nodo
					+ " nodi (core e network visualizer compresi) " )();
					lista << global.listaPeer
				}
			}
		}
		|
		for ( j = 0, j<3, j++ ) {
			invioBlocco(bMsg);
			verificaBMsg
		}

		/*|

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
			*/
	}
}

/**
 * Metodo che permette di validare o meno un blocco ricevuto
 */
define validazione
{
	p -> bMsg.block.chain.primo;
	//verifica con il piccolo teorema di Fermat
	a = 2;
	op.base = a;
	op.exponent = p-1;
	pow@Math(op)(potenza);
	r = potenza%p;
	if ( r==1  ) {
		println@Console( "Il numero " + p + " e' pseudoprimo" )();
		//controllo che il previousBlockHash corrisponda
		synchronized( token_blockchain ){
			sz = #global.blockchain.block;
			previousBlock -> global.blockchain.block[sz-1]
		};
		getJsonString@JsonUtils(previousBlock)(previousBlockString);
		md5@MessageDigest(previousBlockString)(previousBlockHash);
		//confronto l'hash dell'attuale ultimo blocco con
		//il previousBlockHash del nuovo blocco
		if (previousBlockHash == bMsg.block.previousBlockHash) {
			println@Console( "Il previousBlockHash corrisponde" )();
			//se passo i vari test, allora salvo il blocco
			println@Console( "Il blocco viene salvato" )();
			synchronized( token_lista ){
				global.blockchain.block[sz] << bMsg.block
			}
		}
		else {
			println@Console( "Il previousBlockHash non corrisponde" )()
		}
	}
	else {
		println@Console( "Il numero " + p + " NON e' pseudoprimo" )()
	}
}

/**
 * Metodo che verifica che l'hash firmato corrisponda all'hash del blocco ricevuto
 */
define verificaBMsg
{
	//calcolo l'hash del blocco ricevuto
	getJsonString@JsonUtils(bMsg.block)(stringBlocco);
	md5@MessageDigest(stringBlocco)(hashBlocco);
	println@Console( "\n** Ho ricevuto il blocco seguente:\n" + stringBlocco )();
	//verifico la corrispondenza attraverso il Java service embedded
	with( verificaReq ){
		.plaintext = hashBlocco;
		.publicKey = bMsg.block.transaction.nodeSeller.publicKey;
		.ciphertext = bMsg.cryptoCurrentBlockHash
	};
	verifica@MyKeyUtil(verificaReq)(verificato);
	if (verificato) {
			println@Console( "La firma e' stata verificata, procedo con la validazione" )();
			validazione
	}
	else {
		println@Console( "La firma non ha superato la verifica, il blocco viene rigettato" )()
	}
}

/**
 * Metodo che permette di validare o meno un blocco ricevuto
 */
define validazionePrimoBlocco
{
	p -> primoBlocco.block.chain.primo;
	//verifica con il piccolo teorema di Fermat
	a = 2;
	op.base = a;
	op.exponent = p-1;
	pow@Math(op)(potenza);
	r = potenza%p;
	if ( r==1  ) {
		println@Console( "Il numero " + p + " e' pseudoprimo" )();
		//controllo che il previousBlockHash corrisponda
		md5@MessageDigest("0")(hash_0);
		if (hash_0 == primoBlocco.block.previousBlockHash) {
			println@Console( "Il previousBlockHash corrisponde" )();
			//se passo i vari test, allora salvo il blocco
			println@Console( "Il blocco viene salvato" )();
			synchronized( token_blockchain ){
				global.blockchain.block << primoBlocco.block
			};
			// incremento il semaforo solo dopo che è stato scritto il primo blocco
	    // così i nodi successivi scaricheranno una blockchain non vuota
			//ne rilascio 3 perché i peer successivi della demo sono 3
			release@SemaphoreUtils(global.letturaPrimoBlocco)();
			release@SemaphoreUtils(global.letturaPrimoBlocco)();
			release@SemaphoreUtils(global.letturaPrimoBlocco)()
		}
		else {
			println@Console( "Il previousBlockHash non corrisponde" )()
		}
	}
	else {
		println@Console( "Il numero " + p + " NON e' pseudoprimo" )()
	}
}

/**
 * Metodo che verifica che l'hash firmato corrisponda all'hash del blocco ricevuto
 */
define verificaPrimoBlocco
{
	//calcolo l'hash del blocco ricevuto
	getJsonString@JsonUtils(primoBlocco.block)(stringBlocco);
	md5@MessageDigest(stringBlocco)(hashPrimoBlocco);
	println@Console( "\n** Ho ricevuto il primo blocco:\n" + stringBlocco )();
	//verifico la corrispondenza attraverso il Java service embedded
	with( verificaReq ){
		.plaintext = hashPrimoBlocco;
		.publicKey = primoBlocco.block.transaction.nodeBuyer.publicKey;
		.ciphertext = primoBlocco.cryptoCurrentBlockHash
	};
	verifica@MyKeyUtil(verificaReq)(verificato);
	if (verificato) {
			println@Console( "La firma e' stata verificata, procedo con la validazione" )();
			validazionePrimoBlocco
	}
	else {
		println@Console( "La firma non ha superato la verifica, il blocco viene rigettato" )()
	}
}
