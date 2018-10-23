include "time.iol"
include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "semaphore_utils.iol"
//porte input 

//per nodo1
inputPort PP13 {
	Location: "socket://localhost:9020"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}


//per networkVisualizer
inputPort PP18 {
	Location: "socket://localhost:9090"
	Protocol: sodep
	Interfaces: BlockchainInterface 
}

//porte output

//nodo1
outputPort PP14 {
	Location: "socket://localhost:9030"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}
//nodo2
outputPort PP15 {
	Location: "socket://localhost:9040"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}
//nodo3
outputPort PP16 {
	Location: "socket://localhost:9050"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}

//nodo4
outputPort PP17 {
	Location: "socket://localhost:9060"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}

//network visualizer
outputPort PP30 {
	Location: "socket://localhost:9100"
	Protocol: sodep
	Interfaces: BlockchainInterface 
}


execution { concurrent }

init
  {
    semaforo1pow.name = "Semaforo prima Pow";
    semaforo1pow.permits = 1;
    release@SemaphoreUtils(semaforo1pow)(res)

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

  [finePOW(nomeNodo)(nodoprimo){
 
   acquire@SemaphoreUtils(semaforo1pow)(res);

   //sezione critica
   nodoprimo = nomeNodo;
  
  	//mando agli altri nodi il nome del nodo che ha finio per primo la POW
   	fineSemaforo@PP14(nodoprimo)
   	;
   	fineSemaforo@PP15(nodoprimo)
   	;
   	fineSemaforo@PP16(nodoprimo)
   	;
   	fineSemaforo@PP17(nodoprimo)
   ;

    release@SemaphoreUtils(semaforo1pow)(res)
   
  }]

/*  servizio per il download della blockchain 
  attuale*/

  [invioBlockchain(blockchainAttuale)]{
  	
  	blockchainAttuale@PP14(blockchainAttuale)
   	;
   	blockchainAttuale@PP15(blockchainAttuale)
   	;
   	blockchainAttuale@PP16(blockchainAttuale)
   	;
   	blockchainAttuale@PP17(blockchainAttuale)
  }


// Invio informazioni nodi

	[informazioniNodo1(nodo1)]{
		invioInformazioniNodo1@PP30(nodo1)
	}
	[informazioniNodo2(nodo2)]{
		invioInformazioniNodo2@PP30(nodo2)
	}
	[informazioniNodo3(nodo3)]{
		invioInformazioniNodo3@PP30(nodo3)
	}
	[informazioniNodo4(nodo4)]{
		invioInformazioniNodo4@PP30(nodo4)
	}

// Richiesta numero jollar per Nodo

	[numeroJollarNodo1(numeroJollarNodo1)]{
		richiestaNumeroJollarNodo1@PP30(numeroJollarNodo1)
	}
	

	[numeroJollarNodo2(numeroJollarNodo2)]{
		richiestaNumeroJollarNodo2@PP30(numeroJollarNodo2)
	}
	

	[numeroJollarNodo3(numeroJollarNodo3)]{
		richiestaNumeroJollarNodo3@PP30(numeroJollarNodo3)
	}
	

	[numeroJollarNodo4(numeroJollarNodo4)]{
		richiestaNumeroJollarNodo4@PP30(numeroJollarNodo4)
	}

}


