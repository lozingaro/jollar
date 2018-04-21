include "common.iol"
include "console.iol"

outputPort Calculator{
  Location: "socket://localhost:8001"
  Protocol: sodep
  Interfaces: CalculatorInterface
}

main
{
	root.x = 3.5;
	root.y = -4.5;
	sum@Calculator( root )( result );
	println@Console( result )()
}
