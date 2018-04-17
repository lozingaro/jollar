include "interface.iol"
include "console.iol"

inputPort MyInput {
    Location: "socket://localhost:8000/"
    Protocol: sodep
    Interfaces: MyInterface
}

main
{
    sendNumber( x ); // Receive x from any client
    println@Console( "il numero inviato è " + x.x)()
}
