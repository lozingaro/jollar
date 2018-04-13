outputPort Out {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: count( void ), print( int )
}

define runCount {
	if( idx-- > 0 ){
		runCount | count@Out()
	}
}

main
{
	for (i=0, i<10, i++) {
		idx = run = 100;
		runCount;
		print@Out( run )
	}
}