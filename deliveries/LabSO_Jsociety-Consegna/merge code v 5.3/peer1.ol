include "time.iol"
include "semaphore_utils.iol"
include "interface.iol"
include "message_digest.iol"
include "console.iol"
include "math.iol"

include "json_utils.iol"
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
	generaChiavi@MyKeyUtil()(chiavi);
	publicKey = chiavi.publicKey;
	privateKey = chiavi.privateKey;
	with (info) {
		.publicKey = publicKey;
		.location = "socket://localhost:9001";
		.protocol = "http"
	}
}

main {
	aggiungiPeer@JollarCore(info)(indexMsg);
	println@Console("Connessione stabilita con: \t" + JollarCore.location )();
	println@Console("Nodo aggiunto con successo:\nLoc: " + info.location +
		"\nProt: " + info.protocol + "\nPubK: " + info.publicKey)();
	sidMsg.sid = indexMsg.sid;
	//se sono il primo nodo...
	if (indexMsg.index == 2) {
		println@Console( "sono il primo nodo, creo il primo blocco" )();
		//receiveTime riceve il tempo in millisec inviato dal server
		receiveTime@JollarCore(sidMsg)( result );
		//stampo su console il valore ottenuto
		println@Console("Time ms: " + result)();

		//mi serve la public key del Core, quindi chiedo la lista
		invioPeer@JollarCore(sidMsg)(listaPeer);
		//creo e invio il primo blocco al Core
		creazionePrimoBlocco;
		firmaHashNuovoBlocco;
		with( bloccoMsg ){
			.sid = sidMsg.sid;
			.block << nuovoBlocco;
			.cryptoCurrentBlockHash = cryptoCurrentBlockHash
		};
		invioPrimoBlocco@JollarCore(bloccoMsg);
		blockchain.block << nuovoBlocco;

		//Resto in attesa che si connettano tutti i peer
		println@Console("**Sono il primo nodo e sono in attesa degli altri nodi connessi")();
		inAttesaDiTuttiIPeer();
		println@Console( "NON sono piu' in attesa" )();
		//mi faccio mandare la lista aggiornata dei peer
		invioPeer@JollarCore(sidMsg)(listaPeer);

		//creo e invio il secondo blocco
		creaInfoSecondoBlocco;
		creaEInviaBlocco;
		aggiungiNuovoBlocco;

		//creo e invio il terzo blocco
		creaInfoTerzoBlocco;
		creaEInviaBlocco;
		aggiungiNuovoBlocco;

		//creo e invio il quarto blocco
		creaInfoQuartoBlocco;
		creaEInviaBlocco;
		aggiungiNuovoBlocco;

		//a questo punto il NV può resumare
		portaBroadcast.protocol = listaPeer.nodo[1].protocol;
		portaBroadcast.location = listaPeer.nodo[1].location;
		println@Console( "Richiesta monitoraggio risorse - Network Visualizer a:\t" + portaBroadcast.location + " " + portaBroadcast.protocol )();
		inAttesaDelleTransazioni@portaBroadcast();
		riceviBlockchain()(blockchain)
	}
	//se non sono il primo nodo
	else {
		//scarico la blockchain dal Core
		downloadBlockchain@JollarCore(sidMsg)(bc);
		blockchain << bc;
		//resto in attesa che arrivi un blocco da convalidare
		for ( j = 0, j<3, j++ ) {
			println@Console( "Aspetto che mi arrivi il prossimo blocco" )();
	  	invioBlocco(bMsg);
			verificaBMsg
		}
		;
		riceviBlockchain()(blockchain)
	}
}

/**
 * Metodo che permette di ottenere la difficulty
 */
define getDifficulty
{
	pk = p;
	k = i;
	oper.base = 2;
	oper.exponent = p-1;
	pow@Math(oper)(power);
	remainder = power%pk;
	//formula della difficulty presa dal primecoin paper
	d =double (k) + double((pk-remainder)/pk)
}

/**
 * Metodo che permette di creare il primo blocco
 */
define creazionePrimoBlocco
{
	// Nodo mittente
	with (nS) {
		.index = 0;
		.publicKey = listaPeer.nodo[0].publicKey
	};
	// Nodo destinatario
	with (nB) {
		.index = indexMsg.index;
		.publicKey = publicKey
	};
	//transazione
	with( transazione ){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 6
	};
	//calcolo hash e timeStamp
	md5@MessageDigest("0")(hash0);
	receiveTime@JollarCore(sidMsg)(timeStamp);
	//creo il primo elemento della catena
	i = 2;
	origine = 2;
	op.base = 2;
	op.exponent = (i - 1);
	pow@Math(op)(potenza);
	p = potenza * origine + (potenza -1);
	with( chain ){
		.tipo = 1;
		.origine = origine;
		.i = i;
		.primo = int(p)
	} ;
	//calcolo la difficulty
	getDifficulty;
	//creo il primo blocco
	with(nuovoBlocco) {
		.previousBlockHash = hash0;
		.difficulty =d;// 1.0;
		.transaction << transazione;
		.timeStamp = timeStamp;
		.chain << chain
	}
	|
	bloccoMsg.sid = sidMsg.sid
}

/**
 * Metodo che permette di calcolare l'hash del blocco precedente
 */
define getPreviousBlockHash
{
	bcSize = #blockchain.block;
	getJsonString@JsonUtils(blockchain.block[bcSize-1])(stringa);
	md5@MessageDigest(stringa)(previousBlockHash)
}

/**
 * Metodo che permette di creare un nuovo elemento della catena di Cunningham
 * del primo tipo.
 */
define getChain
{
	k = #blockchain.block-1;
	chainPrecedente -> blockchain.block[k].chain;
	i = chainPrecedente.i + 1;
	//calcolo il nuovo numero primo della catena
	op.base = 2;
	op.exponent = (i - 1);
	pow@Math(op)(potenza);
	p = potenza * chainPrecedente.origine + (potenza - 1);
	//inserisco le info nel nuovo elemento della catena
	with( nuovaChain ){
		.tipo = 1;
		.origine = chainPrecedente.origine;
		.primo = int(p);
		.i = i
	}
}

/**
 * Metodo che permette di creare un nuovo blocco
 */
define creazioneNuovoBlocco
{
	{
		//calcolo l'hash del blocco precedente
		getPreviousBlockHash |
		//ottengo il timeStamp
		receiveTime@JollarCore(sidMsg)(timeStamp) |
		//calcolo il numero primo e difficulty
		//e inserisco le informazioni sulla catena
		{
			getChain;
			getDifficulty
		}
	};
	//inserisco le info nel nuovo blocco
	with(nuovoBlocco) {
		.previousBlockHash = previousBlockHash;
		.difficulty = d; //numeri di zeri da calcolare
		.transaction << transazione; //info sulla transazione
		.timeStamp = timeStamp;
		.chain << nuovaChain
	}
}

/**
 * Metodo che contiene la transazione relativa al secondo blocco
 */
define creaInfoSecondoBlocco
{// Nodo mittente
	with (nS) {
		.index = 2;
		.publicKey = publicKey
	};
	// Nodo destinatario
	with (nB) {
		.index = 3;
		.publicKey = listaPeer.nodo[3].publicKey
	};
	//transazione
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 1
	}
}

/**
 * Metodo che contiene la transazione relativa al terzo blocco
 */
define creaInfoTerzoBlocco
{// Nodo mittente
	with (nS) {
		.index = 2;
		.publicKey = publicKey
	};
	// Nodo destinatario
	with (nB) {
		.index = 4;
		.publicKey = listaPeer.nodo[4].publicKey
	};
	//transazione
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 2
	}
}

/**
 * Metodo che contiene la transazione relativa al quarto blocco
 */
define creaInfoQuartoBlocco
{// Nodo mittente
	with (nS) {
		.index = 2;
		.publicKey = publicKey
	};
	// Nodo destinatario
	with (nB) {
		.index = 5;
		.publicKey = listaPeer.nodo[5].publicKey
	};
	//transazione
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 3
	}
}

/**
 * Metodo che permette di firmare l'hash di un nuovo blocco
 */
 define firmaHashNuovoBlocco
 {
 	//converto il blocco in string e calcolo l'hash
 	getJsonString@JsonUtils(nuovoBlocco)(nuovoBloccoString);
	md5@MessageDigest(nuovoBloccoString)(h);
	//firmo il blocco attraverso l'operation del Java service embedded
 	with( firmaReq ){
 		.privateKey = privateKey;
 		.plaintext = h
 	};
 	firma@MyKeyUtil(firmaReq)(cryptoCurrentBlockHash)
 }

 /**
  * Metodo che permette di inviare in broadcast il blocco creato
  */
 define invioBroadcast
 {
 	//creo il messaggio da inviare
 	with( bloccoMsg ){
 		.sid = sidMsg.sid;
 		.block << nuovoBlocco;
 		.cryptoCurrentBlockHash = cryptoCurrentBlockHash
 	};
	//trasmetto in broadcast il messaggio
println@Console( "\nInvio il blocco:\n" + nuovoBloccoString )();
	for ( i = 0, i < #listaPeer.nodo, i++) {
 		if (i != indexMsg.index && i!= 1) { // Così posso escludere QUESTO nodo
 			//binding dinamico:
 			//ad ogni iterazione cambio location e protocol della portaBroadcast
 			pB -> portaBroadcast;
 			nodo_i -> listaPeer.nodo[i];
 			with( pB ){
 				.location = nodo_i.location;
 				.protocol = nodo_i.protocol
 			};
 			println@Console( "Invio il nuovo blocco al peer n. " + i)();
 			invioBlocco@portaBroadcast(bloccoMsg)
 		}
 	}
 }

define creaEInviaBlocco
{
	creazioneNuovoBlocco;
	firmaHashNuovoBlocco;
	invioBroadcast
}

/**
 * Metodo che permette di aggiungere il blocco creato alla blockchain
 */
define aggiungiNuovoBlocco
{
	size = #blockchain.block;
	blockchain.block[size] << nuovoBlocco
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
		sz = #blockchain.block;
		previousBlock -> blockchain.block[sz-1];
		getJsonString@JsonUtils(previousBlock)(previousBlockString);
		md5@MessageDigest(previousBlockString)(previousBlockHash);
		//confronto l'hash dell'attuale ultimo blocco con
		//il previousBlockHash del nuovo blocco
		if (previousBlockHash == bMsg.block.previousBlockHash) {
			println@Console( "Il previousBlockHash corrisponde" )();
			//se passo i vari test, allora salvo il blocco
			println@Console( "Il blocco viene salvato" )();
			blockchain.block[sz] << bMsg.block
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
	println@Console( "\nHo ricevuto il blocco seguente:\n" + stringBlocco )();
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