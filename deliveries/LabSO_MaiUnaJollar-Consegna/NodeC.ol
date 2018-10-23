include "interface.iol"
include "console.iol"
include "math.iol"
include "message_digest.iol"
include "security_utils.iol"
include "time.iol"
//outputPort del Server
outputPort ServersendToC {
  Location: "socket://localhost:9030"
  Protocol: sodep
  Interfaces: Interfaccia
}

//output dei nodi
outputPort AsendToC {
  Location: "socket://localhost:9130"
  Protocol: sodep
  Interfaces: Interfaccia
}

outputPort BsendToC {
  Location: "socket://localhost:9230"
  Protocol: sodep
  Interfaces: Interfaccia
}

outputPort DsendToC {
  Location: "socket://localhost:9430"
  Protocol: sodep
  Interfaces: Interfaccia
}

outputPort NetworkVisualizer {
  Location: "socket://localhost:9510"
  Protocol: sodep
  Interfaces: Interfaccia
}

//inputPort dei nodi
inputPort RequestFromA {
  Location: "socket://localhost:9310"
  Protocol: sodep
  Interfaces: Interfaccia
}

inputPort RequestFromB {
  Location: "socket://localhost:9320"
  Protocol: sodep
  Interfaces: Interfaccia
}

inputPort RequestFromD {
  Location: "socket://localhost:9340"
  Protocol: sodep
  Interfaces: Interfaccia
}
/*********************************/

define Visualizer {

  println@Console( "Se vuoi vedere le informazioni sul sistema, digita: si." )();

  in (scelto);
  if (scelto == "si") {

    scope(timeVisualizer){
      getCurrentDateTime@Time(format)(reqTime);
      visualizer.request = reqTime
    };

    scope( statusVisualizer ){

      if( activeNode.nodeA) {
        visualizer.status.nodeA = true
        } else {
          visualizer.status.nodeA = false
        };
        if (activeNode.nodeB){
          visualizer.status.nodeB = true
          } else {
            visualizer.status.nodeB= false
          };
          if (activeNode.nodeC){
            visualizer.status.nodeC = true
            } else {
              visualizer.status.nodeC= false
            };
            if (activeNode.nodeD){
              visualizer.status.nodeD = true
              } else {
                visualizer.status.nodeD= false
              }
            };

            scope(transVisualizer) {
              // visualizer.transactions.nodeBuyer =
              // visualizer.transactions.nodeSeller =
              visualizer.transactions.amount = totalamount;
              visualizer.transactions.nodeSeller.publicKey = Block.Transaction.nodeSeller.publicKey
            };
            sendInfo@NetworkVisualizer(visualizer)
            } else {
              println@Console( "ERROR" )();
              Visualizer
            }
          }

          //OK NON TOCCARE
          define TrasferisciJollar {
            println@Console("Quanti jollar vuoi inviare ?")();
            in (inputamount);
            println@Console("Hai deciso di trasferire " + inputamount)()
          }

          //OK NON TOCCARE
          define StampaTotaleJollar {
            println@Console("HAI " + totalamount)();
            if(totalamount != 0)
            {
              println@Console("ORA COMPRATI UNA LAMBO! (o ARMI)")()
            }
            else
            {
              println@Console("SEI POVERO")()
            }
          }

          define VerificaFermat{
            println@Console("Verifica di Fermat")();
            fermat = 0;
            PowRequest.base = 2;

            PowRequest.exponent--;
            pow@Math(PowRequest)(resultPow);
            PowRequest.exponent++;
            condizione = true;
            while(condizione){
              fermat = (resultPow%PowRequest.exponent);

              //da commentare dopo aver eseguito dei test sulla potenza
              println@Console(" Il remainder di Fermat e': " + fermat)();

              if(fermat == 1 || PowRequest.exponent == 2){
                println@Console("******primo******")();
                condizione = false
                }else {
                  println@Console("******fermat no primo******")();

                  condizione = false;

                  chainPrime = false
                }
              };
              println@Console("FINE Verifica di Fermat")()
            }

            //la lunghezza della catena è usata per regolare la difficoltà.
            //l'unico problema è che la lunghezza della catena principale è un valore discreto la cui difficoltà aumenta in modo esponenziale.
            //primecoin ha risolto questo problema usando la lunghezza frazionaria.

            // d = k + (pk-r)/pk
            //LA USIAMO PER VEIFICARE CHE LUNGHEZZA OK ??
            define lunghezzaFrazionaria
            {
              k = double(lunghezzaCatena);
              pk = double(PowRequest.exponent);
              r = double(fermat);
              fracLenght =  k + (pk - r) / pk;
              println@Console("La lunghezzaFrazionaria e': " + double(fracLenght) )()
            }

            //OK PER ORA
            define RewardNode {
              totalamount = totalamount + 6;
              println@Console( "HAI RICEVUTO 6 JOLLAR di REWARD" )();
              StampaTotaleJollar
            }

            //DA RIVEDERE MA OK
            define ControlloCatena {
              println@Console(m.m)();
              if(m.m == "VERIFICA OTTENUTA")
              {
                verificheTotali++
              }
              else if (m.m == "VERIFICA FALLITA")
              {
                verificheTotali = verificheTotali
              }
            }

            define InviaFineTransazione
            {
                m.m = string("FINE TRANSAZIONE");
                if(activeNode.nodeA)
                  inviaMessaggio@AsendToC(m);
                if(activeNode.nodeB)
                  inviaMessaggio@BsendToC(m);
                if(activeNode.nodeD)
                  inviaMessaggio@DsendToC(m)
            }

            define exitmenu {
              println@Console("Selezione l'operazione da fare:")();
              println@Console("Digita '1' per inviare jollar a A")();
              println@Console("Digita '2' per inviare jollar a B")();
              println@Console("Digita '3' per inviare jollar a D")();

              in ( inserimento );

              m.m = string("Amount");

              if(inserimento == 1 || inserimento == 2 || inserimento == 3){

                sendNumber@ServersendToC(x);
                z.z = string("Richiesta al Server da parte di C");
                requestTimeStampToServer@ServersendToC(z)(y);
                getCurrentDateTime@Time(format)(reqTime);
                println@Console("TimeStamp: " + y.y)();
                println@Console("TIME: " + reqTime)();

                if(inserimento == 1){
                  inviaMessaggio@AsendToC(m);
                  m.m = string("In arrivo JOLLAR a A inviati da C");
                  inviaMessaggio@AsendToC(m);

                  TrasferisciJollar;

                  if(inputamount<=totalamount && inputamount >= 0){
                    amount.amount = int(inputamount);
                    println@Console("Trasferimento di " + amount.amount + " JOLLAR in corso...")();
                    sendMoney@AsendToC(amount);
                    totalamount = totalamount-inputamount
                  }
                  else{
                    println@Console("ERRORE")();
                    amount.amount = -1;
                    sendMoney@AsendToC(amount);
                    exitmenu
                  }

                  } else if(inserimento == 2){
                    inviaMessaggio@BsendToC(m);
                    m.m = string("In arrivo JOLLAR a B inviati da C");
                    inviaMessaggio@BsendToC(m);

                    TrasferisciJollar;

                    if(inputamount<=totalamount && inputamount >= 0){
                      amount.amount = int(inputamount);
                      println@Console("Trasferimento di " + amount.amount + " JOLLAR in corso...")();
                      sendMoney@BsendToC(amount);
                      totalamount = totalamount-inputamount
                    }
                    else{
                      println@Console("ERRORE")();
                      amount.amount = -1;
                      sendMoney@BsendToC(amount);
                      exitmenu
                    }

                    } else if(inserimento == 3){
                      inviaMessaggio@DsendToC(m);
                      m.m = string("In arrivo JOLLAR a D inviati da C");
                      inviaMessaggio@DsendToC(m);

                      TrasferisciJollar;

                      if(inputamount<=totalamount && inputamount >= 0){
                        amount.amount = int(inputamount);
                        println@Console("Trasferimento di " + amount.amount + " JOLLAR in corso...")();
                        sendMoney@DsendToC(amount);
                        totalamount = totalamount-inputamount
                      }
                      else{
                        println@Console("ERRORE")();
                        amount.amount = -1;
                        sendMoney@DsendToC(amount);
                        exitmenu
                      }
                    };
                    StampaTotaleJollar;
                    Visualizer;
                    InviaFineTransazione
                  }
                  else{
                    exitmenu
                  }

                }

                //OK NON MODIFICARE
                define chainVerifyResult {

                  if(chainPrime == true){
                    m.m = string("VERIFICA OTTENUTA")
                    }else{
                      m.m = string("VERIFICA FALLITA")
                    }
                  }

                  //DIREI OK
                  define VerificaCunningham{
                    chainPrime = true;
                    h=0;
                    j=0;
                    k=0;

                    while(j<lunghezzaCatena && chainPrime)
                    {
                      if(chain.type == "CunninghamPrimo")
                      {
                        println@Console("Verifica di :  " + chain.CunninghamPrimo.numCunP[h])();
                        PowRequest.exponent = chain.CunninghamPrimo.numCunP[h]
                      };
                      if(chain.type == "CunninghamSecondo")
                      {
                        println@Console("Verifica di :  " + chain.CunninghamSecondo.numCunS[j])();
                        PowRequest.exponent = chain.CunninghamSecondo.numCunS[j]
                      };
                      if(chain.type == "BiTwin")
                      {
                        println@Console("Verifica di :  " + chain.BiTwin.numBiTw[k])();
                        PowRequest.exponent = chain.BiTwin.numBiTw[k]
                      };
                      if(chain.type == "BiTwin"){
                        lunghezzaCatena--
                      };
                      VerificaFermat;
                      // println@Console(chainPrime)();
                      h++;
                      j++;
                      k++
                    };


                    chainVerifyResult
                  }

                  define WaitForMessage{
                    inviaMessaggio(m);			//ricevi messaggio
                    println@Console(m.m)();
                    println@Console( "MESSAGGIO RICEVUTO" )();
                    if(m.m == "chain"){
                      println@Console( "Ricezione catena in corso")();

                      inviaMessaggio(m);
                      chain.creator = string(m.m);		//chi ti sta inviando la catena
                      println@Console("Il creatore della catena e' " + chain.creator)();

                      inviaMessaggio(m);
                      lunghezzaCatena = int(m.m);
                      println@Console("La lunghezza della catena e' " + lunghezzaCatena)();

                      inviaMessaggio(m);
                      chain.type = m.m;
                      println@Console("Il tipo della catena e' " + chain.type)();

                      println@Console( "Ricezione numeri in corso...")();

                      if(chain.type == "CunninghamPrimo"){
                        for(h=0, h < lunghezzaCatena, h++){
                          inviaMessaggio(m);
                          chain.CunninghamPrimo.numCunP[h] = int(m.m)
                        }
                      };
                      if(chain.type == "CunninghamSecondo"){
                        for(j=0, j < lunghezzaCatena, j++){
                          inviaMessaggio(m);
                          chain.CunninghamSecondo.numCunS[j] = int(m.m)
                        }
                      };
                      if(chain.type == "BiTwin"){
                        for(k=0, k< lunghezzaCatena, k++){
                          inviaMessaggio(m);
                          chain.BiTwin.numBiTw[k] = int(m.m)
                        }
                      };

                      VerificaCunningham;

                      //invia messaggio se VerificaCunningham e' verificata
                      //oppure  no, e la manda agli altri
                      //riceve la stringa "catena verifica"

                      if(chain.creator == "A")
                      {
                        inviaMessaggio@AsendToC(m)
                      };
                      if(chain.creator == "B")
                      {
                        inviaMessaggio@BsendToC(m)
                      };
                      if(chain.creator == "D")
                      {
                        inviaMessaggio@DsendToC(m)
                      }

                    }
                    else if (m.m == "Amount"){
                      inviaMessaggio(m);
                      println@Console(m.m)();
                      sendMoney(amount);

                      if(amount.amount != -1){
                        totalamount = totalamount + amount.amount;
                        println@Console( "HAI RICEVUTO " + amount.amount + " JOLLAR" )();
                        StampaTotaleJollar
                      }
                      else{
                        println@Console("Procedura fallita")()
                      }

                    }
                    else if(m.m == "check")
                    {
                      println@Console("IL NODO E' ATTIVO")()
                    }

                    else if(m.m == "ChainVerByBroadcast")
                    {
                      exitmenu
                      |
                      WaitForMessage
                    }
                    else if(m.m == "FINE TRANSAZIONE")
                    {
                    WaitForMessage
                    }


                    else if(m.m == "CALCOLO LUNGHEZZA A")
                    {
                      inviaLung@AsendToC(lunghezzaCatena)
                    }
                    else if(m.m == "CALCOLO LUNGHEZZA B")
                    {
                      inviaLung@BsendToC(lunghezzaCatena)
                    }
                    else if(m.m == "CALCOLO LUNGHEZZA D")
                    {
                      inviaLung@DsendToC(lunghezzaCatena)
                    };

                    WaitForMessage
                  }

                  //OK DA MOD
                  //allora per fare il difficultyCalculator dobbiamo definire K come lunghezza della catena primi.
                  //P0,P1...Pk-1 è la catena di numeri primi
                  //R è il test di Fermat
                  //la formula è p  K/r
                  //R dovrebbe essere il numero primo SUCCESSIVO
                  define difficultyCalculator{
                    //esempio a caso per calcolo difficoltà
                    Block.difficulty =  PowRequest.exponent/fermat; //lunghezzaCatena + 0.25 ; //r=
                    println@Console("La difficoltà e' " + Block.difficulty)();
                    println@Console("PowExp e "+  PowRequest.exponent )();
                    println@Console("fermat e "+ fermat )()
                  }

                  //E' GIUSTO IN A  O IN B O BOH
                  //OK NON MODIFICARE  ---- non ci serve se l'implementato dentro createhash
                  // define hashi{
                  //   md5@MessageDigest(hashnocode)(global.resulthash);
                  //   println@Console( global.resulthash )()
                  // }

                  //OK MA MOD
                  define createhash{

                    testVar=0;
                    //while solo per vedere se funziona
                    while(testVar<3) {
                      println@Console("creazione blocco")();
                      Block.previousBlockHash = resulthash; // l'iniziale hash ha previousHash=null, dopo il primo ciclo previoushHash=resulthash dal
                      // precedente hash, nodo A crea il primo hash allora non ha previousHash?


                      //Block.difficulty = 2;
                      difficultyCalculator;

                      //credo che la chiave publica e un hash dalla chaive privata perche non ha senso che tutte due (private/public)
                      // sono separato generati random.

                      // createSecureToken@SecurityUtils()(Block.Transaction.nodeSeller.publicKey);
                      // println@Console("la chiave public di Seller e' " + Block.Transaction.nodeSeller.publicKey)();

                      createSecureToken@SecurityUtils()(Block.Transaction.nodeSeller.privateKey);
                      println@Console("la chiave private di Seller e': " + Block.Transaction.nodeSeller.privateKey)();

                      md5@MessageDigest(Block.Transaction.nodeSeller.privateKey)(Block.Transaction.nodeSeller.publicKey);
                      println@Console( "la chiave public di Seller e': " + Block.Transaction.nodeSeller.publicKey )();

                      // createSecureToken@SecurityUtils()(Block.Transaction.nodeBuyer.publicKey);
                      // println@Console("la chiave public di Buyer e' " + Block.Transaction.nodeBuyer.publicKey)();

                      createSecureToken@SecurityUtils()(Block.Transaction.nodeBuyer.privateKey);
                      println@Console("la chiave private di Buyer e': " + Block.Transaction.nodeBuyer.privateKey)();

                      md5@MessageDigest(Block.Transaction.nodeBuyer.privateKey)(Block.Transaction.nodeBuyer.publicKey);
                      println@Console( "la chiave public di Buyer e': " + Block.Transaction.nodeBuyer.publicKey)();

                      hashnocode = string("#" + Block.previousBlockHash + "#"+
                      Block.difficulty + "#" +
                      Block.Transaction.nodeSeller.publicKey + "#"+
                      Block.Transaction.nodeSeller.privateKey + "#" +
                      Block.Transaction.nodeBuyer.publicKey + "#" +
                      Block.Transaction.nodeBuyer.privateKey
                      ) ;

                      println@Console("Hashcode= " + hashnocode)();
                      if (Block.previousBlockHash != null ) {
                        println@Console( "Previous Block Hash= " + Block.previousBlockHash )()
                      }
                      else {
                        println@Console( "Previous Block Hash= 0" )()
                      };

                      md5@MessageDigest(hashnocode)(resulthash);
                      println@Console( "ResultHash= " + resulthash )();

                      // println@Console("previousBlockHash= " + Block.previousBlockHash)();
                      //
                      //
                      //
                      // hashi;
                      testVar++
                    }
                  }

                  // il test di Fermat controlla se un numbero e prime: aumentare qualsiasi numero (in genere 2) alla potenza di un primo,
                  // sottrarre il numero primo quante più volte possibile e vedere se si ottiene il numero originale. Esempio: 217– 17 * 7710 = 2
                  //  223– 23 * 364722 = 2 ma 221– 21 * 99864 = 8.

                  // Una formulazione alternativa, e leggermente migliore, è di aumentare il numero alla potenza del primo meno e vedere se ne
                  //ottieni 1 (questo essere vero implica chiaramente il numero che passa l'altro test)
                  //come si può distinguere tra una catena 7,2 primi lunghi e una catena 7,5 primi lunghi?
                  // guarda il valore risultante del test di Fermat del primo valore nella catena per non essere un numero primo. più basso è,più maggiore è la "lunghezza frazionaria".
                  //esempio una catena 2,5,11 ha il prossimo valore di 23 , allora 2^22 modulo 23 = 1.Quindi la catena avrebbe una lunghezza di:
                  //la nostra catena di 2, 5, 11, 23, 47 ha il valore successivo 95, 2^94m odulo 95 è 54,
                  // quindi la catena avrà una lunghezza di 5 + (95 - 54) / 95 ~ = 5,43.affinché una catena principale possa contare come prova valida del lavoro, deve avere
                  // una lunghezza frazionaria almeno uguale alla difficoltà; al momento della stesura di questo parametro, questo parametro fluttua attorno a 7.1

                  //
                  // define FindRandom {
                  //
                  //   conditionRandom = true;
                  //
                  //   while(conditionRandom)
                  //   {
                  //     random@Math()(result);
                  //     //	println@Console("random number is: " + result )();
                  //     cast=int(result);
                  //     cast=result*10;
                  //     //	println@Console("casted number is: " + cast )();
                  //     rnd.decimals = cast;
                  //     round@Math(rnd.decimals)(newResult);
                  //     // newResult=result*10;
                  //     if(newResult<=3)		//usato per fare le prove di quali indici dell array prendere
                  //     {
                  //       //	println@Console( newResult )();
                  //       conditionRandom = false
                  //     }
                  //
                  //   };
                  //   n = newResult
                  //   //  println@Console(n)()
                  // }

                  define cunninghamPrimo{
                    chain.creator = string("C");

                    println@Console("la lunghezza della catena e' " + lunghezzaCatena)();

                    chain.type = "CunninghamPrimo";

                    println@Console("il tipo della catena e' " + chain.type)();

                    println@Console("Numero di partenza " + numRand)();

                    for ( i = 0, i < lunghezzaCatena, i++ ) {
                      if(i == 0){
                        chain.CunninghamPrimo.numCunP[i] = numRand;
                        println@Console(chain.CunninghamPrimo.numCunP[i])()
                      }
                      else{
                        chain.CunninghamPrimo.numCunP[i] = ((2*chain.CunninghamPrimo.numCunP[i-1]) + 1);
                        println@Console(chain.CunninghamPrimo.numCunP[i])()
                      }
                    }
                  }

                  define cunninghamSecondo{
                    chain.creator = string("C");

                    println@Console("la lunghezza della catena e' " + lunghezzaCatena)();

                    chain.type = "CunninghamSecondo";

                    println@Console("il tipo della catena e' " + chain.type)();

                    println@Console("Numero di partenza " + numRand)();

                    for ( i = 0, i < lunghezzaCatena, i++ ) { // in realtà sarebbe la difficulty direi
                      if(i == 0){
                        chain.CunninghamSecondo.numCunS[i] = numRand;
                        println@Console(chain.CunninghamSecondo.numCunS[i])()
                      }
                      else{
                        chain.CunninghamSecondo.numCunS[i] = ((2*chain.CunninghamSecondo.numCunS[i-1]) - 1);
                        println@Console(chain.CunninghamSecondo.numCunS[i])()
                      }
                    }
                  }

                  define biTwin{
                    chain.creator = string("C");
                    lunghezzaCatena++;
                    println@Console("la lunghezza della catena e' " + lunghezzaCatena)();

                    chain.type = "BiTwin";

                    println@Console("il tipo della catena e' " + chain.type)();

                    println@Console("Numero di partenza " + numRand)();
                    indicePow = 0;
                    for ( i = 1, i < lunghezzaCatena, i = i+2) {
                      PowRequest.base = 2;
                      PowRequest.exponent = indicePow;
                      pow@Math(PowRequest)(resultPostPow);
                      resultPostPow = int(resultPostPow);
                      chain.BiTwin.numBiTw[i-1] = resultPostPow*numRand - 1;
                      chain.BiTwin.numBiTw[i] = resultPostPow*numRand + 1;

                      println@Console(chain.BiTwin.numBiTw[i-1])();
                      println@Console(chain.BiTwin.numBiTw[i])();
                      indicePow++
                    }
                  }

                  //Per Verificare le catene
                  /////////////////////////////////////////////////////
                  define VerificaCunninghamC{
                    VerificaCunningham;
                    ControlloCatena
                  }

                  define InviaCunninghamA{
                    println@Console("Invio della catena")();
                    m.m = string("chain");
                    inviaMessaggio@AsendToC(m);

                    m.m = string(chain.creator);
                    inviaMessaggio@AsendToC(m);

                    m.m = string(lunghezzaCatena);
                    inviaMessaggio@AsendToC(m);

                    m.m = string(chain.type);
                    inviaMessaggio@AsendToC(m);

                    if(chain.type == "CunninghamPrimo")
                    {
                      for(h=0,h<lunghezzaCatena,h++){
                        m.m = string(chain.CunninghamPrimo.numCunP[h]);
                        inviaMessaggio@AsendToC(m)
                      }
                    };
                    if(chain.type == "CunninghamSecondo")
                    {
                      for(j=0,j<lunghezzaCatena,j++){
                        m.m = string(chain.CunninghamSecondo.numCunS[j]);
                        inviaMessaggio@AsendToC(m)
                      }
                    };
                    if(chain.type == "BiTwin")
                    {
                      for(k=0,k<lunghezzaCatena,k++){
                        m.m = string(chain.BiTwin.numBiTw[k]);
                        inviaMessaggio@AsendToC(m)
                      }
                    };
                    inviaMessaggio(m);
                    ControlloCatena
                  }

                  define InviaCunninghamB{
                    println@Console("Invio della catena")();
                    m.m = string("chain");
                    inviaMessaggio@BsendToC(m);

                    m.m = string(chain.creator);
                    inviaMessaggio@BsendToC(m);

                    m.m = string(lunghezzaCatena);
                    inviaMessaggio@BsendToC(m);

                    m.m = string(chain.type);
                    inviaMessaggio@BsendToC(m);

                    if(chain.type == "CunninghamPrimo")
                    {
                      for(h=0,h<lunghezzaCatena,h++){
                        m.m = string(chain.CunninghamPrimo.numCunP[h]);
                        inviaMessaggio@BsendToC(m)
                      }
                    };
                    if(chain.type == "CunninghamSecondo")
                    {
                      for(j=0,j<lunghezzaCatena,j++){
                        m.m = string(chain.CunninghamSecondo.numCunS[j]);
                        inviaMessaggio@BsendToC(m)
                      }
                    };
                    if(chain.type == "BiTwin")
                    {
                      for(k=0,k<lunghezzaCatena,k++){
                        m.m = string(chain.BiTwin.numBiTw[k]);
                        inviaMessaggio@BsendToC(m)
                      }
                    };
                    inviaMessaggio(m);
                    ControlloCatena
                  }

                  define InviaCunninghamD{
                    println@Console("Invio della catena")();
                    m.m = string("chain");
                    inviaMessaggio@DsendToC(m);

                    m.m = string(chain.creator);
                    inviaMessaggio@DsendToC(m);

                    m.m = string(lunghezzaCatena);
                    inviaMessaggio@DsendToC(m);

                    m.m = string(chain.type);
                    inviaMessaggio@DsendToC(m);

                    if(chain.type == "CunninghamPrimo")
                    {
                      for(h=0,h<lunghezzaCatena,h++){
                        m.m = string(chain.CunninghamPrimo.numCunP[h]);
                        inviaMessaggio@DsendToC(m)
                      }
                    };
                    if(chain.type == "CunninghamSecondo")
                    {
                      for(j=0,j<lunghezzaCatena,j++){
                        m.m = string(chain.CunninghamSecondo.numCunS[j]);
                        inviaMessaggio@DsendToC(m)
                      }
                    };
                    if(chain.type == "BiTwin")
                    {
                      for(k=0,k<lunghezzaCatena,k++){
                        m.m = string(chain.BiTwin.numBiTw[k]);
                        inviaMessaggio@DsendToC(m)
                      }
                    };
                    inviaMessaggio(m);
                    ControlloCatena
                  }

                  //Controlla nodi attivi
                  ////////////////////////////////
                  define VerificaStatoA{

                    scope(VerifyConnectionA){
                      activeNode.nodeA = true;
                      {
                        install ( IOException => activeNode.nodeA = false );
                        install ( ConnectException => print@Console("")() );
                        m.m = string("check");
                        inviaMessaggio@AsendToC(m);
                        throw ( ConnectException )
                      }
                    };
                    println@Console("STATO NODO A " + activeNode.nodeA)()
                  }
                  define VerificaStatoB{

                    scope(VerifyConnectionB){
                      activeNode.nodeB = true;
                      {
                        install ( IOException => activeNode.nodeB = false );
                        install ( ConnectException => print@Console("")() );
                        m.m = string("check");
                        inviaMessaggio@BsendToC(m);
                        throw ( ConnectException )
                      }
                    };
                    println@Console("STATO NODO B " + activeNode.nodeB)()
                  }

                  define VerificaStatoC{
                    activeNode.nodeC=true;
                    println@Console("STATO NODO C "+ activeNode.nodeC)()
                  }

                  define VerificaStatoD{

                    scope(VerifyConnectionD){
                      activeNode.nodeD = true;
                      {
                        install ( IOException => activeNode.nodeD = false );
                        install ( ConnectException => print@Console("")() );
                        m.m = string("check");
                        inviaMessaggio@DsendToC(m);
                        throw ( ConnectException )
                      }
                    };
                    println@Console("STATO NODO D " + activeNode.nodeD)()
                  }

                  define VerificaStatoNodi
                  {
                    println@Console("VERIFICA NODI ATTIVI")();
                    VerificaStatoA;
                    VerificaStatoB;
                    VerificaStatoC;
                    VerificaStatoD;
                    println@Console("VERIFICA NODI ATTIVI CONCLUSA")()
                  }

                  //count dei nodi attivi da usare dopo per fare le verifiche delle catene
                  define CalcolaNodiAttivi {
                    nodiAttivi = 0;

                    if(activeNode.nodeA)
                    {
                      nodiAttivi++;
                      println@Console("NODO A ATTIVO")()
                    };
                    if(activeNode.nodeB)
                    {
                      nodiAttivi++;
                      println@Console("NODO B ATTIVO")()
                    };
                    if(activeNode.nodeC)
                    {
                      nodiAttivi++;
                      println@Console("NODO C ATTIVO")()
                    };
                    if(activeNode.nodeD)
                    {
                      nodiAttivi++;
                      println@Console("NODO D ATTIVO")()
                    };

                    println@Console("TOTALE NODI ATTIVI " + nodiAttivi)()

                  }

                  //invia agli altri che è stata trovata una catena giusta
                  define InviaConfermaBroadcast {
                    m.m = string("ChainVerByBroadcast");
                    if(activeNode.nodeA)
                    {
                      inviaMessaggio@AsendToC(m)
                    };
                    if(activeNode.nodeB)
                    {
                      inviaMessaggio@BsendToC(m)
                    };
                    if(activeNode.nodeD)
                    {
                      inviaMessaggio@DsendToC(m)
                    }
                  }

                  define CreaCatene {
                    if(contatoreCatene == 1){
                      condRand = true;
                      random@Math()(doublePreCast);
                      numRand = int(doublePreCast*10);
                      while(condRand){
                        if(numRand != 1 && numRand != 0){
                          condRand = false;
                          cunninghamPrimo
                          } else{
                            random@Math()(doublePreCast);
                            numRand = int(doublePreCast*10)
                          }
                        };
                        println@Console("numero random generato " + numRand)();
                        contatoreCatene++
                      }
                      else if(contatoreCatene == 2){
                        contatoreCatene++;
                        cunninghamSecondo
                        } else if(contatoreCatene == 3){
                          contatoreCatene++;
                          biTwin
                        }
                        else
                        {
                          contatoreCatene = 1;
                          CreaCatene
                        }
                      }

                      define CalcolaLunghezzaCatena
                      {
                        VerificaStatoNodi;
                          m.m = string("CALCOLO LUNGHEZZA C");

                          lunghezzaCatena = 0;
                          lunghezzaInviataA = 0;
                          lunghezzaInviataB = 0;
                          lunghezzaInviataD = 0;


                          if(activeNode.nodeA){
                            inviaMessaggio@AsendToC(m);
                            inviaLung(lunghezzaInviataA)
                          };
                          if(activeNode.nodeB){
                            inviaMessaggio@BsendToC(m);
                            inviaLung(lunghezzaInviataB)
                          };
                          if(activeNode.nodeD){
                            inviaMessaggio@DsendToC(m);
                            inviaLung(lunghezzaInviataD)
                          };

                          {
                          if(lunghezzaInviataA > lunghezzaInviataB)
                            lunghezzaCatena = lunghezzaInviataA
                          else
                            lunghezzaCatena = lunghezzaInviataB;

                          if (lunghezzaInviataD > lunghezzaCatena)
                            lunghezzaCatena = lunghezzaInviataD
                          };

                          if(lunghezzaCatena == 0){
                          lunghezzaCatena = 1
                        };

                          lunghezzaCatena++;
                          println@Console("LA LUNGHEZZA E' " + lunghezzaCatena)()

                      }


                      //Broadcast di catena per verifica ai nodi attivi
                      ////////////////////////////////////////////////////////
                      define VerificaBroadcast{

                        verificheTotali = 0;

                        VerificaCunninghamC;

                        if(activeNode.nodeA)
                        {
                          InviaCunninghamA
                        };
                        if(activeNode.nodeB)
                        {
                          InviaCunninghamB
                        };
                        if(activeNode.nodeD)
                        {
                          InviaCunninghamD
                        };

                        //se il nodo riceve il numero di verifiche UGUALI al numero di nodiAttivi
                        //il nodo si auto assegna  la REWARD iniziale di 6 jollar
                        if(verificheTotali == nodiAttivi){
                          println@Console("CATENA GIUSTA")();
                          RewardNode;
                          //BOH ??
                          if(nodiAttivi != 1)
                          {
                            InviaConfermaBroadcast;
                            exitmenu
                            |   //concorrente con WaitForMessage !!
                            WaitForMessage
                          }
                          else{
                            WaitForMessage
                          }
                        }
                        else{
                          println@Console("CATENA ERRATA")();
                          StampaTotaleJollar;

                          CreaCatene;

                          VerificaStatoNodi;
                          CalcolaNodiAttivi;
                          VerificaBroadcast
                        }
                      }

                      /*ordine delle esecuzioni:
                      parte nodo A(ma con possibilita di cambiare NODO)
                      crea la catena.
                      se e' l unico nodo attivo se la autoverifica, altrimenti la manda agli altri in broadcast
                      lancia VerificaStatoNodi
                      esegue count
                      si mette in attesa

                      */


                      main
                      {
                        println@Console("node C started \n")();
                        registerForInput@Console()();
                        totalamount = 0;
                        contatoreCatene = 1;

                        createhash;

                        CalcolaLunghezzaCatena;

                        CreaCatene;
                        VerificaStatoNodi;
                        CalcolaNodiAttivi;
                        VerificaBroadcast

                        //    exitmenu;
                        //  createhash;

                        //  Visualizer

                        ////////
                        //;
                        //WaitForMessage
                        //exitmenu





                        // chainPrime = true;
                        // k = 0;
                        // while(k<lunghezzaCatena && chainPrime)
                        // {
                        //   println@Console("Verifica di :  " + chain.CunninghamSecondo.numCunS[k])();
                        //   PowRequest.exponent = chain.CunninghamSecondo.numCunS[k];
                        //   VerificaFermat;
                        //   // println@Console(chainPrime)();
                        //   k++
                        // }
                        // ;
                        //
                        // chainVerifyResult

                        //StampaTotaleJollar;
                        //createhash
                        //VerificaFermat
                        //  while(true) {
                        //  exitmenu
                        //  |
                        //  WaitForMessage
                        //}

                      }
