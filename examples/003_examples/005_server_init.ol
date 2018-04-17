include "console.iol"
include "time.iol"
include "math.iol"

inputPort In {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: start( void )
}

execution{ concurrent }

init
{
 	getCurrentDateTime@Time()( date )
}

main
{
	start();
	println@Console( "start date: " + date  )();
	random@Math()( delay );
	println@Console( 10000.0*delay )();
	sleep@Time( 10000.0*delay )();
	getCurrentDateTime@Time()( date );
	println@Console( "current date: " + date  )()
}