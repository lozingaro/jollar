include "Interfaccia.iol"
include "console.iol"
include "file.iol"

inputPort NetworkVisualizer {
 Location: "socket://localhost:8005"
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

outputPort ServerTimeStamp {
 Location: "socket://localhost:8006"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}

init {
 netConnesso @ServerTimeStamp("connesso");
 println @Console("|-----------------------------------------|")();
 println @Console("|              J O L L A R J$             |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|      BENVENUTO, SONO IN ATTESA DEL      |")();
 println @Console("|       COLLEGAMENTO DEL PRIMO NODO       |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|..........Attendo la connessione.........|")();
 println @Console("|-----------------------------------------|")()
}


main {
 collegamentoNodo1(nodo1);
 println @Console("Il primo nodo si e' appena collegato")();
 println @Console("Il suo id e'= " + nodo1.id)();
 i = 2;

 println @Console("In attesa del collegamento del nodo " + i)();
 collegamentoNodo2(nodo2);
 println @Console("Il nodo 2 si e' collegato")();
 println @Console("Il suo id = " + nodo2.id)();
 i++;

 println @Console("In attesa del collegamento del nodo " + i)();
 collegamentoNodo3(nodo3);
 println @Console("Il nodo 3 si e' collegato")();
 println @Console("Il suo id = " + nodo3.id)();
 i++;

 println @Console("In attesa del collegamento del nodo " + i)();
 collegamentoNodo4(nodo4);
 println @Console("Il nodo 4 si e' collegato")();
 println @Console("Il suo id = " + nodo4.id)();

 println @Console("|-----------------------------------------|")();
 println @Console("|     TUTTI I NODI SI SONO COLLEGATI      |")();
 println @Console("|-----------------------------------------|")();


 blockchainScaricata(ok);

 println @Console("|   I NODI HANNO SCARICATO LA BLOCKHAIN   |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|  UN NUOVO BLOCCO STA PER ESSERE CREATO  |")();
 println @Console("|-----------------------------------------|")();
 println @Console("| I NODI HANNO INIZIATO LA PROOF OF WORK  |")();
 println @Console("|-----------------------------------------|")();

 {
  [proofOfWorkTerminata(idPrimoNodo)("Primo")] | [proofOfWorkTerminata(idSecondoNodo)("Secondo")] | [proofOfWorkTerminata(idTerzoNodo)("Terzo")] | [proofOfWorkTerminata(idQuartoNodo)("Quarto")]
 };

 println @Console("|   IL PRIMO NODO AD AVER COMPLETATO LA   |")();
 println @Console("|        PROOF OF WORK, HA ID = " + idPrimoNodo + "         |")();
 println @Console("|-----------------------------------------|")();

 {
  jollarTotali(n1) |
   jollarTotali(n2) |
   jollarTotali(n3) |
   jollarTotali(n4)

 };



 jollarTotali = int(n1) + int(n2) + int(n3) + int(n4);
 println @Console("All'interno del Sistema \"J O L L A R - J$\" sono presenti " + jollarTotali + "J$")();

 println @Console("La BLOCKHAIN e' stato aggiornata")();

 println @Console("Tutti i nodi hanno scaricato la nuova blockchain")();


 println @Console("|-----------------------------------------|")();
 println @Console("|  UN NUOVO BLOCCO STA PER ESSERE CREATO  |")();
 println @Console("|-----------------------------------------|")();
 println @Console("| I NODI HANNO INIZIATO LA PROOF OF WORK  |")();
 println @Console("|-----------------------------------------|")();

 {
  [proofOfWorkTerminata(idPrimoNodo)("Primo")] | [proofOfWorkTerminata(idSecondoNodo)("Secondo")] | [proofOfWorkTerminata(idTerzoNodo)("Terzo")] | [proofOfWorkTerminata(idQuartoNodo)("Quarto")]
 };

 println @Console("|   IL PRIMO NODO AD AVER COMPLETATO LA   |")();
 println @Console("|        PROOF OF WORK, HA ID = " + idPrimoNodo + "         |")();
 println @Console("|-----------------------------------------|")();

 {
  jollarTotali(n1) |
   jollarTotali(n2) |
   jollarTotali(n3) |
   jollarTotali(n4)

 };



 jollarTotali = int(n1) + int(n2) + int(n3) + int(n4);
 println @Console("All'interno del Sistema \"J O L L A R - J$\" sono presenti " + jollarTotali + "J$")();

 println @Console("La BLOCKHAIN e' stato aggiornata")();

 println @Console("Tutti i nodi hanno scaricato la nuova blockchain")();

 println @Console("|-----------------------------------------|")();
 println @Console("|  UN NUOVO BLOCCO STA PER ESSERE CREATO  |")();
 println @Console("|-----------------------------------------|")();
 println @Console("| I NODI HANNO INIZIATO LA PROOF OF WORK  |")();
 println @Console("|-----------------------------------------|")();

 {
  [proofOfWorkTerminata(idPrimoNodo)("Primo")] | [proofOfWorkTerminata(idSecondoNodo)("Secondo")] | [proofOfWorkTerminata(idTerzoNodo)("Terzo")] | [proofOfWorkTerminata(idQuartoNodo)("Quarto")]
 };

 println @Console("|   IL PRIMO NODO AD AVER COMPLETATO LA   |")();
 println @Console("|        PROOF OF WORK, HA ID = " + idPrimoNodo + "         |")();
 println @Console("|-----------------------------------------|")(); {
  [jollarTotali(n1)] | [jollarTotali(n2)] | [jollarTotali(n3)] | [jollarTotali(n4)]

 };



 jollarTotali = int(n1) + int(n2) + int(n3) + int(n4);
 println @Console("All'interno del Sistema \"J O L L A R - J$\" sono presenti " + jollarTotali + "J$")();

 println @Console("La BLOCKHAIN e' stato aggiornata")();

 println @Console("Tutti i nodi hanno scaricato la nuova blockchain")();

 invioBlockchain(newBlockchain3);
 stampaBlockChain
}


define stampaBlockChain {
 println @Console("|-----------------------------------------|")();
 println @Console("|                BLOCKCHAIN               |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|               BLOCCO GENESI             |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|ID: " + newBlockchain3.block.id_blocco)();
 println @Console("|HASH: " + newBlockchain3.block.blockHash)();
 println @Console("|DIFFICULTY: " + newBlockchain3.block.difficulty)();
 println @Console("|-----------------------------------------|")();
 println @Console("|               BLOCCO UNO                |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|ID: " + newBlockchain3.block[1].id_blocco)();
 println @Console("|HASH: " + newBlockchain3.block[1].blockHash)();
 println @Console("|HASH PRECEDENTE: " + newBlockchain3.block[1].previousBlockHash)();
 println @Console("|LUNGHEZZA POW: " + newBlockchain3.block[1].lunghezzaProofOfWork)();
 println @Console("|DIFFICULTY: " + newBlockchain3.block[1].difficulty)();
 println @Console("|FIRMA: " + newBlockchain3.block[1].firma)();
 println @Console("|ID NODO SELLER: " + newBlockchain3.block[1].transaction.nodeSeller)();
 println @Console("|NODO BUYER: " + newBlockchain3.block[1].transaction.nodeBuyer)();
 println @Console("|JOLLAR INVIATI: " + newBlockchain3.block[1].transaction.jollar)();
 println @Console("|-----------------------------------------|")();
 println @Console("|               BLOCCO DUE                |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|ID: " + newBlockchain3.block[2].id_blocco)();
 println @Console("|HASH: " + newBlockchain3.block[2].blockHash)();
 println @Console("|HASH PRECEDENTE: " + newBlockchain3.block[2].previousBlockHash)();
 println @Console("|LUNGHEZZA POW: " + newBlockchain3.block[2].lunghezzaProofOfWork)();
 println @Console("|DIFFICULTY: " + newBlockchain3.block[2].difficulty)();
 println @Console("|FIRMA: " + newBlockchain3.block[2].firma)();
 println @Console("|ID NODO SELLER: " + newBlockchain3.block[2].transaction.nodeSeller)();
 println @Console("|NODO BUYER: " + newBlockchain3.block[2].transaction.nodeBuyer)();
 println @Console("|JOLLAR INVIATI: " + newBlockchain3.block[2].transaction.jollar)();
 println @Console("|-----------------------------------------|")();
 println @Console("|               BLOCCO TRE                |")();
 println @Console("|-----------------------------------------|")();
 println @Console("|ID: " + newBlockchain3.block[3].id_blocco)();
 println @Console("|HASH: " + newBlockchain3.block[3].blockHash)();
 println @Console("|HASH PRECEDENTE: " + newBlockchain3.block[3].previousBlockHash)();
 println @Console("|LUNGHEZZA POW: " + newBlockchain3.block[3].lunghezzaProofOfWork)();
 println @Console("|DIFFICULTY: " + newBlockchain3.block[3].difficulty)();
 println @Console("|FIRMA: " + newBlockchain3.block[3].firma)();
 println @Console("|ID NODO SELLER: " + newBlockchain3.block[3].transaction.nodeSeller)();
 println @Console("|NODO BUYER: " + newBlockchain3.block[3].transaction.nodeBuyer)();
 println @Console("|JOLLAR INVIATI: " + newBlockchain3.block[3].transaction.jollar)()

}