include "console.iol"
include "types/Binding.iol"

inputPort In {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: subscribeForContact( Binding )
}

outputPort Out {
OneWay: contact( string )
}

execution{ concurrent }

main
{
	subscribeForContact( Out );
	println@Console( "Out.location: " + Out.location )();
	println@Console( "Out.protocol: " + Out.protocol )();
	contact@Out( Out.protocol + ": Hello World!" )
}