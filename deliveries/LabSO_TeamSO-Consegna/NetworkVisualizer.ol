// Newtwork Visualizer
include "INetworkVisualizer.iol"
include "console.iol"

inputPort NetworkVisualizer {
	Location: "socket://localhost:8055"
	Protocol: sodep
	Interfaces: INetworkVisualizer
}


init
{
	println@Console( "NewtorkVisualizer avviato.
		In attesa di log da mostrare." )()
}

execution{ sequential }

main
{
  [print(content)]{
  	println@Console( "----------------------------" )();
  	println@Console("Received message from : "+ content.from )();
  	println@Console( "Message : "+ content.message )();
  	println@Console( "La data attuale del nodo e' : "+ content.content.data )();
  	println@Console( "L'username e':"+content.content.user )();
  	println@Console( "La chiave pubblica e': "+content.content.pubkey )();
  	println@Console( "Le sue transazioni spendibili sono:" )();
  	for ( i=0, i<#content.content.utxo.result, i++ ) {
  		println@Console( "transazione n:"+i+" | Hash: "+content.content.utxo.result[i] )()
  	};

  	println@Console( "----------------------------" )()
  }
}