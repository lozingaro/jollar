include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"

// outputPort per comunicare con server timestamp

outputPort PP18 {
	Location: "socket://localhost:9090"
	Protocol: sodep
	Interfaces: BlockchainInterface 
}

// inputPort per server timestamp

inputPort PP30 {
	Location: "socket://localhost:9100"
	Protocol: sodep
	Interfaces: BlockchainInterface 
}

// Prima porzione di codice da eseguire ancor prima del main

init
{

  println@Console( "aspetto informazioni nodi..." )();

  //riceve le informazioni relative ai nodi
  [invioInformazioniNodo1(nodo1)];
 
  [invioInformazioniNodo2(nodo2)];
  
  [invioInformazioniNodo3(nodo3)];

  [invioInformazioniNodo4(nodo4)];

  {
  	[invioBlockchainNetwork(blockchainAttuale)]
  	|
  	[richiestaNumeroJollarNodo1(numeroJollarNetworkNodo1)]
	|
	[richiestaNumeroJollarNodo2(numeroJollarNetworkNodo2)]
	|
	[richiestaNumeroJollarNodo3(numeroJollarNetworkNodo3)]
	|
	[richiestaNumeroJollarNodo4(numeroJollarNetworkNodo4)]
  }
}

// Main procedure

main
{
  println@Console( "BENVENUTO NEL NETWORK VISUALIZER" )();
  println@Console( "--------------------------------" )();
  registerForInput@Console()();
  println@Console( "Vuoi conoscere lo stato delle blockchain di tutti i nodi? Y/N" )();
  in(risposta);
  if( risposta == "Y" || risposta =="y"  ) {
    

    println@Console( "-----------------------------------" )();
    println@Console( "Ho scaricato la blockchain attuale." )();
    println@Console( "-----------------------------------" )();
  	
  	// data e ora
    
    println@Console( "Data e ora al momento dell'attuale richiesta: " )();
    serverTimestamp@PP18("ora attuale")(dataOraAttuale);
    println@Console( dataOraAttuale)();

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative al nodo1: " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo1.publicKey )();
    println@Console( "Transazioni effettuate: " )();
    println@Console( "" )();

    // prima transazione

    println@Console( "Prima transazione: " )();
    println@Console( "Hash prima transazione: " + blockchainAttuale.block[1].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[1].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[1].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo2.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[1].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();
   	
   	// seconda transazione

    println@Console( "" )();
    println@Console( "Seconda transazione: " )();
    println@Console( "Hash seconda transazione: " + blockchainAttuale.block[2].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[2].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[2].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[2].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();
    
    // terza transazione
    
    println@Console( "" )();
    println@Console( "Terza transazione: " )();
    println@Console( "Hash terza transazione: " + blockchainAttuale.block[3].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[3].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[3].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo4.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[3].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    // numero di jollar in portafoglio
    
    println@Console( "Numero di jollar presenti nel portafoglio del nodo1 = "+ numeroJollarNetworkNodo1 )();



    /*
    	Informazioni nodo2
     */


    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative al nodo2: " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo2.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + blockchainAttuale.block[1].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[1].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[1].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo2.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[1].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio del nodo2 = "+ numeroJollarNetworkNodo2 )();


    /*
    	Informazioni nodo3
     */

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative al nodo3: " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo3.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + blockchainAttuale.block[2].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[2].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[2].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[2].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio del nodo3 = "+ numeroJollarNetworkNodo3 )();
   	

 	/*
    	Informazioni nodo4
     */

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative al nodo4: " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo4.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + blockchainAttuale.block[3].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + blockchainAttuale.block[3].transaction.timestamp )();
    println@Console( "Nodo seller: " + blockchainAttuale.block[3].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + blockchainAttuale.block[3].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio del nodo4 = "+ numeroJollarNetworkNodo4 )();

    println@Console( "" )();
    println@Console( "Ho scaricato la blockchain piu' lunga presente nella rete." )();
    println@Console( "" )()
  }//fine if y
}