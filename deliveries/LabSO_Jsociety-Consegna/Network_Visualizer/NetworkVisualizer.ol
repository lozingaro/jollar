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


include "time.iol"
include "console.iol"
include "NetInterface.iol"


//porta di output che interroga server timestamp
outputPort ToServerTimeStamp{
	Location: "socket://localhost:1030"
	Protocol: sodep
	Interfaces: NetInterface
}


//riceve informazioni dai nodi 
inputPort FromTimeStamp{
	Location: "socket://localhost:1031"
	Protocol: sodep
	Interfaces: NetInterface
}

init{
	global.nodoPrimo = 0;
	global.nodoSecondo = 0;
	global.nodoTerzo = 0;
	global.nodoQuarto = 0
}

main{

// PARTE 1 di 4 -- > • La data e l’ora del server timestamp al momento della richiesta/////

	infoSend.value = 7;
	infoSend.name = "Network Visualizer";

//invio richiesta al server timestamp per sapere i millisec dei vari nodi
	sendACK@ToServerTimeStamp(infoSend)(infoReceive);
	back = infoReceive;

	if(back == 5){
//ricevo risposta dal server con i vari timestamp
		sendTimeStamp(value)();
		global.nodoPrimo = value.nodoA;
		global.nodoSecondo = value.nodoB;
		global.nodoTerzo = value.nodoC;
		global.nodoQuarto = value.nodoD

	};

		//trasformo il timestamp in una variabile di tipo GetDateTimeResponse
	​getDateTime@Time(global.nodoPrimo)(npd);
	global.nodoPrimoDate = npd;
	println@Console(global.nodoPrimoDate)();

	getDateTime@Time(global.nodoSecondo)(nsd);
	global.nodoSecondoDate = nsd;
	println@Console(global.nodoSecondoDate)();

	getDateTime@Time(global.nodoTerzo)(ntd);
	global.nodoTerzoDate = ntd;
	println@Console(global.nodoTerzoDate)();

	getDateTime@Time(global.nodoQuarto)(nqd);
	global.nodoQuartoDate = nqd;
	println@Console(global.nodoQuartoDate)()

//////////////////FINE PARTE 1 di 4//////////////////////////////////////////

}