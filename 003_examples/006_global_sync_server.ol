include "console.iol"

inputPort In {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: count( void ), print( int )
}

execution{ concurrent }

main
{
	[ count() ]{ synchronized( t ){ global.i++ } }
	[ print( run ) ]{ println@Console( global.i )();
		println@Console( "missing: " + ( run - global.i ) )();
		undef( global.i )
	}
}