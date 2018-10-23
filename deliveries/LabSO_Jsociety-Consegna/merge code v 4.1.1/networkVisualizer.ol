/*

Il Network Visualiser `e un tool amministrativo da terminale per il monitoraggio del sistema.
--> Implementazione
Il Network Visualizer invia richieste a tutta la rete per conoscere 
lo stato delle blockchain di tutti i nodi, la loro versione, le transazioni che contengono,
generando le seguenti informazioni:

• La data e l’ora del server timestamp al momento della richiesta.

• Per ogni utente/nodo: la sua chiave pubblica; le transazioni 
che ha effettuato divise per entrate/uscite; 
la versione della blockchain che utilizza e la quantita` totale di Jollar che possiede.

• Per ogni transazione al punto precedente, ordinate in ordine cronologico,
 si indica la data, l’ora, e gli utenti (con le loro chiavi pubbliche) coinvolti.

• La blockchain piu` lunga presente nella rete (chiamata la versione ufficiale), 
con tutta la struttura dati che contiene.

*/

include "console.iol"
include "interface.iol"
include "Time.iol"

//porta di output che interroga server timestamp
outputPort ToCore {
	Location: "socket://localhost:9000/"
	Protocol: http
	Interfaces: JollarInterface
}
outputPort portaBroadcast {
	Interfaces: JollarInterface
}

init{
	// Inizialmente assegno valore zero, così la prima blockchain più lunga è quella ufficiale
	global.officialBlockchain = 0;
	global.puntBlockchain = 0
}

main{
	networkVisualizer@ToCore()(infoNet);
	println@Console("Richiesta informazioni blockchain effettuata: " + infoNet.dateReq)();
	for (i = 0, i < #infoNet.listaPeer.nodo, i++) {
		//binding dinamico:
		//ad ogni iterazione cambio location e protocol della portaBroadcast
		pB -> portaBroadcast;
		nodoi -> infoNet.listaPeer.nodo[i];
		with( pB ){
			.location = nodoi.location;
			.protocol = nodoi.protocol
		};
		println@Console("[Network Visualizer]: Ricezione blockchain da: " + i + " nodo -> " + pB.location + " - " + pB.protocol + "..")();
			// Salvo tutte le blockchain dei vari blocchi, quella più lunga è la ufficiale
		riceviBlockchain@portaBroadcast()(blockchainTemp);
		global.blockchain[i] = blockchainTemp;
		if(#blockchainTemp.block > global.officialBlockchain){
			global.puntBlockchain = i;
			global.officialBlockchain = blockchain[i]
		}
		// Stampare transazioni nella blockchain e wallet (TODO)
	}
}