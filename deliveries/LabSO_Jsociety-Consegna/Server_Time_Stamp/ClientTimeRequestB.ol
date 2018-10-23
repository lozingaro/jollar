include "console.iol"
include "TimeInterface.iol"

//dichiaro output port per mandare informazioni al server time stamp
outputPort ToServer{
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: TimeInterface
}


//dichiaro una input port per ricevere informazioni
inputPort FromServer {
	Location: "socket://localhost:1024/"
	Protocol: sodep
	Interfaces: TimeInterface
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
		timeStampB = result;
		//stampo su console il valore ottenuto
		println@Console("client B:" + timeStampB)();

		//azzero variabili di controllo 
		global.check = 0
	}

}