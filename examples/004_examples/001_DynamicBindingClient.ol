include "console.iol"
include "types/Binding.iol"

inputPort InSodep {
Location: "socket://localhost:8001"
Protocol: sodep
OneWay: contact( string )
}

inputPort InSoap {
Location: "socket://localhost:8002"
Protocol: soap
OneWay: contact( string )
}

outputPort DynamicBindingServer {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: subscribeForContact( Binding )
}


main
{
	subscribeForContact@DynamicBindingServer( global.inputPorts.InSodep );
	contact( s );	println@Console( s )();
	subscribeForContact@DynamicBindingServer( global.inputPorts.InSoap );
	contact( s );	println@Console( s )()
}