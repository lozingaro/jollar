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
	if (indexMsg.index == 1) {
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
		println@Console("**Sono il primo nodo e sono in attesa di n nodi connessi")();
		inAttesaDiTuttiIPeer();
		println@Console( "NON sono più in attesa" )();
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
		aggiungiNuovoBlocco
	}
	//se non sono il primo nodo
	else {
		//scarico la blockchain dal Core
		downloadBlockchain@JollarCore(sidMsg)(downloadMsg);
		wallet << downloadMsg.wallet;
		blockchain << downloadMsg.blockchain;
		//resto in attesa che arrivi un blocco da convalidare
		while(true) {
			println@Console( "**Aspetto che mi arrivi qualche blocco" )();
	  	invioBlocco(bMsg);
			verificaBMsg
		}
	}
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
	getCurrentTimeMillis@Time()(timeStamp);
	//creo il primo elemento della catena
	with( chain ){
		.tipo = 1;
		.origine = 2;
		.i = 1;
		.primo = 2
	} ;
	//creo il primo blocco
	with(nuovoBlocco) {
		.previousBlockHash = hash0;
		.difficulty = 1.0;
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
	i = ++chainPrecedente.i;
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
		getCurrentTimeMillis@Time()(timeStamp) |
		//calcolo il numero primo e inserisco le informazioni sulla catena
		getChain
	};
	//inserisco le info nel nuovo blocco
	with(nuovoBlocco) {
		.previousBlockHash = previousBlockHash;
		.difficulty = 1.0; //numeri di zeri da calcolare
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
		.index = 1;
		.publicKey = publicKey
	};
	// Nodo destinatario
	with (nB) {
		.index = 2;
		.publicKey = listaPeer.nodo[2].publicKey
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
		.index = 1;
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
		.jollar = 2
	}
}

/**
 * Metodo che contiene la transazione relativa al quarto blocco
 */
define creaInfoQuartoBlocco
{// Nodo mittente
	with (nS) {
		.index = 1;
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
		.jollar = 3
	}
}

/**
 * Metodo che permette di firmare l'hash di un nuovo blocco
 */
define firmaHashNuovoBlocco
{
	//converto il blocco in string e calcolo l'hash
	getJsonString@JsonUtils(nuovoBlocco)(s);
	md5@MessageDigest(s)(h);
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
	for ( i = 0, i < #listaPeer.nodo, i++) {
		if (i != indexMsg.index) { // Così posso escludere QUESTO nodo
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
		println@Console( "Il numero " + p + " è pseudoprimo" )();
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
			blockchain.block[sz] << bMsg.block
		}
		else {
			println@Console( "Il previousBlockHash non corrisponde" )()
		}
	}
	else {
		println@Console( "Il numero " + p + " NON è pseudoprimo" )()
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
	//verifico la corrispondenza attraverso il Java service embedded
	with( verificaReq ){
		.plaintext = hashBlocco;
		.publicKey = bMsg.block.transaction.nodeSeller.publicKey;
		.ciphertext = bMsg.cryptoCurrentBlockHash
	};
	verifica@MyKeyUtil(verificaReq)(verificato);
	if (verificato) {
			println@Console( "**La firma è stata verificata, procedo con la validazione" )();
			validazione
	}
	else {
		println@Console( "** La firma non ha superato la verifica, il blocco viene rigettato" )()
	}
}
