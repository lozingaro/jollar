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
	Location: "socket://localhost:9003"
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
//	walletAmount = 0;
	with (info) {
		.publicKey = publicKey;
		.location = "socket://localhost:9003";
		.protocol = "http"
	}
}

main {
	aggiungiPeer@JollarCore(info)(indexMsg);
	println@Console("Nodo aggiunto con successo:\nLoc: " + info.location +
		"\nProt: " + info.protocol + "\nPubK: " + info.publicKey)();
	sidMsg.sid = indexMsg.sid;
	//se sono il primo nodo...
	if (indexMsg.index == 2) {
		println@Console( "sono il primo nodo, creo il primo blocco" )();

		println@Console( "il mio sid e' \t" + sidMsg.sid)();
		//receiveTime riceve il tempo in millisec inviato dal server
		receiveTime@JollarCore(sidMsg)( result );
		//stampo su console il valore ottenuto
		println@Console("Time ms: " + result)();

		//mi serve la public key del server, quindi chiedo la lista
		invioPeer@JollarCore(sidMsg)(listaPeer);
		creazionePrimoBlocco;
		firmaHashNuovoBlocco;
		with( bloccoMsg ){
			.sid = sidMsg.sid;
			.block << nuovoBlocco;
			.cryptoCurrentBlockHash = cryptoCurrentBlockHash
		};
		// Da client a server
		invioPrimoBlocco@JollarCore(bloccoMsg);
		blockchain.block << nuovoBlocco;
		//Resto in attesa che si connettano tutti i peer
		println@Console("**Sono il primo nodo e sono in attesa di n nodi connessi")();
		inAttesaDiTuttiIPeer(); //Aspetta finchè server non arriva al comando
		println@Console( "**NON sono più in attesa" )();
		//mi faccio mandare la lista dei peer
		invioPeer@JollarCore(sidMsg)(listaPeer);
		println@Console( "devo creare il secondo blocco" )();
		//creo e invio il secondo blocco
		creaInfoSecondoBlocco;
		println@Console( "sono bloccato 001" )();
		creaEInviaBlocco;
		println@Console( "sono bloccato 002" )();
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
		inAttesaDelleTransazioni@portaBroadcast()
	}
	//se non sono il primo nodo
	else {
		downloadBlockchain@JollarCore(sidMsg)(downloadMsg);
		wallet << downloadMsg.wallet;
		blockchain << downloadMsg.blockchain;
		//devo convalidare la blockchain da zero??
		//while(true) {
			println@Console( "**Aspetto che mi arrivi qualche blocco" )();
	  		invioBlocco(bMsg);
			verificaBMsg
		//}
	}
	|
	riceviBlockchain()(blockchain)
}

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
	with( transazione ){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 6
	};
	md5@MessageDigest("0")(hash0);
	getCurrentTimeMillis@Time()(timeStamp);
	with( chain ){
		.tipo = 1;
		.origine = 2;
		.i = 1;
		.primo = 2
	} ;
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

define getPreviousBlockHash
{
	bcSize = #blockchain.block;
	getJsonString@JsonUtils(blockchain.block[bcSize-1])(stringa);
	md5@MessageDigest(stringa)(previousBlockHash)
}

define getChain
{
	println@Console( "sono nel getchain" )();
	k = #blockchain.block-1;
	println@Console( "k e'" + k )();
	chain -> blockchain.block[k].chain;
	op.base = 2;
	i = ++chain.i;
	op.exponent = (i - 1);
	pow@Math(op)(potenza);
	p = potenza * chain.origine + (potenza - 1);
	println@Console( "p è" + p )();
	with( catena ){
		.tipo = 1;
		.origine = chain.origine;
		.primo = int(p);
		.i = i
	}
}
define creazioneNuovoBlocco
{
	//calcolo l'hash del blocco precedente
	{
		getPreviousBlockHash |
		getCurrentTimeMillis@Time()(timeStamp) |
		getChain
	};
	with(nuovoBlocco) {
		.previousBlockHash = previousBlockHash;
		.difficulty = 1.0; //numeri di zeri da calcolare
		.transaction << transazione; //info sulla transazione
		.timeStamp = timeStamp; //devo ottenere il timestamp
		.chain << catena
	}
}

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
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 1
	}
}

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
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 2
	}
}

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
	with (transazione){
		.nodeSeller << nS;
		.nodeBuyer << nB;
		.jollar = 3
	}
}

define firmaHashNuovoBlocco
{
	getJsonString@JsonUtils(nuovoBlocco)(s);
	md5@MessageDigest(s)(h);
	with( firmaReq ){
		.privateKey = privateKey;
		.plaintext = h
	};
	firma@MyKeyUtil(firmaReq)(cryptoCurrentBlockHash)
}

define invioBroadcast
{
	with( bloccoMsg ){
		.sid = sidMsg.sid;
		.block << nuovoBlocco;
		.cryptoCurrentBlockHash = cryptoCurrentBlockHash
	};
	for ( i = 0, i < #listaPeer.nodo, i++) {
		if (i != indexMsg.index && i != 1) { // Così posso escludere QUESTO nodo e escludere NV
			//binding dinamico:
			//ad ogni iterazione cambio location e protocol della portaBroadcast
			pB -> portaBroadcast;
			nodoi -> listaPeer.nodo[i];
			with( pB ){
				.location = nodoi.location;
				.protocol = nodoi.protocol
			};
			println@Console( "invio il nuovo blocco a\t" + i + " -- " +
				pB.location + " " + pB.protocol )();
			// da terminare
			invioBlocco@portaBroadcast(bloccoMsg)
		}
	}
}

define creaEInviaBlocco
{
	creazioneNuovoBlocco;
	println@Console( "sono bloccato 001.001" )();
	firmaHashNuovoBlocco;
	println@Console( "sono bloccato 001.002" )();
	invioBroadcast
}

define aggiungiNuovoBlocco
{
	size = #blockchain.block;
	blockchain.block[size] << nuovoBlocco
}

define validazione
{
	//se passo i vari test, allora salvo il blocco
	p -> bMsg.block.chain.primo;
	//verifica con teorema di fermat
	a = 2;
	op.base = a;
	op.exponent = p-1;
	pow@Math(op)(potenza);
	r = potenza%p;
	println@Console( "la potenza e' " + potenza )();
	println@Console( "p e' " + p )();
	println@Console( "il resto e' "  + r)();
	if ( r==1  ) {
		println@Console( "**il numero " + p + " e' primo" )();
		println@Console( "dovrei fare altri test" )();
		sz = #blockchain.block;
		blockchain.block[sz] << b.block;
		println@Console( "ho aggiunto il blocco" )();
		println@Console( "bc size prima: " + sz + "\tbc size adesso: " + #blockchain.block )()
	}
}

define verificaBMsg
{
	getJsonString@JsonUtils(bMsg.block)(stringBlocco);
	md5@MessageDigest(stringBlocco)(hashBlocco);
	with( verificaReq ){
		.plaintext = hashBlocco;
		.publicKey = bMsg.block.transaction.nodeSeller.publicKey;
		.ciphertext = bMsg.cryptoCurrentBlockHash
	};
	verifica@MyKeyUtil(verificaReq)(verificato);
	if (verificato) {
			println@Console( "** L'hash corrisponde, procedo con la validazione" )();

			validazione

	}
	else {
		println@Console( "** L'hash NON corrisponde, il blocco viene rigettato" )()
	}
}