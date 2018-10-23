include "interface.iol"
include "time.iol"
include "console.iol"

inputPort SaaS {
	Location: "socket://localhost:7999"
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

execution{ concurrent }


main
{
  [timeRequest()(tempo){

  	getCurrentTimeMillis@Time()(ms);
  	tempo = ms;
	println@Console( ms )()

  }]


}