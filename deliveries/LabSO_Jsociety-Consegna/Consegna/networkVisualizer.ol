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
//porta di output che interroga server timestamp
outputPort ToCore {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}

outputPort portaBroadcast {
	Interfaces: JollarInterface
}

inputPort InPort {
	Location: "socket://localhost:9009/"
	Protocol: http
	Interfaces: JollarInterface
}

init{
	println@Console( "Connessione stabilita con: \"socket://localhost:9000\" " )();
	generaChiavi@MyKeyUtil()(chiavi);
	publicKey = chiavi.publicKey;
	privateKey = chiavi.privateKey;
	// walletAmount = 0;
	with (info) {
		.publicKey = publicKey;
		.location = "socket://localhost:9009";
		.protocol = "http"
	};
	// Inizialmente assegno valore zero, così la prima blockchain più lunga è quella ufficiale
	global.officialBlockchain = 0;
	global.puntBlockchain = 0
}

main{
	aggiungiPeer@ToCore(info)(sidNV);
	println@Console("NV aggiunto con successo:\nLoc: " + info.location +
		"\nProt: " + info.protocol + "\nPubK: " + info.publicKey)();
	sidMsg.sid = sidNV.sid;
	println@Console( "SID:\t" + sidMsg.sid)();
	println@Console( "Richiesta monitoraggio risorse ai peer connessi.." )();
	inAttesaDelleTransazioni();
	println@Console( "Resuming.. Contatto il server." )();
	//networkVisualizer@ToCore(sidMsg)(infoNet);

	invioPeer@ToCore(sidMsg)(listaPeer);
	getCurrentTimeMillis@Time()( time );
	getDateTime@Time(time)(date);

	// • La data e l’ora del server timestamp al momento della richiesta.
	println@Console("Richiesta informazioni blockchain effettuata: " + date)();

	for (i = 2, i < #listaPeer.nodo, i++) {
		//binding dinamico:
		//ad ogni iterazione cambio location e protocol della portaBroadcast
		pB -> portaBroadcast;
		nodoi -> listaPeer.nodo[i];
		with( pB ){
			.location = nodoi.location;
			.protocol = nodoi.protocol
		};
		println@Console("[Network Visualizer]: Ricezione blockchain da: " + i + " nodo -> " + pB.location + " - " + pB.protocol)();
		// Salvo tutte le blockchain dei vari blocchi, quella più lunga è la ufficiale
		riceviBlockchain@portaBroadcast()(blockchainTemp);
		blockchain[i] << blockchainTemp;
		if ( #blockchainTemp.block > #officialBlockchain.block){
			puntBlockchain = i;
			officialBlockchain << blockchain[i]
		};
		println@Console("Lunghezza blockchain ricevuta: " + #blockchain[i].block)()
	};

		//• La blockchain piu` lunga presente nella rete (chiamata la versione ufficiale),
		//con tutta la struttura dati che contiene.
	println@Console( "La blockchain ufficiale e'" )();

	for ( k = 0, k<#officialBlockchain.block, k++ ) {
		println@Console( "Blocco " + k + ":" )();
		getJsonString@JsonUtils(officialBlockchain.block[k])(blocco);
		println@Console( blocco )()
	};

	/*• Per ogni utente/nodo: la sua chiave pubblica; le transazioni
	che ha effettuato divise per entrate/uscite;
	la versione della blockchain che utilizza e la quantita` totale di Jollar che possiede. */

	println@Console( "\n** informazioni sui peer\n" )();
	for ( k=2, k<#listaPeer.nodo, k++ ) {
		wallet[k] = 0;
		println@Console( "-- Nodo con indice  " + k)();
		println@Console( "chiave pubblica  " + listaPeer.nodo[k].publicKey )();

		for ( j=0, j<#officialBlockchain.block, j++ ) {
			present = false;
			bloccoJ -> officialBlockchain.block[j];
			transazioneJ -> bloccoJ.transaction;

			if (transazioneJ.nodeSeller.publicKey == listaPeer.nodo[k].publicKey) {
				present = true;
				println@Console( "-- Transazione in uscita" )();
				wallet[k] = wallet[k] - transazioneJ.jollar
			}
			else if( transazioneJ.nodeBuyer.publicKey == listaPeer.nodo[k].publicKey ) {
				present = true;
				println@Console( "-- transazione in entrata" )();
				wallet[k] = wallet[k] + transazioneJ.jollar
			};

			/*• Per ogni transazione al punto precedente, ordinate in ordine cronologico,
 		si indica la data, l’ora, e gli utenti (con le loro chiavi pubbliche) coinvolti.
		*/
			if (present) {
					println@Console( "node seller   " + transazioneJ.nodeSeller.publicKey )();
					println@Console( "node buyer    " + transazioneJ.nodeBuyer.publicKey )();
					println@Console( "jollar:       " + transazioneJ.jollar )();
					getDateTime@Time(bloccoJ.timeStamp)(date);
					println@Console( "data e ora    " + date )()
			}
		};
		println@Console( "il wallet del nodo e ' " + wallet[k] + "\n")()
	}
}
