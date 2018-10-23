include "interface.iol"
include "console.iol"
include "time.iol"

inputPort MyInputA {
    Location: "socket://localhost:9010"
    Protocol: sodep
    Interfaces: Interfaccia
}

inputPort MyInputB {
Location: "socket://localhost:9020"
Protocol: sodep
Interfaces: Interfaccia
}

inputPort MyInputC {
Location: "socket://localhost:9030"
Protocol: sodep
Interfaces: Interfaccia
}

inputPort MyInputD {
    Location: "socket://localhost:9040"
    Protocol: sodep
    Interfaces: Interfaccia
}


main
{
    while (true)
    {
    sendNumber(x);
    getCurrentTimeMillis@Time()(y.y);
    requestTimeStampToServer(z)(y);
    println@Console(z.z)();
    println@Console("Invio il time stamp: " + y.y)()
    }
}
