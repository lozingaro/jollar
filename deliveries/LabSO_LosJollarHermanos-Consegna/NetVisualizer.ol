include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "InterfaceTime2.iol"
include "file.iol"
include "math.iol"
include "time.iol"
include "message_digest.iol"
include "Interfaceservpeer.iol"
include "TransInterface.iol"
include "NetworkInterface.iol"

execution{ concurrent }

inputPort Network {
	Location: "socket://localhost:8010"
	Protocol: sodep
	Interfaces: NetworkInterface
}

outputPort Timeoutput {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: InterfaceTime2
}

init {
	println@Console("NETWORK VISUALIZER" + "\n")();
	println@Console("Attendo connessione di qualche nodo."+"\n")()
}

main {
	[sendString(flag)] {
		getTime@Timeoutput()(t);
		println@Console("\n" + "////////////////////////////////////////////" + "\n")();
		println@Console(t)();
		println@Console(flag)()

	}
}
