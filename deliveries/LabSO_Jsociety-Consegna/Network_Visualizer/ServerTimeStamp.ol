
include "time.iol"
include "console.iol"
include "NetInterface.iol"


//execution{ concurrent } //lascia il server attivo
execution{ concurrent }

//dichiaro porta in input per ricevere informazioni dai client
inputPort FromClient {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: NetInterface
}


//dichiaro porta in output per inviare invormazioni al client
outputPort ToClientNet{
	Location: "socket://localhost:1028"
	Protocol: sodep
	Interfaces: NetInterface
}

//porta in input che riceve l'interrogazione da parte del NetworkVisualizer
inputPort FromNetworkVisualizer{
	Location: "socket://localhost:1030"
	Protocol: sodep
	Interfaces: NetInterface
}

outputPort ToNetworkVisualizer{
	Location: "socket://localhost:1031"
	Protocol: sodep
	Interfaces: NetInterface
}



//nell'init dichiaro che il server viene avviato correttamente
//inoltre aggiungo una variabile di controllo da usare per evitare di avere correlation error 
//durante l'utilizzo delle operations di time.iol
init{
	println@Console("server avviato")();
	
	global.ack = 0;
  
	global.timeStampMillisec[0] = 0;//0 e' il nodo A
	global.timeStampMillisec[1] = 0;//1 e' il nodo B
	global.timeStampMillisec[2] = 0;//2 e' il nodo C
	global.timeStampMillisec[3] = 0//3 e' il nodo D
}


main{

//ricevo le informazioni sul tipo di client e invio un 5 come risposta che ho 
//ricevuto tutto
	sendACK(receivedClientInfo)(5);

//salvo i valori ottenuti da sendACK in due variabili in modo da porterne disporre
	global.ack = receivedClientInfo.value;
	global.clientName = receivedClientInfo.name;

	//se le variabili ricevute sono corrette inizio ad eseguire una serie di funzioni
	if(global.ack == 1){

		//interrogo Time per sapere i millisecondi di tempo attuale
		getCurrentTimeMillis@Time()( millis );
		//salvo il tempo ottenuto in una variabile
		global.realTime = millis;

		getDateTime@Time(millis)(cacca);
		println@Console(cacca)();
		//invio il tempo al client che me lo ha richiesto
		receiveTime@ToClientNet(global.realTime)();
		//stampo a quale client ho inviato il tempo
		println@Console("inviato tempo a " + global.clientName)();

		//salvo in una variabile globale il timestamp di ogni nodo
		if(global.clientName == "client A"){
			global.timeStampMillisec[0] = global.realTime
		};
		if(global.clientName == "client B"){
			global.timeStampMillisec[1] = global.realTime
		};
		if(global.clientName == "client C"){
			global.timeStampMillisec[2] = global.realTime
		};
		if(global.clientName == "client D"){
			global.timeStampMillisec[3] = global.realTime
		};

		//azzero variabili di controllo 
		global.ack = 0;
		global.clientName = null
	};

	//ricevo una richiesta dal network visualizer
	
	if(global.ack == 7){

		//salvo i valori dei vari timestamp dentro una variabile timestampinfo
		//variabile creata nell'interfaccia netinterface e di tipo netVisualType
		timeStampInfo.nodoA = global.timeStampMillisec[0] ;
		timeStampInfo.nodoB = global.timeStampMillisec[1] ;
		timeStampInfo.nodoC = global.timeStampMillisec[2] ;
		timeStampInfo.nodoD = global.timeStampMillisec[3] ;
		//invio al network visualizer tutti i timestamp
		sendTimeStamp@ToNetworkVisualizer(timeStampInfo)();


	    //azzero variabile di controllo 
		global.ack = 0

	}


}