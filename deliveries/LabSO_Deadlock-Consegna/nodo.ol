include "MainInterface.iol"
include "Console.iol"
include "String_utils.iol"
include "file.iol"
include "message_digest.iol"

outputPort Nodo_Broadcast {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: BroadcastInterface
}

outputPort Nodo_Network {  //riceve richiesta
  Location:"socket://localhost:9000"
  Protocol: sodep
  Interfaces: NetInterface
}

inputPort ConnNodo {
	Location: location //da assegnare
	Protocol: sodep
	Interfaces: BroadcastInterface
}

outputPort Time {
  Location: "socket://localhost:8100"
  Protocol: sodep
  Interfaces: TimestampInterface, DateInterface
}

outputPort Pow {  
  Interfaces: PowInterface 
}

outputPort Blockchain {
	Interfaces: BlockchainInterface
}

embedded {
  Jolie: "ProofOfWork.ol" in Pow
  Jolie: "Blockchain.ol" in Blockchain
}

define RichiestaTime {
  requestTime = location;
  TimeRequestResponse@Time( requestTime )( responseTime );
  Transaction.timestamp = responseTime;
  millis = responseTime;
  requestDate = millis;
  DateRequestResponse@Time( requestDate )( responseDate );
  Transaction.date = responseDate;
  println@Console( "Data-ora transazione: " + responseDate )()
}

define RichiestaTimeBlock {
  requestTime = location;
  TimeRequestResponse@Time( requestTime )( responseTime );
  millis = responseTime;
  requestDate = millis;
  DateRequestResponse@Time( requestDate )( responseDate );
  println@Console( "Il blocco è stato salvato nella block il: " + responseDate )();
  Block.timestamp = responseDate
}


execution{ concurrent }

init {
  registerForInput@Console()();
  global.contoJollar = 0; 
  global.path =  ".";

  //assegnazione chiave privata
  digest = new;
  md5@MessageDigest(digest)(response);
  global.Node.privateKey = response;

   
  sonoNato@Nodo_Broadcast(location)(response);
  if (response.nato = true) {
    //assegnazione chiave pubblica
    reqSplit = location;
    reqSplit.regex = ":";
    split@StringUtils(reqSplit)(resSplit);
    println@Console( "da splittare: " + reqSplit)();
    println@Console( resSplit.result[2] )();
    global.Node.publicKey = resSplit.result[2];
    idNodo = global.Node.publicKey; 


    //cancella file con blockchain locale del nodo se esiste già
    global.fileBlockchain = global.path + "/fileBlockchain" + global.Node.publicKey + ".txt";
    exists@File(global.fileBlockchain)(esiste);
    if (esiste) {
      delete@File(global.fileBlockchain)(cancellato);
      if (cancellato == true) {
        println@Console( "file eliminato" )()
      }
    };

    //stampa informazioni assegnate
    println@Console( "Nodo nato" )();
    println@Console( "chiave pubblica assegnata: " + global.Node.publicKey )();
    println@Console( "chiave privata assegnata: " + global.Node.privateKey )();
    println@Console( "location assegnata: " + location)();
    //incrementa contoJollar con valore di blocco genesis
    global.contoJollar = global.contoJollar + response.jollarGenesis;
    println@Console( "Conto jollar: " + global.contoJollar )();
    println@Console( "Per creare una nuova transazione inserire idNodo destinatario/numero jollar: " )();

    //avvia network
    possoPartire@Nodo_Network(idNodo)(avvioNwResp)
  }
}


main{
  
  //invia transazione al broadcast
  [in(inputTransazione)] {
    Transaction.nodeSeller.publicKey = global.Node.publicKey;
    Transaction.nodeSeller.privateKey = global.Node.privateKey;
    Transaction.nodeSeller.location = location;
    inputTransazione.regex = "/";
    split@StringUtils(inputTransazione)(datiTransazione);
    Transaction.nodeBuyer.publicKey = datiTransazione.result[0];
    Transaction.jollar = int(datiTransazione.result[1]);

    if (Transaction.nodeBuyer.publicKey == global.Node.publicKey) {
      println@Console( "Impossibile effettuare la transazione: mittente e destinatario coincidono." )()
    }
    else {
      synchronized( contoJollarToken ) {
        //controllo di avere abbastanza jollar 
        if( Transaction.jollar <= global.contoJollar ) {
          println@Console("Jollar che si vogliono inviare: " + Transaction.jollar)();
          println@Console("NodoDestinatario: " + Transaction.nodeBuyer.publicKey)();

          scope( timestamp ) {
            install( IOException => println@Console( "Timestamp down.")() );
            RichiestaTime
          };
          
          invioTrans@Nodo_Broadcast(Transaction)
        } 
        else {
          println@Console("L'importo che si vuole trasferire (" + Transaction.jollar + 
                    ") è maggiore dell'importo posseduto (" + global.contoJollar +
                    "), pertanto non è possibile effettuare la transazione." )()
        }
      }
    }
  }

  //riceve chiamata dal boradcast per verificare che sia attivo
  [checkNodoAttivo(attivo)] {
    println@Console( "" )()
  }

  //riceve transazione dal broadcast
  [broadcastTrans(transRequest2)] {
    //Se il nodo destinatario non esiste nella rete, non viene eseguita la transazione
    if (transRequest2.nodoDown == true) {
      println@Console( "" )()
    }
    //Se il nodo destinatario esiste viene eseguita la transazione
    else {
      println@Console( "La transazione inviata è da " + (transRequest2.nodeSeller.publicKey + 
      " a " + transRequest2.nodeBuyer.publicKey + " con jollar = " + transRequest2.jollar) )();

      //se il nodo è il destinatario --> incrementa il conto jollar
      synchronized( contoJollarToken ) {
        if (transRequest2.nodeBuyer.publicKey == global.Node.publicKey){
          global.contoJollar = global.contoJollar + transRequest2.jollar;
          println@Console( "Conto in seguito ai jollar ricevuti:" + global.contoJollar)()
        }
      };

      //se il nodo è il mittente --> decrementa il conto jollar
      synchronized( contoJollarToken ){
        if (transRequest2.nodeSeller.publicKey == global.Node.publicKey) {
          global.contoJollar = global.contoJollar - transRequest2.jollar;
          println@Console( "Conto in seguito ai jollar inviati:" + global.contoJollar)()
        }
      };

      //invio info transazione al network
      infoNodo.chiavePubblicaNodo = global.Node.publicKey;
      infoNodo.transaction.nodeSeller.publicKey = transRequest2.nodeSeller.publicKey;
      infoNodo.transaction.nodeBuyer.publicKey = transRequest2.nodeBuyer.publicKey; 
      infoNodo.transaction.jollar = transRequest2.jollar;
      infoNodo.transaction.timestamp = transRequest2.timestamp;
      infoNodo.transaction.date = transRequest2.date;

      //l'invio avviene solo se il nodo è coinvolto nella transazione
      if( (global.Node.publicKey  == transRequest2.nodeSeller.publicKey) || (global.Node.publicKey  == transRequest2.nodeBuyer.publicKey)) {
        invioInfoNodo@Nodo_Network(infoNodo)
      };
      
      //avvio Proof of work
      requestPow.x=2;
      requestPow.y=4;
      givePoW@Pow(requestPow)(responsePow);
      println@Console("Esito transazione: " + responsePow.validita)();
   
    
      if( responsePow.validita == true ) {
        //scrittura del blocco sulla blockchain del nodo, mediante richiesta a Blockchain.ol
        requestBlCh.block.previousBlockHash = "hash blocco precedente";
        requestBlCh.block.difficulty = responsePow.difficulty;
        requestBlCh.block.transaction.nodeSeller.publicKey = transRequest2.nodeSeller.publicKey;
        requestBlCh.block.transaction.nodeBuyer.publicKey = transRequest2.nodeBuyer.publicKey;
        requestBlCh.block.transaction.jollar = transRequest2.jollar;
        requestBlCh.block.transaction.timestamp =  transRequest2.timestamp;
        scope( timestamp ) {
          install( IOException => println@Console( "Timestamp down" )() );  
          RichiestaTimeBlock;
          requestBlCh.block.timestamp = Block.timestamp
        };
        
        requestBlCh.nomefileBlCh = "/fileBlockchain" + global.Node.publicKey + ".txt";
        updateBlCh@Blockchain( requestBlCh )( responseBlCh );
        println@Console("Response da Blockchain: " + responseBlCh)();

        //incrementa il conto dei jollar se il nodo ha aggiunto il blocco alla blockchain
        if ( responseBlCh == true ) {
          synchronized( contoJollarToken ) {
            global.contoJollar = global.contoJollar + 6;
            println@Console( "Conto in seguito alla vincita del bonus :" + global.contoJollar)()
          }
        }
      }
      else {
        println@Console("non ho aggiunto nessun blocco alla blockchain")()
      };
 
      //invio il conto jollar del nodo al network
      infoJollarNodo.idNodoJ = global.Node.publicKey;
      infoJollarNodo.jollarNodo =  global.contoJollar;
      invioJollarNodo@Nodo_Network(infoJollarNodo);
      

      //conteggio dei blocchi presenti nella blockchain, mediante richiesta a Blockchain.ol
      fileDaLeggere = "/fileBlockchain" + global.Node.publicKey + ".txt";
      contaBlocchiBlCh@Blockchain( fileDaLeggere )( nBlocchi );
      println@Console("Numero di blocchi" + nBlocchi)();
      global.numeroBlocchiNodo = nBlocchi;

      //invia richiesta al broadcast di chiedere numero di blocchi a tutti gli altri nodi
      nodoDaControllare.location =location;
      checkBlChCorretta@Nodo_Broadcast( nodoDaControllare )
    }
  }

  //riceve richiesta dal broadcast di passargli location + numero nodi
  [richiestaBlockchainNodi()(resBlockchainNodi) {
  	fileDaLeggere=  "/fileBlockchain" + global.Node.publicKey + ".txt";
    contaBlocchiBlCh@Blockchain( fileDaLeggere )( nBlocchi );
    resBlockchainNodi.location = location;
    resBlockchainNodi.numeroBlocchi = nBlocchi
  }]

  //riceve dal broadcast la lunghezza delle blockchain degli altri nodi e le confronta con la propria
  [inviaNumBlocchi(nodoOk)] {
    synchronized( numeroBlocchiNodo ) {
      println@Console( "CONTROLLO LUNGHEZZE" )();
      println@Console( "numero blocchi nodo: " + global.numeroBlocchiNodo )();
      println@Console( "numero blocchi da confrontare: " + nodoOk.numeroBlocchi )();
      
      //confronto lunghezze
      if ( nodoOk.numeroBlocchi > global.numeroBlocchiNodo ) {
        println@Console( "blockchain da aggiornare" )();
        //copio file blockchain più lunga
        reqSplit = nodoOk.location;
        reqSplit.regex = ":";
        split@StringUtils(reqSplit)(resSplit);
        
        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato." )() );
          copyRequest.from = global.path + "/fileBlockchain" + resSplit.result[2] + ".txt";
          copyRequest.to = global.path + "/fileBlockchain" + global.Node.publicKey + ".txt";
          println@Console( "copia da " +  copyRequest.from + " a " + copyRequest.to)();
          copyDir@File(copyRequest)(copyResponse);
          if (copyResponse == true) {
            println@Console( "contenuto copiato" )()
          } 
        }
      }  
    }
  }


  //riceve richiesta dal broadcast di passare al broadcast location + numero nodi
  [richiestaInfoNodo(richiestaNumBlocchi)]{
    fileDaLeggere = "/fileBlockchain" + global.Node.publicKey + ".txt";
    contaBlocchiBlCh@Blockchain( fileDaLeggere )( nBlocchi );
    global.numeroBlocchiNodo = nBlocchi;
    blocchi.numeroBlocchi = global.numeroBlocchiNodo;
    blocchi.location =location;
    rispostaNumeroBlocchi@Nodo_Network(blocchi)
  }

}

