
include "time.iol"
include "console.iol"
include "TimeInterface.iol"


//execution{ concurrent } //lascia il server attivo
execution{ concurrent }

//dichiaro porta in input per ricevere informazioni dai client
inputPort FromClient {
	Location: "socket://localhost:8000/"
	Protocol: sodep
	Interfaces: TimeInterface
}


//dichiaro porta in output per inviare invormazioni 
outputPort ToClient{
    Location: "socket://localhost:1024"
    Protocol: sodep
    Interfaces: TimeInterface
}


//nell'init dichiaro che il server viene avviato correttamente
//inoltre aggiungo una variabile di controllo da usare per evitare di avere correlation error 
//durante l'utilizzo delle operations di time.iol
init{
  println@Console("server avviato")();
  global.ack = 0
}




main{

//ricevo le informazioni sul tipo di client e invio un 5 come risposta che ho ricevuto tutto
sendACK(receivedClientInfo)(5);
//salvo i valori ottenuti da sendACK in due variabili in modo da porterne disporre
global.ack = receivedClientInfo.value;
global.clientName = receivedClientInfo.name;

	//se le variabili ricevute sono corrette inizio ad eseguire una serie di funzioni
	if(global.ack == 1){

		//interrogo Time per sapere i millisecondi di tempo attuale
		getCurrentTimeMillis@Time()( millis );
		//salvo il tempo ottenuto in una variabile
		realTime = millis;
		//invio il tempo al client che me lo ha richiesto
		receiveTime@ToClient(realTime)();
		//stampo a quale client ho inviato il tempo
		println@Console("inviato tempo a " + global.clientName)();
		//azzero variabili di controllo 
		global.ack = 0;
		global.clientName = null
		}

}