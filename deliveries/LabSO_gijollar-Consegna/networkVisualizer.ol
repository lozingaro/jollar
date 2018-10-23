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

outputPort timestamp {
    Location: "socket://localhost:8006/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort broadcast {
    Location: "socket://localhost:8005/"
    Protocol: sodep
    Interfaces: ClientInterface
}

inputPort MyInport {
    Location: "socket://localhost:8007/"
    Protocol: sodep
    Interfaces: ClientInterface
}

execution{ concurrent }

//Stampa le opzioni per l'utente
define mostraOpzioni{
  println@Console("Premi il tasto invio per richiedere lo stato della rete")()
}

init{
  mostraOpzioni;
  registerForInput@Console()()
}

main{
  [in(scelta)]{
    requestDate@timestamp(request)(response); //data e ora al momento della richiesta
    request.time = response;
    println@Console("Data: " + request.time +"\n")();

    scope ( CLIENT1 ){
      //RICHIESTA AL CLIENT 1
      install( IOException => {
        println@Console("Il client 1 e' offline, non e' possibile ricevere il suo stato!")()
      });
      requestData@client1()(response); //richiedo i dati al client1
      println@Console("STATO DEL CLIENT 1")();
      println@Console("\n" + "Chiave client: " + response.pkClient + "  Saldo: " + response.saldo)();
      println@Console("Entrate: ")();
      if(!is_defined( response.entrate )){
        println@Console("Nessuna entrata presente!")()
      }else{
        for(i=0, i<#response.entrate.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.entrate.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.entrate.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.entrate.transaction[i].jollar)();
          timeMilli = response.entrate.transaction.time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      println@Console("Uscite: ")();
      if(!is_defined( response.uscite )){
        println@Console("Nessuna uscita presente!")()
      }else{
        for(i=0, i<#response.uscite.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.uscite.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.uscite.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.uscite.transaction[i].jollar)();
          timeMilli = response.uscite.transaction[i].time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      posizione = #response.blockchain.block - 1;
      t = response.blockchain.block[posizione].time;
      println@Console( "Versione blockchain:" )();

      //stampa della blockchain
      for(i=0, i<#response.blockchain.block, i++){
        println@Console( "Blocco "+(i+1) )();
        println@Console( "ID: "+response.blockchain.block[i].id+", PreviousID: "+response.blockchain.block[i].previousId )();
        println@Console("Transazione:")();
        println@Console( "\t Seller: "+response.blockchain.block[i].transaction.nodeSellerID.publicKey)();
        println@Console( "\t Buyer: "+response.blockchain.block[i].transaction.nodeBuyerID.publicKey)();
        println@Console( "\t Jollar: "+response.blockchain.block[i].transaction.jollar)();
        timeMilli = response.blockchain.block[i].transaction.time;
        getDateTime@Time(timeMilli)(dataRisposta);
        println@Console( "\t Data transazione: " + dataRisposta)();
        print@Console("Catena numeri primi: ")();
        for(j=0, j<#response.blockchain.block[i].catena.numeriPrimi, j++){
          print@Console( response.blockchain.block[i].catena.numeriPrimi[j]+"  " )()
        };
        print@Console( ", Difficulty: "+response.blockchain.block[i].difficulty +"\n")();
        //println@Console( "Timestamp: "+response.blockchain.block[i].time )();
        println@Console( "Client che ha scritto il blocco: "+response.blockchain.block[i].clientS.publicKey+"\n" )()
      }
    };

    scope( CLIENT2 ){
      //RICHIESTA AL CLIENT 2
      install(IOException => {
          println@Console( "Il client 1 e' offline, non e' possibile ricevere il suo stato!\n" )()
      });
      requestData@client2()(response); //richiedo i dati al client2
      println@Console("STATO DEL CLIENT 2")();
      println@Console("\n" + "Chiave client: " + response.pkClient + "  Saldo: " + response.saldo)();
      println@Console("Entrate: ")();
      if(!is_defined( response.entrate )){
        println@Console("Nessuna entrata presente!")()
      }else{
        for(i=0, i<#response.entrate.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.entrate.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.entrate.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.entrate.transaction[i].jollar)();
          timeMilli = response.entrate.transaction.time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      println@Console("Uscite: ")();
      if(!is_defined( response.uscite )){
        println@Console("Nessuna uscita presente!")()
      }else{
        for(i=0, i<#response.uscite.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.uscite.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.uscite.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.uscite.transaction[i].jollar)();
          timeMilli = response.uscite.transaction[i].time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      posizione = #response.blockchain.block - 1;
      t = response.blockchain.block[posizione].time;
      println@Console( "Versione blockchain:" )();

      //stampa della blockchain
      for(i=0, i<#response.blockchain.block, i++){
        println@Console( "Blocco "+(i+1))();
        println@Console( "ID: "+response.blockchain.block[i].id+", PreviousID: "+response.blockchain.block[i].previousId )();
        println@Console("Transazione:")();
        println@Console( "\t Seller: "+response.blockchain.block[i].transaction.nodeSellerID.publicKey)();
        println@Console( "\t Buyer: "+response.blockchain.block[i].transaction.nodeBuyerID.publicKey)();
        println@Console( "\t Jollar: "+response.blockchain.block[i].transaction.jollar)();
        timeMilli = response.blockchain.block[i].transaction.time;
        getDateTime@Time(timeMilli)(dataRisposta);
        println@Console( "\t Data transazione: " + dataRisposta)();
        print@Console("Catena numeri primi: ")();
        for(j=0, j<#response.blockchain.block[i].catena.numeriPrimi, j++){
          print@Console( response.blockchain.block[i].catena.numeriPrimi[j]+"  " )()
        };
        print@Console( ", Difficulty: "+response.blockchain.block[i].difficulty+"\n")();
        //println@Console( "Timestamp: "+response.blockchain.block[i].time )();
        println@Console( "Client che ha scritto il blocco: "+response.blockchain.block[i].clientS.publicKey+"\n" )()
      }
    };

    scope( CLIENT3 ){
      //RICHIESTA AL CLIENT 3
      install(IOException => {
          println@Console( "Il client 1 e' offline, non e' possibile ricevere il suo stato!\n" )()
      });
      requestData@client3()(response); //richiedo i dati al client3
      println@Console("STATO DEL CLIENT 3")();
      println@Console("\n" + "Chiave client: " + response.pkClient + "  Saldo: " + response.saldo)();
      println@Console("Entrate: ")();
      if(!is_defined( response.entrate )){
        println@Console("Nessuna entrata presente!")()
      }else{
        for(i=0, i<#response.entrate.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.entrate.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.entrate.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.entrate.transaction[i].jollar)();
          timeMilli = response.entrate.transaction.time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      println@Console("Uscite: ")();
      if(!is_defined( response.uscite )){
        println@Console("Nessuna uscita presente!")()
      }else{
        for(i=0, i<#response.uscite.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.uscite.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.uscite.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.uscite.transaction[i].jollar)();
          timeMilli = response.uscite.transaction[i].time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      posizione = #response.blockchain.block - 1;
      t = response.blockchain.block[posizione].time;
      println@Console( "Versione blockchain:" )();

      //stampa della blockchain
      for(i=0, i<#response.blockchain.block, i++){
        println@Console( "Blocco "+(i+1) )();
        println@Console( "ID: "+response.blockchain.block[i].id+", PreviousID: "+response.blockchain.block[i].previousId )();
        println@Console("Transazione:")();
        println@Console( "\t Seller: "+response.blockchain.block[i].transaction.nodeSellerID.publicKey)();
        println@Console( "\t Buyer: "+response.blockchain.block[i].transaction.nodeBuyerID.publicKey)();
        println@Console( "\t Jollar: "+response.blockchain.block[i].transaction.jollar)();
        timeMilli = response.blockchain.block[i].transaction.time;
        getDateTime@Time(timeMilli)(dataRisposta);
        println@Console( "\t Data transazione: " + dataRisposta)();
        print@Console("Catena numeri primi: ")();
        for(j=0, j<#response.blockchain.block[i].catena.numeriPrimi, j++){
          print@Console( response.blockchain.block[i].catena.numeriPrimi[j]+"  " )()
        };
        print@Console( ", Difficulty: "+response.blockchain.block[i].difficulty+"\n")();
        //println@Console( "Timestamp: "+response.blockchain.block[i].time )();
        println@Console( "Client che ha scritto il blocco: "+response.blockchain.block[i].clientS.publicKey+"\n" )()
      }
    };

    scope( CLIENT4 ){
      install(IOException => {
          println@Console( "Il client 1 e' offline, non e' possibile ricevere il suo stato!\n" )()
      });
      //RICHIESTA AL CLIENT 4
      requestData@client4()(response); //richiedo i dati al client4
      println@Console("STATO DEL CLIENT 4")();
      println@Console("\n" + "Chiave client: " + response.pkClient + "  Saldo: " + response.saldo)();
      println@Console("Entrate: ")();
      if(!is_defined( response.entrate )){
        println@Console("Nessuna entrata presente!")()
      }else{
        for(i=0, i<#response.entrate.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.entrate.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.entrate.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.entrate.transaction[i].jollar)();
          timeMilli = response.entrate.transaction.time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      println@Console("Uscite: ")();
      if(!is_defined( response.uscite )){
        println@Console("Nessuna uscita presente!")()
      }else{
        for(i=0, i<#response.uscite.transaction, i++){
          println@Console("Transazione "+(i+1)+":")();
          println@Console( "\t Seller: "+response.uscite.transaction[i].nodeSellerID.publicKey)();
          println@Console( "\t Buyer: "+response.uscite.transaction[i].nodeBuyerID.publicKey)();
          println@Console( "\t Jollar: "+response.uscite.transaction[i].jollar)();
          timeMilli = response.uscite.transaction[i].time;
          getDateTime@Time(timeMilli)(dataRisposta);
          println@Console( "\t Data transazione: " + dataRisposta)()
        }
      };
      posizione = #response.blockchain.block - 1;
      t = response.blockchain.block[posizione].time;
      println@Console( "Versione blockchain:" )();

      //stampa della blockchain
      for(i=0, i<#response.blockchain.block, i++){
        println@Console( "Blocco "+(i+1) )();
        println@Console( "ID: "+response.blockchain.block[i].id+", PreviousID: "+response.blockchain.block[i].previousId )();
        println@Console("Transazione:")();
        println@Console( "\t Seller: "+response.blockchain.block[i].transaction.nodeSellerID.publicKey)();
        println@Console( "\t Buyer: "+response.blockchain.block[i].transaction.nodeBuyerID.publicKey)();
        println@Console( "\t Jollar: "+response.blockchain.block[i].transaction.jollar)();
        timeMilli = response.blockchain.block[i].transaction.time;
        getDateTime@Time(timeMilli)(dataRisposta);
        println@Console( "\t Data transazione: " + dataRisposta)();
        print@Console("Catena numeri primi: ")();
        for(j=0, j<#response.blockchain.block[i].catena.numeriPrimi, j++){
          print@Console( response.blockchain.block[i].catena.numeriPrimi[j]+"  " )()
        };
        print@Console( ", Difficulty: "+response.blockchain.block[i].difficulty+"\n")();
        //println@Console( "Timestamp: "+response.blockchain.block[i].time )();
        println@Console( "Client che ha scritto il blocco: "+response.blockchain.block[i].clientS.publicKey+"\n" )()
      }
    };

    //CODICE PER RICHIEDERE LA STAMPA DELLA BLOCKCHAIN UFFICIALE
    scope( scopeBlockchain ){
      install(IOException => {
        println@Console( "Il broadcast non e' raggiungibile, riprova dopo averlo lanciato!" )()
      });
      sincro@broadcast()(array);
      maxl = 0;
      numClientMax = 0;
      for(i=0, i<#array.listaBlockchain, i++){
        bl << array.listaBlockchain[i];
        if(#bl > maxl){
          maxl = #bl.block;
          blockchainMax << bl;
          lista[0] << bl;
          numClientMax = 1
        }else{
          if(#bl.block == maxl){
            lista[numClientMax] << bl;
            numClientMax = numClientMax + 1
          }
        }
      };
      if(numClientMax == 1){
        blockchainUfficiale << blockchainMax
      }else{
        //se c'è più di una lista con lunghezza = lunghezza massima
        listMax = 0;
        maxCount = 0;
        //prendo un elemento della lista e lo confronto con tutti gli altri a parte se stesso
        for(i=0, i<#lista, i++){
          myBlockchain << lista[i];
          size = #myBlockchain.block;
          blocki << myBlockchain.block[size-1];
          count = 0;
          for(j=0, j<#lista, j++){
            myBlockchainj << lista[j];
            blockj << myBlockchainj.block[size-1];
            if(i != j){
              if(blocki.id == blockj.id){
                count = count+1;
                if(count > maxCount){
                  maxCount = count;
                  listMax = i
                }else{
                  //se ho più blockchain che sono presenti nello stesso numero di client,
                  //confronto il timestamp dell'ultimo blocco delle due blockchain.
                  //quella con il time più piccolo è stata scritta per prima e quindi
                  //sara la blockchain di riferimento.
                  if(count == maxCount){
                    myblock << lista[listMax].block[size-1];
                    if(blocki.time < myblock.time){
                      listMax = i
                    }
                  }
                }
              }
            }
          }
        };
        blockchainUfficiale << lista[listMax]
      };
      //stampa della blockchain ufficiale
      println@Console( "BLOCKCHAIN UFFICIALE:" )();
      for(i=0, i<#blockchainUfficiale.block, i++){
        println@Console( "Blocco "+(i+1) )();
        println@Console( "ID: "+response.blockchain.block[i].id+", PreviousID: "+response.blockchain.block[i].previousId )();
        println@Console("Transazione:")();
        println@Console( "\t Seller: "+blockchainUfficiale.block[i].transaction.nodeSellerID.publicKey)();
        println@Console( "\t Buyer: "+blockchainUfficiale.block[i].transaction.nodeBuyerID.publicKey)();
        println@Console( "\t Jollar: "+blockchainUfficiale.block[i].transaction.jollar)();
        timeMilli = blockchainUfficiale.block[i].transaction.time;
        getDateTime@Time(timeMilli)(dataRisposta);
        println@Console( "\t Data transazione: " + dataRisposta)();
        print@Console("Catena numeri primi: ")();
        for(j=0, j<#blockchainUfficiale.block[i].catena.numeriPrimi, j++){
          print@Console( blockchainUfficiale.block[i].catena.numeriPrimi[j]+"  " )()
        };
        print@Console( ", Difficulty: "+response.blockchain.block[i].difficulty+"\n")();
        //println@Console( "Timestamp: "+blockchainUfficiale.block[i].time )();
        println@Console( "Client che ha scritto il blocco: "+blockchainUfficiale.block[i].clientS.publicKey+"\n" )()
      }
    };
    mostraOpzioni
  }
}
