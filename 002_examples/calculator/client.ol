include "common.iol"
include "console.iol"

outputPort Calculator{
  Location: "socket://localhost:8001"
  Protocol: sodep
  Interfaces: CalculatorInterface
}

main
{
	root.x = int( args[0] );
	root.y = int( args[1] );
	sum@Calculator( root )( result );
	println@Console( result )()
}
