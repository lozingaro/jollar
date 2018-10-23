include "time.iol"
include "MainInterface.iol"
include "console.iol"

outputPort Time_Nodo {  //invia a a
  Protocol: sodep
  Interfaces: TimestampInterface
}

outputPort Time_Net {  //invia al network visualizer 
  Location: "socket://localhost:9000"
  Protocol: sodep
  Interfaces: DateInterface
}

inputPort Time {  //riceve richiesta
	Location:"socket://localhost:8100"
	Protocol: sodep
	Interfaces: TimestampInterface, DateInterface
}

execution{ concurrent }//single è quella di default se non metto nessuna esecuzione

main
{   
	[TimeRequestResponse(requestTime)(responseTime){
  		println@Console( requestTime )();
  		//assegnazione variabile della request alla location della porta
      
  		getCurrentTimeMillis@Time()( millis );
  		responseTime = millis	

  	}] {nullProcess} //serve per sintassi al compilatore per dirgli che il metodo è finito 

  [DateRequestResponse(requestDate)(responseDate){
      //println@Console( "ho ricevuto i millisecondi: "+request )(); //fin qui va bene 

      getDateTime@Time(requestDate)(data);
      responseDate=data //risponso al nodo
      //println@Console("ho convertito in: "+data)()
  }]{nullProcess}

}