include "console.iol"
include "Interfaccia.iol"
include "time.iol"

inputPort ServerTimeStamp {
 Location: "socket://localhost:8006"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

outputPort OutNodo1 {
 Location: "socket://localhost:8001"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

outputPort OutNodo2 {
 Location: "socket://localhost:8002"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

outputPort OutNodo3 {
 Location: "socket://localhost:8003"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

outputPort OutNodo4 {
 Location: "socket://localhost:8004"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

outputPort NetworkVisualizer {
 Location: "socket://localhost:8005"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}


main {
 println @Console("In attesa del Network Visualizer")();
 netConnesso(ok);
 println @Console("Il Network Visualizer si è connesso")();
 invioBlockchain(newBlockchain);


 println @Console("Ricevuto")();

 {
  invioBlockchainAggiornata @OutNodo1(newBlockchain) |
   invioBlockchainAggiornata @OutNodo2(newBlockchain) |
   invioBlockchainAggiornata @OutNodo3(newBlockchain) |
   invioBlockchainAggiornata @OutNodo4(newBlockchain)
 };

 getCurrentTimeMillis @Time()(dataOra);
 println @Console("La BLOCKCHAIN aggiornata e' stata inviata a tutti i nodi alle ore: " + dataOra)();

 invioBlockchain(newBlockchain2);


 println @Console("Ricevuto")();

 {
  invioBlockchainAggiornata @OutNodo1(newBlockchain2) |
   invioBlockchainAggiornata @OutNodo2(newBlockchain2) |
   invioBlockchainAggiornata @OutNodo3(newBlockchain2) |
   invioBlockchainAggiornata @OutNodo4(newBlockchain2)
 };


 getCurrentTimeMillis @Time()(dataOra);
 println @Console("La BLOCKCHAIN aggiornata e' stata inviata a tutti i nodi alle ore: " + dataOra)();


 invioBlockchain(newBlockchain3);


 println @Console("Ricevuto")();

 {
  invioBlockchainAggiornata @OutNodo1(newBlockchain3) |
   invioBlockchainAggiornata @OutNodo2(newBlockchain3) |
   invioBlockchainAggiornata @OutNodo3(newBlockchain3) |
   invioBlockchainAggiornata @OutNodo4(newBlockchain3)
 };

 getCurrentTimeMillis @Time()(dataOra);

 println @Console("La BLOCKCHAIN aggiornata e' stata inviata a tutti i nodi alle ore: " + dataOra)();

 invioBlockchain @NetworkVisualizer(newBlockchain3);


 println @Console("Il programma ha termiato l'esecuzione.")()
}