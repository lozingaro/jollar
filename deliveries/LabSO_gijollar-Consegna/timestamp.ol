include "clientInterface.iol"
include "time.iol"
include "console.iol"

outputPort client1 {
    Location: "socket://localhost:8001/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort client2 {
    Location: "socket://localhost:8002/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort client3 {
    Location: "socket://localhost:8003/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort client4 {
    Location: "socket://localhost:8004/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort networkVisualizer {
    Location: "socket://localhost:8007/"
    Protocol: sodep
    Interfaces: ClientInterface
}

inputPort MyInport {
    Location: "socket://localhost:8006/"
    Protocol: sodep
    Interfaces: ClientInterface
}

execution{ concurrent }

main{
  [requestTime(request)(response) {
    getCurrentTimeMillis@Time()( time );
    response = time
  }]

  [requestDate(request)(response) {
    getCurrentTimeMillis@Time()( time );
    getDateTime@Time( time )( date );
    response = date
  }]
}
