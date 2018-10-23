include "time.iol"
include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "semaphore_utils.iol"
include "POW.ol"
//porte input

//porte di comunicazione da e per i nodi
inputPort TIMESTAMP {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo1
outputPort NODO1 {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo2
outputPort NODO2 {
	Location: "socket://localhost:8002"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo3
outputPort NODO3 {
	Location: "socket://localhost:8003"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo4
outputPort NODO4 {
	Location: "socket://localhost:8004"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//networkvisualizer
outputPort NETWORK {
	Location: "socket://localhost:8005"
	Protocol: sodep
	Interfaces: BlockchainInterface
}


execution { concurrent }

init
  {
    semaphore.name = "critics";
    semaphore.permits = 1;
    release@SemaphoreUtils(semaphore)(res);
		println@Console( "*_________________________*" )();
		println@Console( "IO SONO PENSIERO PROFONDO." )();
		println@Console( "*_________________________*" )()
  }

main
{
 	/*
 		Servizio che determina l'ora esatta
 		quando arriva la richiesta
 	 */
  [serverTimestamp(richiesta)(ora){
    getCurrentDateTime@Time()(orario);
    ora = orario
   }]

   /*
   	Servizio che determina quale nodo finisce per primo
   	la proof of work
    */
  [endPOW(node)(first){

   acquire@SemaphoreUtils(semaphore)(res);

   //sezione critica
   first = node;

  	//mando agli altri nodi il nome del nodo che ha finio per primo la POW
   	endCritics@NODO1(first)
   	;
   	endCritics@NODO2(first)
   	;
   	endCritics@NODO3(first)
   	;
   	endCritics@NODO4(first)
   	;
    release@SemaphoreUtils(semaphore)(res)
  }]

/*  servizio per il download della blockchain
  attuale*/
  [sendBlockChain(newBlockChain)]{

  	sendBlockChain@NODO1(newBlockChain)
   	|
   	sendBlockChain@NODO2(newBlockChain)
   	|
   	sendBlockChain@NODO3(newBlockChain)
   	|
   	sendBlockChain@NODO4(newBlockChain)
  }


// Invio informazioni nodi
	[infoNode1(nodo1)]{
		sendInfoNode1@NETWORK(nodo1)
	}
	[infoNode2(nodo2)]{
		sendInfoNode2@NETWORK(nodo2)
	}
	[infoNode3(nodo3)]{
		sendInfoNode3@NETWORK(nodo3)
	}
	[infoNode4(nodo4)]{
		sendInfoNode4@NETWORK(nodo4)
	}

// Richiesta numero jollar per Nodo
	[jollarNumbNodo1(jollarNumbNodo1)]{
		qstjollarNumbNodo1@NETWORK(jollarNumbNodo1)
	}
	[jollarNumbNodo2(jollarNumbNodo2)]{
		qstjollarNumbNodo2@NETWORK(jollarNumbNodo2)
	}
	[jollarNumbNodo3(jollarNumbNodo3)]{
		qstjollarNumbNodo3@NETWORK(jollarNumbNodo3)
	}
	[jollarNumbNodo4(jollarNumbNodo4)]{
		qstjollarNumbNodo4@NETWORK(jollarNumbNodo4)
	}

}
