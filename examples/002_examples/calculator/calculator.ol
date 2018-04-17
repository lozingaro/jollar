include "common.iol"
include "console.iol"

execution{ concurrent }

// "http://localhost:8000/sum?x=3&y=4"

inputPort In {
  Location: "socket://localhost:8000"
  Protocol: http
  Interfaces: CalculatorInterface
}

inputPort In2 {
Location: "socket://localhost:8001"
Protocol: sodep
Interfaces: CalculatorInterface
}

main
{
	sum( a )( b ) {
        println@Console( a.x + " + " + a.y )();
		b = a.x + a.y
	}
}
