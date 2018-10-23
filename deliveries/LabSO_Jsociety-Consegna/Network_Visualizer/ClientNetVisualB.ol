include "time.iol"
include "console.iol"
include "NetInterface.iol"

//dichiaro output port per mandare informazioni al server time stamp
outputPort ToServer{
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: NetInterface
}



//invio informazioni al network visualizer
outputPort ToNetworkVisualizer {
	Location: "socket://localhost:1026"
	Protocol: sodep
	Interfaces: NetInterface
}


//dichiaro una input port per ricevere informazioni dal server time stamp
inputPort FromServer {
	Location: "socket://localhost:1028"
	Protocol: sodep
	Interfaces: NetInterface


}

init{

	global.check = 0;
	global.timeStampB = 0
}

main{
	//il tipo client che ho creato nell'interfaccia e' formato da una stringa
	//contenente il nome del client che sta inviando la risposta ed un intero
	//l'intero viene usato come valore di controllo per evitare un correlation error 
	clientInfo.name = "client B";
	clientInfo.value = 1;

     //sendACK invia le informazioni precedenti al server time stamp e si aspeta
	// un valore di controllo di ritorno, ovvero un intero 5
	sendACK@ToServer(clientInfo)(back);

    //la variabile di controllo assume il valore 5
	global.check = back;	
	
	
	//se il valore viene reinviato correttamente il client esegue una serie di funzioni
	if(global.check == 5){

		//receiveTime riceve il tempo in millisec inviato dal server
		receiveTime(result)();
		//salvo il tempo sulla variabile timeStampB per utilizzi futuri
		global.timeStampB = result;
		//stampo su console il valore ottenuto
		println@Console("time stamp del client B:" + global.timeStampB)();
		//azzero variabili di controllo 
		global.check = 0
	}

}