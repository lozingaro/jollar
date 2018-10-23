include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"

// outputPort per comunicare con server timestamp

outputPort TIMESTAMP {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: BlockchainInterface
}

// inputPort per server timestamp

inputPort NETWORK {
	Location: "socket://localhost:8005"
	Protocol: sodep
	Interfaces: BlockchainInterface
}

// Prima porzione di codice da eseguire ancor prima del main

init
{
	println@Console( "BENVENUTO NEL NETWORK VISUALIZER." )();
	println@Console( "*________________________________*" )();
  println@Console( "Aspetto informazioni autostoppisti..." )();

  //riceve le informazioni relative ai nodi
  [sendInfoNode1(nodo1)];

  [sendInfoNode2(nodo2)];

  [sendInfoNode3(nodo3)];

  [sendInfoNode4(nodo4)];

  {
  	[sendBlockChainNetwork(newBlockChain)]
  	|
  	[qstjollarNumbNodo1(jollarNumbNetworkNodo1)]
  	|
  	[qstjollarNumbNodo2(jollarNumbNetworkNodo2)]
  	|
  	[qstjollarNumbNodo3(jollarNumbNetworkNodo3)]
  	|
  	[qstjollarNumbNodo4(jollarNumbNetworkNodo4)]
    }
}

// Main procedure
main
{
  registerForInput@Console()();
  println@Console( "Vuoi conoscere lo stato delle blockchain di tutti i nodi? Y/N" )();
  in(risposta);
  if( risposta == "Y" || risposta =="y"  ) {


    println@Console( "-----------------------------------" )();
    println@Console( "Ho scaricato la blockchain attuale." )();
    println@Console( "-----------------------------------" )();

  	// data e ora
    println@Console( "Data e ora al momento dell'attuale richiesta: " )();
    serverTimestamp@TIMESTAMP("Ora attuale")(dataOraAttuale);
    println@Console( dataOraAttuale)();

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative all'AUTOSTOPPISTA (nodo1): " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo1.publicKey )();
    println@Console( "Transazioni effettuate: " )();
    println@Console( "" )();

    // prima transazione
		println@Console( "--------------------------------" )();
    println@Console( "Prima transazione: " )();
    println@Console( "Hash prima transazione: " + newBlockChain.block[1].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[1].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[1].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo2.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[1].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();
   	println@Console( "--------------------------------" )();
   	// seconda transazione

    println@Console( "" )();
		println@Console( "--------------------------------" )();
    println@Console( "Seconda transazione: " )();
    println@Console( "Hash seconda transazione: " + newBlockChain.block[2].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[2].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[2].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[2].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();
    println@Console( "--------------------------------" )();
    // terza transazione

    println@Console( "" )();
		println@Console( "--------------------------------" )();
    println@Console( "Terza transazione: " )();
    println@Console( "Hash terza transazione: " + newBlockChain.block[3].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[3].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[3].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo4.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[3].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();
		println@Console( "--------------------------------" )();
    // numero di jollar in portafoglio
    println@Console( "Numero di jollar presenti nel portafoglio dell'AUTOSTOPPISTA 1 = "+ jollarNumbNetworkNodo1 )();



    /*
    	Informazioni nodo2
     */
    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative all'AUTOSTOPPISTA (nodo2): " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo2.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + newBlockChain.block[1].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[1].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[1].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo2.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[1].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio dell'AUTOSTOPPISTA 2 = "+ jollarNumbNetworkNodo2 )();


    /*
    	Informazioni nodo3
     */

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative all'AUTOSTOPPISTA (nodo3): " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo3.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + newBlockChain.block[2].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[2].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[2].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[2].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio dell'AUTOSTOPPISTA 3 = "+ jollarNumbNetworkNodo3 )();


 	/*
    	Informazioni nodo4
     */

    println@Console( "--------------------------------" )();
    println@Console( "Informazioni relative all'AUTOSTOPPISTA (nodo4): " )();
    println@Console( "--------------------------------" )();

    println@Console( "Chiave pubblica: " + nodo4.publicKey )();
    println@Console( "Transazioni effettuate: 0" )();
    println@Console( "" )();
    println@Console( "Transazione ricevuta: 1" )();
    println@Console( "Hash transazione: " + newBlockChain.block[3].transaction.hash_transaction )();
    println@Console( "Data e ora della transazione: " + newBlockChain.block[3].transaction.timestamp )();
    println@Console( "Nodo seller: " + newBlockChain.block[3].transaction.nodeSeller + " con chiave pubblica: "
    	+ nodo3.publicKey)();
    println@Console( "Nodo buyer: " + newBlockChain.block[3].transaction.nodeBuyer + " con chiave pubblica: "
    	+ nodo1.publicKey)();

    println@Console( "Numero di jollar presenti nel portafoglio dell'AUTOSTOPPISTA 4 = "+ jollarNumbNetworkNodo4 )();

    println@Console( "" )();
    println@Console( "Ho scaricato la blockchain piu' lunga presente nella rete." )();
    println@Console( "***********************************" )();
	  println@Console( "ADDIO E GRAZIE PER TUTTO IL PESCE!" )();
    println@Console( "***********************************" )()
  }
}
