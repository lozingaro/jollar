include "interface.iol"
include "console.iol"

outputPort B {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: MyInterface
}

main
{
    x.x = 5;
    sendNumber@B( x )
}
