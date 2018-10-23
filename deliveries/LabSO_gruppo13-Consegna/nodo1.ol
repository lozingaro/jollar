include "console.iol"
include "Interfaccia.iol"
include "ui/swing_ui.iol"
include "message_digest.iol"
include "math.iol"
include "string_utils.iol"
include "time.iol"

inputPort InNodo1 {
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

outputPort ServerTimeStamp {
 Location: "socket://localhost:8006"
 Protocol: sodep
 Interfaces: InterfacciaJollar
}


main {
 println @Console("Hai accettato la connessione.")();
 md5 @MessageDigest("segreto1")(hashSegreto);
 md5 @MessageDigest("pubblico1")(hashPubblico);
 Nodo1.id = 1;
 Nodo1.publicKey = hashPubblico;
 Nodo1.privateKey = hashSegreto;
 Nodo1.jollarPosseduti = 6;

 collegamentoNodo1 @NetworkVisualizer(Nodo1);
 println @Console("Sei il primo nodo ad essersi collegato, con ID: " + Nodo1.id)();
 println @Console("In attesa che tutti gli altri nodi si colleghino.....")();

 nodiCollegati(ok);
 println @Console(ok)();

 creazioneBloccoGenesi;


 blockchain.block.id_blocco = bloccoGenesi.id_blocco;
 blockchain.block.blockHash = bloccoGenesi.blockHash;
 blockchain.block.previousBlockHash = bloccoGenesi.previousBlockHash;
 blockchain.block.difficulty = bloccoGenesi.difficulty;
 blockchain.block.timestamp = bloccoGenesi.timestamp;

 {
  invioBlockchain @OutNodo2(blockchain) |
   invioBlockchain @OutNodo3(blockchain) |
   invioBlockchain @OutNodo4(blockchain)
 };

 ok = "Scaricata";

 blockchainScaricata @NetworkVisualizer(ok);

 println @Console("|-------------------------------------------|")();
 println @Console("|             INFORMAZIONI NODO 1           |")();
 println @Console("|-------------------------------------------|")();


 println @Console("ID: " + Nodo1.id)();
 println @Console("Chiave pubblica: " + Nodo1.publicKey)();
 println @Console("Jollar Posseduti: " + Nodo1.jollarPosseduti)();

 registerForInput @Console()();

 println @Console("|-------------------------------------------|")();
 println @Console("|    VUOI EFFETTUARE UNA TRANSAZIONE? S/N   |")();
 println @Console("|-------------------------------------------|")(); in (risposta);

 if (risposta == "S" || risposta == "s") {
  if (Nodo1.jollarPosseduti > 0) {
   println @Console("Possiedi " + Nodo1.jollarPosseduti + " J$")();
   println @Console("Inserisci il nodo a cui vuoi inviare i J$ (e.g. nodo2, nodo3, nodo4)")(); in (nodo);
   println @Console("Inserire la quantità di J$ da trasferire ( < " + Nodo1.jollarPosseduti + ")")(); in (jollarInviati);
   jollarInviatiINT = int(jollarInviati);

   md5 @MessageDigest("transazioneUno")(firstTransaction);
   primaTransazione.hashTransazione = firstTransaction;
   primaTransazione.nodeSeller = Nodo1.id;
   primaTransazione.nodeBuyer = nodo;
   primaTransazione.jollar = jollarInviatiINT;

   nuovaTransazione @OutNodo2(primaTransazione)(res);
   println @Console(res)();
   Nodo1.jollarPosseduti = Nodo1.jollarPosseduti - jollarInviati;
   println @Console("Transazione effettuata!")();
   println @Console("Possiedi " + Nodo1.jollarPosseduti + "J$")();

   println @Console("|-------------------------------------------|")();
   println @Console("|        INVIO DELL'HASH A TUTTI NODI       |")();
   println @Console("|-------------------------------------------|")();

   {
    invioHashGenesi @OutNodo2(bloccoGenesi.blockHash) |
     invioHashGenesi @OutNodo3(bloccoGenesi.blockHash) |
     invioHashGenesi @OutNodo4(bloccoGenesi.blockHash)
   };

   println @Console("|-------------------------------------------|")();
   println @Console("|        INVIO DATI PRIMA TRANSAZIONE       |")();
   println @Console("|-------------------------------------------|")();

   {
    creazioneBloccoPrimo @OutNodo2(primaTransazione)(res);
    println @Console("Il nodo2 ha ricevuto i dati della transazione")() |
     creazioneBloccoPrimo @OutNodo3(primaTransazione)(res);
    println @Console("Il nodo3 ha ricevuto i dati della transazione")() |
     creazioneBloccoPrimo @OutNodo4(primaTransazione)(res);
    println @Console("Il nodo4 ha ricevuto i dati della transazione")()
   };

   {
    proofOfWork @OutNodo2("INIZIO PROOF OF WORK") |
     proofOfWork @OutNodo3("INIZIO PROOF OF WORK") |
     proofOfWork @OutNodo4("INIZIO PROOF OF WORK")
   };


   println @Console("|-------------------------------------------|")();
   println @Console("|      STO INIZIANDO LA PROOF OF WORK       |")();
   println @Console("|-------------------------------------------|")();

   pronto = "pronto";

   proofOfWork;

   while (controllo == false) {
    println @Console("non valido")();
    println @Console("again")();
    proofOfWork
   };

   println @Console("Valido")();

   proofOfWorkTerminata @NetworkVisualizer(Nodo1.id)(posizione);

   if (posizione == "Primo") {
    println @Console("Sei il primo nodo ad aver terminato la Proof of Work")();
    println @Console("Il sistema \"J O L L A R J$\" ti ricompensa con 6J$!")();
    Nodo1.jollarPosseduti = Nodo1.jollarPosseduti + 6;
    println @Console("Ora possiedi " + Nodo1.jollarPosseduti + "J$")();


    bloccoN1.id_blocco = 1;
    md5 @MessageDigest("hashPrimoBlocco")(hashPrimoBlocco);
    bloccoN1.blockHash = hashPrimoBlocco;
    bloccoN1.previousBlockHash = bloccoGenesi.blockHash;
    bloccoN1.difficulty = difficolta;
    bloccoN1.lunghezzaProofOfWork = lunghezzaCatenaPOW;
    getCurrentTimeMillis @Time()(tempo);
    valueToPrettyString@StringUtils(tempo)(pp);
    println@Console( pp )();
    bloccoN1.timestamp = tempo;
    bloccoN1.firma = Nodo1.privateKey;

    bloccoN1.transaction.hashTransazione = primaTransazione.hashTransazione;
    bloccoN1.transaction.nodeSeller = primaTransazione.nodeSeller;
    bloccoN1.transaction.nodeBuyer = primaTransazione.nodeBuyer;
    bloccoN1.transaction.jollar = primaTransazione.jollar;

    blockchain.block[1].id_blocco = bloccoN1.id_blocco;
    blockchain.block[1].blockHash = bloccoN1.blockHash;
    blockchain.block[1].previousBlockHash = bloccoN1.previousBlockHash;
    blockchain.block[1].difficulty = bloccoN1.difficulty;
    blockchain.block[1].lunghezzaProofOfWork = bloccoN1.lunghezzaProofOfWork;
    blockchain.block[1].timestamp = bloccoN1.timestamp;
    blockchain.block[1].firma = bloccoN1.firma;


    blockchain.block[1].transaction.hashTransazione = bloccoN1.transaction.hashTransazione;
    blockchain.block[1].transaction.nodeBuyer = bloccoN1.transaction.nodeBuyer;
    blockchain.block[1].transaction.nodeSeller = bloccoN1.transaction.nodeSeller;
    blockchain.block[1].transaction.jollar = bloccoN1.transaction.jollar;

    invioBlockchain @ServerTimeStamp(blockchain)

   } else if (posizione == "Quarto" || posizione == "Terzo" || posizione == "Secondo") {
    println @Console("Mi dispiace, ma sei arrivato " + posizione)()
   };

   invioBlockchainAggiornata(blockchainAggiornata);
   println @Console("La blockchain aggiornata e' stata scaricata")();
   jollarTotali @NetworkVisualizer(Nodo1.jollarPosseduti);


   println @Console("|-------------------------------------------|")();
   println @Console("|    VUOI EFFETTUARE UNA TRANSAZIONE? S/N   |")();
   println @Console("|-------------------------------------------|")(); in (risposta);

   if (risposta == "S" || risposta == "s") {
    if (Nodo1.jollarPosseduti > 0) {
     println @Console("Possiedi " + Nodo1.jollarPosseduti + " J$")();
     println @Console("Inserisci il nodo a cui vuoi inviare i J$")(); in (nodo);
     println @Console("Inserisci la quantità di J$ da trasferire ( < " + Nodo1.jollarPosseduti + ")")(); in (jollarInviati);
     jollarInviatiINT = int(jollarInviati);

     md5 @MessageDigest("transazioneDue")(secondTransaction);
     secondaTransazione.hashTransazione = secondTransaction;
     secondaTransazione.nodeSeller = Nodo1.id;
     secondaTransazione.nodeBuyer = nodo;
     secondaTransazione.jollar = jollarInviatiINT;

     nuovaTransazione @OutNodo3(secondaTransazione)(res);
     println @Console(res)();
     Nodo1.jollarPosseduti = Nodo1.jollarPosseduti - jollarInviatiINT;
     println @Console("Transazione effettuata!")();
     println @Console("Possiedi " + Nodo1.jollarPosseduti + " J$")();

     println @Console("|-------------------------------------------|")();
     println @Console("|      INVIO DATI SECONDA TRANSAZIONE       |")();
     println @Console("|-------------------------------------------|")();

     {
      creazioneBloccoSecondo @OutNodo2(secondaTransazione)(res);
      println @Console("Il nodo2 ha ricevuto i dati della transazione")() |
       creazioneBloccoSecondo @OutNodo3(secondaTransazione)(res);
      println @Console("Il nodo3 ha ricevuto i dati della transazione")() |
       creazioneBloccoSecondo @OutNodo4(secondaTransazione)(res);
      println @Console("Il nodo4 ha ricevuto i dati della transazione")()
     };

     {
      proofOfWork @OutNodo2("INIZIO PROOF OF WORK") |
       proofOfWork @OutNodo3("INIZIO PROOF OF WORK") |
       proofOfWork @OutNodo4("INIZIO PROOF OF WORK")
     };

     scaricata = "Scaricata";

     println @Console("|-------------------------------------------|")();
     println @Console("|      STO INIZIANDO LA PROOF OF WORK       |")();
     println @Console("|-------------------------------------------|")();

     proofOfWork;

     while (controllo == false) {
      println @Console("non valido")();
      println @Console("again")();
      proofOfWork
     };

     println @Console("Valido")();


     proofOfWorkTerminata @NetworkVisualizer(Nodo1.id)(posizione);

     println @Console(posizione)();

     if (posizione == "Primo") {
      println @Console("Sei il primo nodo ad aver terminato la Proof of Work")();
      println @Console("Il sistema \"J O L L A R J$\" ti ricompensa con 6J$!")();
      Nodo1.jollarPosseduti = Nodo1.jollarPosseduti + 6;
      println @Console("Ora possiedi " + Nodo1.jollarPosseduti + "J$")();

      bloccoN2.id_blocco = 2;
      md5 @MessageDigest("hashSecondoBlocco")(hashSecondoBlocco);
      bloccoN2.previousBlockHash = blockchainAggiornata.block[1].blockHash;
      bloccoN2.blockHash = hashSecondoBlocco;
      bloccoN2.difficulty = difficolta;
      bloccoN2.lunghezzaProofOfWork = lunghezzaCatenaPOW;
      getCurrentTimeMillis @Time()(tempo);
      bloccoN2.timestamp = tempo;
      bloccoN2.firma = Nodo1.privateKey;


      bloccoN2.transaction.hashTransazione = secondaTransazione.hashTransazione;
      bloccoN2.transaction.nodeSeller = secondaTransazione.nodeSeller;
      bloccoN2.transaction.nodeBuyer = secondaTransazione.nodeBuyer;
      bloccoN2.transaction.jollar = secondaTransazione.jollar;

      blockchainAggiornata.block[2].id_blocco = bloccoN2.id_blocco;
      blockchainAggiornata.block[2].blockHash = bloccoN2.blockHash;
      blockchainAggiornata.block[2].previousBlockHash = bloccoN2.previousBlockHash;
      blockchainAggiornata.block[2].difficulty = bloccoN2.difficulty;
      blockchainAggiornata.block[2].lunghezzaProofOfWork = bloccoN2.lunghezzaProofOfWork;
      blockchainAggiornata.block[2].timestamp = bloccoN2.timestamp;
      blockchainAggiornata.block[2].firma = bloccoN2.firma;


      blockchainAggiornata.block[2].transaction.hashTransazione = bloccoN2.transaction.hashTransazione;
      blockchainAggiornata.block[2].transaction.nodeBuyer = bloccoN2.transaction.nodeBuyer;
      blockchainAggiornata.block[2].transaction.nodeSeller = bloccoN2.transaction.nodeSeller;
      blockchainAggiornata.block[2].transaction.jollar = bloccoN2.transaction.jollar;

      invioBlockchain @ServerTimeStamp(blockchainAggiornata)

     } else if (posizione == "Quarto" || posizione == "Terzo" || posizione == "Secondo") {
      println @Console("Mi dispiace, sei arrivato " + posizione)()
     };

     invioBlockchainAggiornata(blockchainAggiornata);
     println @Console("La blockchain aggiornata e' stata scaricata")();
     jollarTotali @NetworkVisualizer(Nodo1.jollarPosseduti);

     println @Console("In attesa di operazioni.......")();

     println @Console("|-------------------------------------------|")();
     println @Console("|    VUOI EFFETTUARE UNA TRANSAZIONE? S/N   |")();
     println @Console("|-------------------------------------------|")(); in (risposta);

     if (risposta == "S" || risposta == "s") {
      if (Nodo1.jollarPosseduti > 0) {
       println @Console("Possiedi " + Nodo1.jollarPosseduti + " J$")();
       println @Console("Inserisci il nodo a cui vuoi inviare i J$ (e.g. nodo2, nodo3, nodo4")(); in (nodo);
       println @Console("Inserire la quantità J$ da trasferire ( < " + Nodo1.jollarPosseduti + ")")(); in (jollarInviati);
       jollarInviatiINT = int(jollarInviati);

       md5 @MessageDigest("transazioneTre")(thirdTransaction);
       terzaTransazione.hashTransazione = thirdTransaction;
       terzaTransazione.nodeSeller = Nodo1.id;
       terzaTransazione.nodeBuyer = nodo;
       terzaTransazione.jollar = jollarInviatiINT;

       nuovaTransazione @OutNodo4(terzaTransazione)(res);
       println @Console(res)();
       Nodo1.jollarPosseduti = Nodo1.jollarPosseduti - jollarInviati;
       println @Console("Transazione effettuata!")();
       println @Console("Possiedi " + Nodo1.jollarPosseduti + "J$")();

       println @Console("|-------------------------------------------|")();
       println @Console("|        INVIO DATI TERZA TRANSAZIONE       |")();
       println @Console("|-------------------------------------------|")();

       {
        creazioneBloccoTerzo @OutNodo2(terzaTransazione)(res);
        println @Console("Il nodo2 ha ricevuto i dati della transazione")() |
         creazioneBloccoTerzo @OutNodo3(terzaTransazione)(res);
        println @Console("Il nodo3 ha ricevuto i dati della transazione")() |
         creazioneBloccoTerzo @OutNodo4(terzaTransazione)(res);
        println @Console("Il nodo4 ha ricevuto i dati della transazione")()
       };

       {
        proofOfWork @OutNodo2("INIZIO PROOF OF WORK") |
         proofOfWork @OutNodo3("INIZIO PROOF OF WORK") |
         proofOfWork @OutNodo4("INIZIO PROOF OF WORK")
       };

       scaricata = "Scaricata";

       println @Console("|-------------------------------------------|")();
       println @Console("|      STO INIZIANDO LA PROOF OF WORK       |")();
       println @Console("|-------------------------------------------|")();

       proofOfWork;

       while (controllo == false) {
        println @Console("non valido")();
        println @Console("again")();
        proofOfWork
       };

       println @Console("Valido")();

       proofOfWorkTerminata @NetworkVisualizer(Nodo1.id)(posizione);

       println @Console(posizione)();
       if (posizione == "Primo") {
        println @Console("Sei il primo nodo ad aver terminato la Proof of Work")();
        println @Console("Il sistema \"J O L L A R J$\" ti ricompensa con 6J$!")();
        Nodo1.jollarPosseduti = Nodo1.jollarPosseduti + 6;
        println @Console("Ora possiedi " + Nodo1.jollarPosseduti + "J$")();

        bloccoN3.id_blocco = 3;
        md5 @MessageDigest("hashTerzoBlocco")(hashTerzoBlocco);
        bloccoN3.previousBlockHash = blockchainAggiornata.block[2].blockHash;
        bloccoN3.blockHash = hashTerzoBlocco;
        bloccoN3.difficulty = difficolta;
        bloccoN3.lunghezzaProofOfWork = lunghezzaCatenaPOW;
        getCurrentTimeMillis @Time()(tempo);
        bloccoN3.timestamp = tempo;
        bloccoN3.firma = Nodo1.privateKey;

        bloccoN3.transaction.hashTransazione = secondaTransazione.hashTransazione;
        bloccoN3.transaction.nodeSeller = secondaTransazione.nodeSeller;
        bloccoN3.transaction.nodeBuyer = secondaTransazione.nodeBuyer;
        bloccoN3.transaction.jollar = secondaTransazione.jollar;

        blockchainAggiornata.block[3].id_blocco = bloccoN3.id_blocco;
        blockchainAggiornata.block[3].blockHash = bloccoN3.blockHash;
        blockchainAggiornata.block[3].previousBlockHash = bloccoN3.previousBlockHash;
        blockchainAggiornata.block[3].difficulty = bloccoN3.difficulty;
        blockchainAggiornata.block[3].lunghezzaProofOfWork = bloccoN3.lunghezzaProofOfWork;
        blockchainAggiornata.block[3].timestamp = bloccoN3.timestamp;
        blockchainAggiornata.block[3].firma = bloccoN3.firma;

        blockchainAggiornata.block[3].transaction.hashTransazione = bloccoN3.transaction.hashTransazione;
        blockchainAggiornata.block[3].transaction.nodeBuyer = bloccoN3.transaction.nodeBuyer;
        blockchainAggiornata.block[3].transaction.nodeSeller = bloccoN3.transaction.nodeSeller;
        blockchainAggiornata.block[3].transaction.jollar = bloccoN3.transaction.jollar;

        invioBlockchain @ServerTimeStamp(blockchainAggiornata)

       } else if (posizione == "Quarto" || posizione == "Terzo" || posizione == "Secondo") {
        println @Console("Mi dispiace, sei arrivato " + posizione)()
       };

       invioBlockchainAggiornata(blockchainAggiornata);
       println @Console("La blockchain aggiornata e' stata scaricata")();
       jollarTotali @NetworkVisualizer(Nodo1.jollarPosseduti);

       println @Console("J$")()
      }
     }
    }
   }

  } else {
   println @Console("Impossibile effettuare la Transazione")()
  }
 }
}

define creazioneBloccoGenesi {
 bloccoGenesi.id_blocco = 0;
 md5 @MessageDigest("HashBloccoGenesi")(hashBloccoGenesi);
 bloccoGenesi.blockHash = hashBloccoGenesi;
 bloccoGenesi.previousBlockHash = "0";
 bloccoGenesi.difficulty = 2;
 getCurrentTimeMillis @Time()(tempo);
 bloccoGenesi.timestamp = tempo;

 if (bloccoGenesi.id_blocco == 0 && bloccoGenesi.difficulty == 2) {
  println @Console("|-------------------------------------------|")();
  println @Console("|     IL BLOCCO GENESI E' STATO CREATO      |")();
  println @Console("|-------------------------------------------|")()
 }
}


define cunninghamPrimo {
 //NUMERO RANDOM
 random @Math()(numeroRandom);
 numR = numeroRandom * 4;
 round @Math(numR)(sceltaAlgoritmo);
 if (sceltaAlgoritmo == 0) {
  for (i = 1, i < 6, i++) {
   n = 2;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1) + (risultato - 1));
   cPrimo0[i] = p
  };
  for (i = 1, i < #cPrimo0, i++) {
   test.base = 2;
   test.exponent = cPrimo0[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cPrimo0[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };
  origine = cPrimo0[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 5
 } else if (sceltaAlgoritmo == 1) {
  for (i = 1, i < 5, i++) {
   n = 509;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1) + (risultato - 1));
   cPrimo1[i] = p
  };
  for (i = 1, i < #cPrimo1, i++) {
   test.base = 2;
   test.exponent = cPrimo1[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cPrimo1[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cPrimo1[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4

 } else if (sceltaAlgoritmo == 2) {
  for (i = 1, i < 4, i++) {
   n = 11;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1) + (risultato - 1));
   cPrimo2[i] = p
  };

  //convalida Fermat
  for (i = 1, i < #cPrimo2, i++) {
   test.base = 2;
   test.exponent = cPrimo2[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cPrimo2[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cPrimo2[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo == 3) {

  //println@Console( "sceltaAlgoritmo = 4" )();
  for (i = 1, i < 4, i++) {
   n = 41;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1) + (risultato - 1));
   cPrimo3[i] = p
  };

  //convalida Fermat
  for (i = 1, i < #cPrimo3, i++) {
   test.base = 2;
   test.exponent = cPrimo3[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cPrimo3[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cPrimo3[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo == 4) {
  //println@Console( "sceltaAlgoritmo = 5" )();

  for (i = 1, i < 7, i++) {
   n = 89;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1) + (risultato - 1));
   cPrimo4[i] = p
  };

  //convalida Fermat
  for (i = 1, i < #cPrimo4, i++) {
   test.base = 2;
   test.exponent = cPrimo4[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cPrimo4[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cPrimo4[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 6
 }
}

define cunninghamSecondo {
 random @Math()(numeroRandom);
 numR = numeroRandom * 4;
 round @Math(numR)(sceltaAlgoritmo2);

 if (sceltaAlgoritmo2 == 0) {

  for (i = 1, i < 4, i++) {
   n = 2;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1 - risultato - 1));
   cSecondo0[i] = p
  };

  //convalida Fermat
  for (i = 1, i < #cSecondo0, i++) {
   test.base = 2;
   test.exponent = cSecondo0[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cSecondo0[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cSecondo0[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo2 == 1) {
  for (i = 1, i < 4, i++) {
   n = 19;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1 - risultato - 1));
   cSecondo1[i] = p
  };

  for (i = 1, i < #cSecondo1, i++) {
   test.base = 2;
   test.exponent = cSecondo1[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cSecondo1[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cSecondo1[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo2 == 2) {
  for (i = 1, i < 4, i++) {
   n = 79;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1 - risultato - 1));
   cSecondo2[i] = p
  };

  for (i = 1, i < #cSecondo2, i++) {
   test.base = 2;
   test.exponent = cSecondo2[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cSecondo2[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cSecondo2[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo2 == 3) {
  for (i = 1, i < 4, i++) {
   n = 331;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1 - risultato - 1));
   cSecondo3[i] = p
  };

  for (i = 1, i < #cSecondo3, i++) {
   test.base = 2;
   test.exponent = cSecondo3[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cSecondo3[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cSecondo3[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3

 } else if (sceltaAlgoritmo2 == 4) {
  for (i = 1, i < 4, i++) {
   n = 439;
   p1 = n;
   prova.base = n;
   prova.exponent = i - 1;
   pow @Math(prova)(risultato);
   p = ((risultato * p1 - risultato - 1));
   cSecondo4[i] = p
  };

  for (i = 1, i < #cSecondo4, i++) {
   test.base = 2;
   test.exponent = cSecondo4[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % cSecondo4[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = cSecondo4[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 3
 }
}

define bitwin {
 random @Math()(numeroRandom);
 numR = numeroRandom * 4;
 round @Math(numR)(sceltaAlgoritmo3);

 if (sceltaAlgoritmo3 == 0) {
  bitwin0[1] = 5;
  bitwin0[3] = ((bitwin0[1] * 2) + 1);
  bitwin0[2] = 7;
  bitwin0[4] = ((bitwin0[2] * 2) - 1);
  for (i = 1, i < #bitwin0, i++) {
   test.base = 2;
   test.exponent = bitwin0[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % bitwin0[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };
  origine = bitwin0[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4
 } else if (sceltaAlgoritmo3 == 1) {
  bitwin1[1] = 23;
  bitwin1[3] = ((bitwin1[1] * 2) + 1);
  bitwin1[2] = 25;
  bitwin1[4] = ((bitwin1[2] * 2) - 1);
  for (i = 1, i < #bitwin1, i++) {
   test.base = 2;
   test.exponent = bitwin1[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % bitwin1[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };
  origine = bitwin1[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4

 } else if (sceltaAlgoritmo3 == 2) {
  bitwin2[1] = 95;
  bitwin2[3] = ((bitwin2[1] * 2) + 1);
  bitwin2[2] = 97;
  bitwin2[4] = ((bitwin2[2] * 2) - 1);
  for (i = 1, i < #bitwin2, i++) {
   test.base = 2;
   test.exponent = bitwin2[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % bitwin2[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };

  origine = bitwin2[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4
 } else if (sceltaAlgoritmo3 == 3) {
  bitwin3[1] = 383;
  bitwin3[3] = ((bitwin3[1] * 2) + 1);
  bitwin3[2] = 385;
  bitwin3[4] = ((bitwin3[2] * 2) - 1);
  for (i = 1, i < #bitwin3, i++) {
   test.base = 2;
   test.exponent = bitwin3[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % bitwin3[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };
  origine = bitwin3[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4
 } else if (sceltaAlgoritmo3 == 4) {
  bitwin4[1] = 1535;
  bitwin4[3] = ((bitwin4[1] * 2) + 1);
  bitwin4[2] = 1537;
  bitwin4[4] = ((bitwin4[2] * 2) - 1);
  for (i = 1, i < #bitwin3, i++) {
   test.base = 2;
   test.exponent = bitwin3[i] - 1;
   pow @Math(test)(elevo);
   p1 = elevo % bitwin3[i];
   if (p1 != 1) {
    controllo = false
   } else {
    controllo = true
   }
  };
  origine = bitwin3[1];
  difficolta = origine / p1;
  lunghezzaCatenaPOW = 4
 }


}

define proofOfWork {
 //calcola random un numero tra 0 e 2

 random @Math()(numeroRandomCatena);
 num = numeroRandomCatena * 2;
 round @Math(num)(numeroCatena);

 if (numeroCatena == 0) {
  cunninghamPrimo
 } else if (numeroCatena == 1) {
  cunninghamSecondo
 } else if (numeroCatena == 2) {
  bitwin
 }

}