outputPort Out {
Location: "socket://localhost:8000"
Protocol: sodep
OneWay: start( void )
}

main
{
  start@Out(); start@Out(); start@Out()
}