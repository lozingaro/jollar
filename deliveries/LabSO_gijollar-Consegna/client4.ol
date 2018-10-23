include "clientInterface.iol"
include "console.iol"
include "string_utils.iol"
include "file.iol"
include "time.iol"
include "math.iol"
include "runtime.iol"
include "message_digest.iol"

outputPort Client {
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort broadcast {
    Location: "socket://localhost:8005/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort timestamp {
    Location: "socket://localhost:8006/"
    Protocol: sodep
    Interfaces: ClientInterface
}

outputPort networkVisualizer {
    Location: "socket://localhost:8007/"
    Protocol: sodep
    Interfaces: ClientInterface
}

inputPort MyInput {
    Location: "socket://localhost:8004/"
    Protocol: sodep
    Interfaces: ClientInterface
}

constants{
  LOCATION_CLIENT1 = "socket://localhost:8001/",
  LOCATION_CLIENT3 = "socket://localhost:8003/",
  LOCATION_CLIENT4 = "socket://localhost:8004/"
}

execution{ concurrent }

//Stampa le opzioni per l'utente
define mostraOpzioni{
  println@Console("--------- \nInserisci:
NumeroNodo / JollarDaInviare

oppure digita 'Saldo' per mostare i tuoi Jollar al momento

oppure digita 'Exit' per chiudere \n---------")()
}

//Data la stringa nodo/jollar fa il parsing e lancia eventuali eccezioni
define splitStringForJollars{
  comando.regex = "/";
  split@StringUtils(comando)(dettagli);
  numeroNodo = int(dettagli.result[0]);
  a.session.jollarOut = int(dettagli.result[1]);
  if (numeroNodo < 1 || numeroNodo > 4){
    throw( illegalNode )
  };
  synchronized( syncSaldo ){
    if (a.session.jollarOut > global.jollarIn){
      throw( tooLittleCash )
    };
    global.jollarOut = a.session.jollarOut
  }
}

define stampaSaldo{
  synchronized( syncSaldo ){
    println@Console("Il saldo e' di: " + global.jollarIn + " Jollar")()
  }
}

define creationChain{
  posizione = #global.Blockchain.block - 1;
  l = global.lunghezza;
  if(global.origine == 0){ //è uguale a 0 nel caso in cui ci sia solo il primo blocco.
    global.origine = 2
  };
  pi = global.origine;
  catena[0] = int(pi);
  //println@Console("0:  "+catena[0])();
  i = 1;
  while(i < l+1){
    powrequest.base = 2;
    powrequest.exponent = i;
    pow@Math(powrequest)(num);
    p = num * pi + (num - 1);
    catena[i] = int(p);
    //println@Console(i+":  "+catena[i])();
    i = i+1
  };
  chain.numeriPrimi << catena;
  chain.lunghezza = l+1;
  global.lunghezza = l+1;
  //calcolo del numero successivo della catena
  powrequest.base = 2;
  powrequest.exponent = l+1;
  pow@Math(powrequest)(num);
  pk = num * 2 + (num - 1);
  //test di fermat per determinare il resto r
  powrequest.base = 3;
  powrequest.exponent = pk-1;
  pow@Math(powrequest)(number);
  //formula per calcolare la difficulty
  r = number % pk;
  risultato = (pk-r)/pk;
  k = double(l+1);
  diff = k + risultato
  //println@Console( "diff: "+diff )()
}

define caricamentoSaldo{
  nome = "cash.json";
  //controllo se esiste il file
  exists@File(nome)(risposta);
  install( IOException => {
    println@Console("Errore nel caricamento del saldo !!!")()
  });
  //se esiste il file dei saldi esiste anche la blockchain
  if(risposta == true){
    f.filename = "cash.json";
    f.format = "json";
    readFile@File(f)(res);
    synchronized( syncSaldo ){
      global.jollarIn = res.arraySaldi[3] //3 perchè il saldo del client 4 è nella quarta posizione dell'array!
    }
    //println@Console( "preso il saldo dal file "+jollarIn )()
  }else{
    //altrimenti carico saldo iniziale di 0
    synchronized( syncSaldo ){
      global.jollarIn = 0
    }
  }
}

define caricamentoBlockchain{
  //metodo che carica la blockchain all'avvio del client
  nome = "FileClient4.json";
  //controllo se esiste il file
  exists@File(nome)(risposta);
  install( IOException => {
    println@Console("Errore nel caricamento della blockchain !!!")()
  });
   //se esiste carico la blockchain
   //dovrebbe sempre essere true perche avviando prima il client 1 si crea il primo blocco!
  if(risposta == true){
    f.filename = "FileClient4.json";
    f.format = "json";
    readFile@File(f)(res);
    for(i=0, i<#res.block, i++){
      //println@Console( "blocco n "+i )();
      global.Blockchain.block[i]<<res.block[i]
    }
  }else{
    //prendo la blockchain dal client 1 perchè è il primo che si avvia nella demo
    //e quindi il file dovrebbe sempre essere presente all'avvio degli altri client
    nome = "FileClient1.json";
    //controllo se esiste il file
    exists@File(nome)(risposta);
    if(risposta == true){
      f.filename = "FileClient1.json";
      f.format = "json";
      readFile@File(f)(res);
      for(i=0, i<#res.block, i++){
        //println@Console( "blocco n "+i )();
        global.Blockchain.block[i]<<res.block[i]
      }
    }
  };
  caricamentoSaldo;
  size = #global.Blockchain.block;
  global.origine = global.Blockchain.block[size-1].catena.numeriPrimi[0]; //primo numero dell'utlima catena della blockchain
  global.lunghezza = global.Blockchain.block[size-1].catena.lunghezza
}

define scriviBlocco{
  //cerco la posizione in cui aggiungere il blocco
  synchronized( syncBlockchain ){
    //println@Console( "scrivo blocco!" )();
    block << ack.block;
    WriteFileRequest.filename = "FileClient4.json";
    posizione = #global.Blockchain.block;
    //controllo che il previousId sia uguale all'id dell'ultimo Blocco
    if(global.Blockchain.block[posizione-1].id == block.previousId ){
      global.Blockchain.block[posizione]<<block;
      println@Console( "Complimenti sei riuscito a scrivere il blocco! Reward 6 jollar" )();
      synchronized( syncSaldo ){
        global.jollarIn = global.jollarIn + 6;
        stampaSaldo
      }
    }else{
          if(global.Blockchain.block[posizione-1].previousId == block.previousId){
            //println@Console( "Blocco gia scritto! clientS (my) " + block.clientS.publicKey)();
            //se il blocco con la transazione è gia stato scritto, ma la catena trovata è di
            //difficolta superiore devo salvarla ed utilizzarla all'arrivo di una nuova transazione.
            if(global.Blockchain.block[posizione-1].difficulty < block.difficulty){
              //println@Console( "difficolta superiore" )();
              synchronized( syncDifficulty ){
                global.oldChain<<block.catena;
                global.diff<<block.difficulty
              }
            }else{
              //println@Console( "difficolta non superiore" )();
              //se il blocco è gia stato scritto ma la catena non è di difficoltà superiore
              synchronized( syncDifficulty ){
                undef( global.oldChain );
                undef( global.diff )
              }
            }
        /*
          }else{
            println@Console( "Blocco non scritto, non sincronizzato. "+ block.clientS.publicKey)()
        */
          }
    };
    testo<<global.Blockchain;
    WriteFileRequest.content<<testo;
    WriteFileRequest.format = "json";
    writeFile@File(WriteFileRequest)()
  }
}
define proceduraDiSincronizzazione{
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
    //println@Console( "solo una blockchain con lunghezza max " )();
    global.Blockchain << blockchainMax
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
    posizione = #lista[listMax].block;
    if(myId != lista[listMax].block[posizione-1].id){
        //println@Console( "Mia blockchain non sincronizzata. Aggiorno!" )();
        //se la blockchain non è sincronizzata ed io avevo scritto l'ultimo blocco
        //tolgo 6 jollar che avevo ricevuto in reward ingiustamente.
        if(global.Blockchain.block[size-1].clientS.publicKey == MyPublicKey){
          println@Console( "Correzione reward! -6 jollar. Sara' per la prossima! :P " )();
          synchronized( syncSaldo ){
            global.jollarIn = global.jollarIn - 6;
            stampaSaldo
          }
        };
        global.Blockchain << lista[listMax];
        s = #global.Blockchain.block
        //println@Console( "ultimo blocco "+global.Blockchain.block[s-1].id+", "+global.Blockchain.block[s-1].clientS.publicKey )()
    }else{
      //println@Console( "Ok, mia blockchain sincronizzata" )();
      ack.isOk = "Errore_Sincro"
    }
  }
}

init{
  mostraOpzioni |
  registerForInput@Console(reg)() |
  clientCode = string(new);
  a.session.clientID = "client4";
  a.session.pkClient = a.session.clientID +"-"+ clientCode;
  scope (scopeName)
  {
    install( IOException => println@Console("Il servizio Broadcast e' offline, la preghiamo di chiudere il client e riaprirlo solo dopo aver avviato il Broadcast!")() );
    sendKey@broadcast(a.session)
  };
  MyPublicKey = a.session.pkClient;
  MyPrivateKey = string(new);
  global.pkClient2 = " ";
  global.pkClient3 = " ";
  global.pkClient4 = " ";
  global.BlockChain = " ";
  //creo un array con le chiavi dei client del sistema
  global.chiavi[0] = MyPublicKey;
  //creo un array con i client del sistema
  users[0] = LOCATION_CLIENT1;
  users[1] = LOCATION_CLIENT2;
  users[2] = LOCATION_CLIENT3;
  caricamentoBlockchain
}

main{
  [in(scelta)]{
    install(illegalNode => {
      println@Console( "Errore: Nodo inesistente, inserire un nodo che va da 1 a 4" )();
      mostraOpzioni
    });
    install (tooLittleCash => {
      println@Console( "Errore: non hai abbastanza Jollar" )();
      mostraOpzioni
    });
    toLowerCase@StringUtils(scelta)(comando);
    if (comando == "saldo") {
      stampaSaldo;
      mostraOpzioni
    }else {
      //IL COMANDO EXIT CONSENTE DI CHIUDERE IL CLIENT E SALVARE IL SALDO DEI SUOI JOLLAR NEL FILE CASH
      if(comando == "exit"){
        install( CorrelationError => {println@Console( "Errore nella chiusura del client (comando exit)." )()},
                  IOException => { println@Console( "Broadcast offline impossibile salvare il saldo." )();
                                    HaltRequest.status = 1;
                                    halt@Runtime( HaltRequest )( void )
                                  }
        );
        //invio il saldo al broadcast che lo salva nel file
        synchronized( syncSaldo ){
          mysaldo.saldo = global.jollarIn;
          mysaldo.client = 4
        };
        sendSaldo@broadcast(mysaldo);
        //HALT CONSENTE DI ARRESTARE IL CLIENT
        HaltRequest.status = 1;
        halt@Runtime( HaltRequest )( void )
      }else{
      splitStringForJollars;
      println@Console("Mandando " + global.jollarOut + " Jollar al client" + numeroNodo)();
      requestTime@timestamp(request)(response);
      if(numeroNodo == 1){
        scope (scopeName)
        {
          if(global.pkClient1 == " "){
            println@Console("Il client a cui si vuole inviare i Jollar non e' disponibile!")();
            mostraOpzioni
          }else{
            nodeBuyer.publicKey = global.pkClient1;
            nodeSeller.publicKey = MyPublicKey;
            tr.nodeBuyerID.publicKey = nodeBuyer.publicKey;
            tr.nodeSellerID.publicKey = nodeSeller.publicKey;
            tr.jollar = global.jollarOut;
            requestTime@timestamp(request)(t);
            tr.time = t;
            tr.id = string(new);
            md5@MessageDigest(MyPrivateKey)(risposta);
            tr.nodeSellerID.privateKey = risposta;
            //prima di mandare la transazione al broadcast devo far validare la transazione agli altri client
            install( IOException =>{ println@Console( "Impossibile validare la transazione perche' non tutti i nodi sono online" )()} );
            numOk = 0;
            for(i = 0, i < #users, i++){
              Client.location = users[i];
              validationTr@Client(tr)(response);
              if(response == "ok"){
                numOk ++
              }
            };
            //dopo aver ricevuto le risposte controllo che il numero di ok sia maggiore della metà dei client
            numMaggioranza = int(#users / 2)+1;
            //se il numero di ok eguaglio o supera la maggioranza dei client la transazione è corretta e quindi
            //posso inviarla al broadcast
            if(numOk >= numMaggioranza){
              sendTransaction@broadcast( tr )
            }
          }
        }
      }else if(numeroNodo == 2){
        scope (scopeName)
        {
          if(global.pkClient2 == " "){
            println@Console("Il client a cui si vuole inviare i Jollar non e' disponibile!")();
            mostraOpzioni
          }else{
            nodeBuyer.publicKey = global.pkClient2;
            nodeSeller.publicKey = MyPublicKey;
            tr.nodeBuyerID.publicKey = nodeBuyer.publicKey;
            tr.nodeSellerID.publicKey = nodeSeller.publicKey;
            tr.jollar = global.jollarOut;
            requestTime@timestamp(request)(t);
            tr.time = t;
            tr.id = string(new);
            md5@MessageDigest(MyPrivateKey)(risposta);
            tr.nodeSellerID.privateKey = risposta;
            //prima di mandare la transazione al broadcast devo far validare la transazione agli altri client
            install( IOException =>{ println@Console( "Impossibile validare la transazione perche' non tutti i nodi sono online" )()} );
            numOk = 0;
            for(i = 0, i < #users, i++){
              Client.location = users[i];
              validationTr@Client(tr)(response);
              if(response == "ok"){
                numOk ++
              }
            };
            //dopo aver ricevuto le risposte controllo che il numero di ok sia maggiore della metà dei client
            numMaggioranza = int(#users / 2)+1;
            //se il numero di ok eguaglio o supera la maggioranza dei client la transazione è corretta e quindi
            //posso inviarla al broadcast
            if(numOk >= numMaggioranza){
              sendTransaction@broadcast( tr )
            }
          }
        }
      }else if(numeroNodo == 3){
        scope (scopeName)
        {
          if(global.pkClient3 == " "){
            println@Console("Il client a cui si vuole inviare i Jollar non e' disponibile!")();
            mostraOpzioni
          }else{
            nodeBuyer.publicKey = global.pkClient3;
            nodeSeller.publicKey = MyPublicKey;
            tr.nodeBuyerID.publicKey = nodeBuyer.publicKey;
            tr.nodeSellerID.publicKey = nodeSeller.publicKey;
            tr.jollar = global.jollarOut;
            requestTime@timestamp(request)(t);
            tr.time = t;
            tr.id = string(new);
            md5@MessageDigest(MyPrivateKey)(risposta);
            tr.nodeSellerID.privateKey = risposta;
            //prima di mandare la transazione al broadcast devo far validare la transazione agli altri client
            install( IOException =>{ println@Console( "Impossibile validare la transazione perche' non tutti i nodi sono online" )()} );
            numOk = 0;
            for(i = 0, i < #users, i++){
              Client.location = users[i];
              validationTr@Client(tr)(response);
              if(response == "ok"){
                numOk ++
              }
            };
            //dopo aver ricevuto le risposte controllo che il numero di ok sia maggiore della metà dei client
            numMaggioranza = int(#users / 2)+1;
            //se il numero di ok eguaglio o supera la maggioranza dei client la transazione è corretta e quindi
            //posso inviarla al broadcast
            if(numOk >= numMaggioranza){
              sendTransaction@broadcast( tr )
            }
          }
        }
      }else{
        println@Console("Errore! Non puoi inviare Jollar a te stesso!")();
        mostraOpzioni
      }
    }
  }
}

[validationTr(request)(response){
  chiaveSeller = request.nodeSellerID.publicKey;
  chiavePrivataSeller = request.nodeSellerID.privateKey;
  chiaveBuyer = request.nodeBuyerID.publicKey;
  //eseguo i controlli sulle chiavi
  //controllo che la chiave del seller e del buyer sia presente nel mio elenco di chiavi
  chiaviTrovate = 0;
  for(i = 0, i < #global.chiavi, i++){
    if(chiaveSeller == global.chiavi[i] || chiaveBuyer == global.chiavi[i]){
      chiaviTrovate ++
    }
  };
  if(chiaviTrovate == 2){
    //considero valida qualsiasi chiave privata l'importante è che non sia vuota
    if(chiavePrivataSeller != " "){
      response = "ok"
    }else{
      response = "errore"
    }
  }else{
    response = "errore"
  }
}]

//METODO PER LA RICEZIONE CHIAVE DAL BROADCAST DI UN ALTRO CLIENT
[sendKey (autentication)]{
  if( autentication.clientID == "client1" ) {
    global.pkClient1 = autentication.pkClient;
    global.chiavi[1] = autentication.pkClient
    //println@Console("Public Key client1: " + global.pkClient1)()
  }else if(autentication.clientID == "client3"){
    global.pkClient3 = autentication.pkClient;
    global.chiavi[2] = autentication.pkClient
    //println@Console("Public Key client3: " + global.pkClient3)()
  }else{
    global.pkClient2 = autentication.pkClient;
    global.chiavi[3] = autentication.pkClient
    //println@Console("Public Key client2: " + global.pkClient2)()
  }
}

  //METODO PER LA RICEZIONE DELLE TRANSAZIONI
  [sendTransaction ( transaction )] {
     clientS.publicKey = MyPublicKey;
     nodeBuyer = transaction.nodeBuyerID.publicKey;
     nodeSeller = transaction.nodeSellerID.publicKey;
     jollar = transaction.jollar;
     println@Console("E' stata ricevuta la seguente transazione = \n \t NodoSeller: " + nodeSeller + "\n \t NodeBuyer: " + nodeBuyer + "\n \t Jollar: " + jollar)();
     println@Console( "Start della proof-of-work" )();

     synchronized( syncDifficulty ){
       size = #global.Blockchain.block;
       //se è presente una catena già creata, ma che non è stata inserita nella blockchain perchè
       //qualche altro client è giunto prima e la difficoltà di questa è maggiore dell'ultimo blocco
       //posso usarla senza eseguire una nuova proof-of-work
       if(is_defined( global.oldChain ) && global.difficulty > global.Blockchain.block[size-1].difficulty){
         //println@Console( "è definita" )();
         block.difficulty = global.difficulty;
         block.catena << global.oldChain
       }else{
         //println@Console( "non è definita" )();
         //creazione della catena
         creationChain;
         block.difficulty = diff;
         block.catena << chain
       }
     };

     //creazione della catena
     requestTime@timestamp(request)(response);
     block.time = response;
     block.transaction << transaction;
     block.clientS << clientS;
     block.id = string(new);
     synchronized( syncBlockchain ){
       size = #global.Blockchain.block;
       //se la transazione non è ancora stata scritta allora creo il blocco e lo invio
       if(global.Blockchain.block[size-1].transaction.id != block.transaction.id){
         block.previousId = global.Blockchain.block[size-1].id;
         //println@Console( "block.previous id "+global.Blockchain.block[size-1].id + " clients:  "+global.Blockchain.block[size-1].clientS.publicKey )();
         global.hash = block.id;
         global.numAck = 0;
         global.isOk = " ";
         sendBlock@broadcast( block )
       }else{
         println@Console( "transazione gia scritta: "+transaction.id +" , " + global.Blockchain.block[size-1].transaction.id)()
       }
     };

     if(nodeBuyer == MyPublicKey){
       //ricezione dei jollar
       //aggiungo la transazione all'array delle entrate
       posizione = #global.entrate.transaction;
       global.entrate.transaction[posizione]<<block.transaction;
       global.jollarIn += jollar;
       stampaSaldo;
       mostraOpzioni
     }
  }

  //METODO PER RICEVERE RISPOSTA DELL'ESECUZIONE CORRETTA DELLA TRANSAZIONE
  [ackSendTransaction( risposta )]{
    if(risposta.messaggio == "ok"){
      println@Console("La transazione e' avvenuta correttamente")();
      //aggiungo la transazione all'array delle uscite
      posizione = #global.uscite.transaction;
      global.uscite.transaction[posizione] << risposta.transaction;
      //sottraggo i jollar venduti dal proprio saldo
      global.jollarIn -= global.jollarOut;
      stampaSaldo;
      mostraOpzioni
    }else{
      println@Console("La transazione non e' avvenuta correttamente, probabilmente il client a cui si vuole inviare e' offline")();
      stampaSaldo;
      mostraOpzioni
    }
  }

  //validazione del Blocco
  [sendBlock ( block )]{
    //controllo del previousHash
    synchronized( syncBlockchain ){
      size = #global.Blockchain.block;
      myId = global.Blockchain.block[size-1].id;
      //se l'id del'ultimo blocco della mia blockchain è diverso dal previousid del blocco che deve essere
      //validato e quindi aggiunto successivamente alla blockchain, richiedo sincronizzazione al broadcast,
      //se la blockchain ufficiale che mi restituisce è uguale alla mia, questo vuol dire che era l'altro client
      //quello non sincronizzato.
      //invece se la blockchain restituita è diversa dalla mia, io non sono sincronizzato e quindi aggiorno la BlockChain
      isOk = "true";
      if(myId != block.previousId){
        //richiedo sincronizzazione
        //println@Console( "Richiesta Sincro(validazione blocco di "+block.clientS.publicKey+")" )();
        sincro@broadcast()(array);
        proceduraDiSincronizzazione
      }
    };
    if(isOk == "true"){
      //controllo della primalità dei numeri
      num << block.catena.numeriPrimi;
      catena = block.catena.lunghezza;
      i = 0;
      while( i < catena){
        if(num[i] == 2){
          powrequest.base = 3
        }else{
          powrequest.base = 2
        };
          powrequest.exponent = num[i]-1;
          //println@Console("base "+powrequest.base+", esponente "+powrequest.exponent)();
          pow@Math(powrequest)(number);
          //println@Console("operazione "+number+" "+(num[i])+" "+(number % num[i]))();
          if( (number % num[i]) != 1 ){
            i = i+1;
            isOk = "Errore_NumeriPrimi"
          }else{
            i = i+1
          }
      };
      if(isOk == "true"){
        //controllo della difficulty della catena
        //prendo ultimo blocco della catena
        pos = #global.Blockchain.block;
        //controllo se difficoltà ultimo blocco è maggiore, allora errore
        if(global.Blockchain.block[pos - 1].difficulty > block.difficulty){
          isOk = "Errore_Difficulty"
        }
      }
    };
    ack.isOk = isOk;
    ack.block << block;
    ackSendBlock@broadcast( ack )
  }

  [ackSendBlock( ack )]{
    if( ack.isOk == "true"){
      install( IOException => {
        println@Console("Errore ackSendBlock. " + IOException)()
      });
      if(ack.block.id == global.hash){
        synchronized( syncAck  ){
          if( global.isOk == " " || global.isOk == ack.isOk ){
            global.numAck = global.numAck + 1;
            numMaggioranza = int(#users/2)+1;
            global.isOk = ack.isOk;
            if(global.numAck == numMaggioranza){
              write@broadcast(ack.block) | scriviBlocco
            }
          }
        }
      }
    }else if(ack.isOk == "Errore_NumeriPrimi"){
      synchronized( syncAck ){
        if(ack.block.id == global.hash){
          if(global.isOk == " " || global.isOk == ack.isOk){
            global.numAck = global.numAck + 1;
            numMaggioranza = int(#users/2)+1;
            global.isOk = ack.isOk;
            if(global.numAck == numMaggioranza){
              //controllo se il primo numero della catena del blocco è uguale all'origine
              //in questo caso aumento, se è differente significa che l'ho già aumentato ed è l'ack duplicato
              if(ack.block.catena.numeriPrimi[0] == global.origine){
                //println@Console( "Errore numeri primi: aumento il numero di origine" )();
                synchronized( syncOrigine  ){
                  global.origine = global.origine + 1;
                  global.lunghezza = 1
                }
              };
              if(global.origine > 41){
                println@Console( "LA DEMO HA RAGGIUNTO IL LIMITE MASSIMO DEL NUMERO DI ORIGINE DELLE CATENE. IMPOSSIBILE PROSEGUIRE" )();
                println@Console( "Digitare 'exit' per chiudere il client." )()
              }else{
                //controllo se il blocco è già stato scritto
                size = #global.Blockchain.block;
                if(ack.block.previousId != global.Blockchain.block[size-1].previousId){
                  //se il blocco non è ancora stato scritto cerco una nuova catena
                  creationChain;
                  ack.block.catena << chain;
                  ack.block.difficulty = diff;
                  requestTime@timestamp(request)(response);
                  ack.block.time = response;
                  ack.block.id = string(new);
                  global.hash = ack.block.id;
                  global.numAck = 0;
                  global.isOk = " ";
                  sendBlock@broadcast( ack.block )
  /*
                }else{
                  println@Console("Blocco gia' scritto")()
  */
                }
              }
            }
          }
        }
      }
    }else{
      if(ack.isOk == "Errore_Difficulty"){
        synchronized( syncAck ){
          if(ack.block.id == global.hash){
            if(global.isOk == " " || global.isOk == ack.isOk){
              global.numAck = global.numAck + 1;
              numMaggioranza = int(#users/2)+1;
              global.isOk = ack.isOk;
              if(global.numAck == numMaggioranza){
                //println@Console( "Errore_Difficulty: aumento lunghezza catena" )();
                //controllo se il blocco non è ancora stato scritto
                size = #global.Blockchain.block;
                if(ack.block.previousId != global.Blockchain.block[size-1].previousId){
                  //se la difficoltà è bassa creao una catena che parte dalla stessa origine
                  //ma che ha lunghezza l+1 rispetto a quella che risulta avere una difficolta troppo bassa!
                  creationChain; //creo catena
                  //modifica del blocco
                  ack.block.catena << chain;
                  ack.block.difficulty = diff;
                  requestTime@timestamp(request)(response);
                  ack.block.time = response;
                  //nuovo invio del blocco
                  ack.block.id = string(new);
                  global.hash = ack.block.id;
                  global.numAck = 0;
                  global.isOk = " ";
                  sendBlock@broadcast( ack.block )
  /*
                }else{ //se il blocco è già stato sctitto.
                  println@Console("Blocco gia' scritto")()
  */
                }
              }
            }
          }
        }
/*
      }else{
        if(ack.isOk == "Errore_Sincro"){
          println@Console( "Blocco non validato perche non sincronizzato." )()
        }
*/
      }
    }
  }

  [requestData(request)(response) {
    //1 chiave del client
    response.pkClient = MyPublicKey;
    //2 saldo dei jollar
    response.saldo = global.jollarIn;
    //3 transazione effettuate divise per entrate ed uscite
    response.entrate << global.entrate;
    response.uscite << global.uscite;
    //4 versione della blockchain
    response.blockchain << global.Blockchain
  }]

  [getBlockchain(req)(resp){
      resp << global.Blockchain
  }]

  [write(block)]{
    //cerco la posizione in cui aggiungere il blocco
    synchronized( syncBlockchain ){
      //println@Console( "write ricevuta da "+block.clientS.publicKey )();
      WriteFileRequest.filename = "FileClient4.json";
      posizione = #global.Blockchain.block;
      //controllo che il previousId sia uguale all'id dell'ultimo Blocco
      if(global.Blockchain.block[posizione-1].id == block.previousId ){
        println@Console( "Scrivo blocco di "+block.clientS.publicKey )();
        global.Blockchain.block[posizione]<<block
/*
      }else{
        if(global.Blockchain.block[posizione-1].previousId == block.previousId){
          println@Console( "Blocco gia scritto. S: " + block.clientS.publicKey)()
        }else{
          println@Console( "Blocco non scritto, non sincronizzato. "+ block.clientS.publicKey)()
        }
*/
      };
      testo<<global.Blockchain;
      WriteFileRequest.content<<testo;
      WriteFileRequest.format = "json";
      writeFile@File(WriteFileRequest)()
    }
  }
}
