include "clientInterface.iol"
include "console.iol"
include "string_utils.iol"
include "file.iol"
include "time.iol"

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

inputPort MyInport {
    Location: "socket://localhost:8005/"
    Protocol: sodep
    Interfaces: ClientInterface
}

execution{ concurrent }

init{
  global.pkClient1 = " ";
  global.pkClient2 = " ";
  global.pkClient3 = " ";
  global.pkClient4 = " ";
  caricamentoSaldi
}

define caricamentoSaldi{
  //metodo che carica la blockchain all'avvio del client
  nome = "cash.json";
  //controllo se esiste il file
  exists@File(nome)(risposta);
  install( IOException => {
    println@Console("Errore nel caricament della blockchain !!!")()
  });
  if(risposta == true){ //se esiste carico i saldi nell'arraySaldi
    f.filename = "cash.json";
    f.format = "json";
    readFile@File(f)(res);
    for(i=0, i<#res.arraySaldi, i++){
      //println@Console( "res di i: "+res.arraySaldi[i] )();
      synchronized( syncArray ){
        global.array.arraySaldi[i] = res.arraySaldi[i]
      }
    }
  }else{
    for(i=0, i<4, i++){
      //println@Console( "array dei saldi a 0" )();
      synchronized( syncArray ){
        global.array.arraySaldi[i] = 0
      }
    }
  }
}

main{
  [sendKey ( autentication )]{
    if(autentication.clientID == "client1"){
      global.pkClient1 = autentication.pkClient;
      println@Console("chiave client 1: " + global.pkClient1)();
      //INVIO LA CHIAVE RICEVUTA AGLI ALTRI CLIENT
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 2 non e' disponibile!")() );
        sendKey@client2( autentication );
        println@Console("invio della chiave del client 1 al client 2")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 3 non e' disponibile!")() );
        sendKey@client3( autentication );
        println@Console("invio della chiave del client 1 al client 3")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 4 non e' disponibile!")() );
        sendKey@client4(autentication);
        println@Console("invio della chiave del client 1 al client 4")()
      };
      //INVIO LE ALTRE CHIAVI IN POSSESSO DEL BROADCAST AL CLIENT CHE MI HA INVIATO LA SUA CHIAVE
      if(global.pkClient2 != " "){
        autenticazione.clientID= "client2";
        autenticazione.pkClient = global.pkClient2;
        sendKey@client1( autenticazione )
      };
      if(global.pkClient3 != " "){
        autenticazione.clientID = "client3";
        autenticazione.pkClient = global.pkClient3;
        sendKey@client1( autenticazione )
      };
      if(global.pkClient4 != " "){
        autenticazione.clientID = "client4";
        autenticazione.pkClient = global.pkClient4;
        sendKey@client1( autenticazione )
      }
    }else if(autentication.clientID == "client2"){
      global.pkClient2 = autentication.pkClient;
      println@Console("chiave client 2: " + global.pkClient2)();
      //INVIO LA CHIAVE RICEVUTA AGLI ALTRI CLIENT
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 1 non e' disponibile!")() );
        sendKey@client1( autentication );
        println@Console("invio della chiave del client 2 al client 1")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 3 non e' disponibile!")() );
        sendKey@client3( autentication );
        println@Console("invio della chiave del client 2 al client 3")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 4 non e' disponibile!")() );
        sendKey@client4( autentication );
        println@Console("invio della chiave del client 2 al client 4")()
      };
      //INVIO LE ALTRE CHIAVI IN POSSESSO DEL BROADCAST AL CLIENT CHE MI HA INVIATO LA SUA CHIAVE
      if(global.pkClient1 != " "){
        autenticazione.clientID = "client1";
        autenticazione.pkClient = global.pkClient1;
        sendKey@client2( autenticazione )
      };
      if(global.pkClient3 != " "){
        autenticazione.clientID = "client3";
        autenticazione.pkClient = global.pkClient3;
        sendKey@client2( autenticazione )
      };
      if(global.pkClient4 != " "){
        autenticazione.clientID = "client4";
        autenticazione.pkClient = global.pkClient4;
        sendKey@client2( autenticazione )
      }
    }else if(autentication.clientID == "client3"){
      global.pkClient3 = autentication.pkClient;
      println@Console("chiave client 3: " + global.pkClient3)();
      //INVIO LA CHIAVE RICEVUTA AGLI ALTRI CLIENT
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 1 non e' disponibile!")() );
        sendKey@client1( autentication );
        println@Console("invio della chiave del client 3 al client 1")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 2 non e' disponibile!")() );
        sendKey@client2( autentication );
        println@Console("invio della chiave del client 3 al client 2")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 4 non e' disponibile!")() );
        sendKey@client4( autentication );
        println@Console("invio della chiave del client 3 al client 4")()
      };
      //INVIO LE ALTRE CHIAVI IN POSSESSO DEL BROADCAST AL CLIENT CHE MI HA INVIATO LA SUA CHIAVE
      if(global.pkClient1 != " "){
        autenticazione.clientID = "client1";
        autenticazione.pkClient = global.pkClient1;
        sendKey@client3( autenticazione )
      };
      if(global.pkClient2 != " "){
        autenticazione.clientID = "client2";
        autenticazione.pkClient = global.pkClient2;
        sendKey@client3( autenticazione )
      };
      if(global.pkClient4 != " "){
        autenticazione.clientID = "client4";
        autenticazione.pkClient = global.pkClient4;
        sendKey@client3( autenticazione )
      }
    }else{
      global.pkClient4 = autentication.pkClient;
      println@Console("chiave client 4: " + global.pkClient4)();
      //INVIO LA CHIAVE RICEVUTA AGLI ALTRI CLIENT
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 1 non e' disponibile!")() );
        sendKey@client1( autentication );
        println@Console("invio della chiave del client 4 al client 1")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 2 non e' disponibile!")() );
        sendKey@client2( autentication );
        println@Console("invio della chiave del client 4 al client 2")()
      };
      scope( scopeName )
      {
        install( IOException => println@Console("Il client 3 non e' disponibile!")() );
        sendKey@client3( autentication );
        println@Console("invio della chiave del client 4 al client 3")()
      };
      //INVIO LE ALTRE CHIAVI IN POSSESSO DEL BROADCAST AL CLIENT CHE MI HA INVIATO LA SUA CHIAVE
      if(global.pkClient1 != " "){
        autenticazione.clientID = "client1";
        autenticazione.pkClient = global.pkClient1;
        sendKey@client4( autenticazione )
      };
      if(global.pkClient2 != " "){
        autenticazione.clientID = "client2";
        autenticazione.pkClient = global.pkClient2;
        sendKey@client4( autenticazione )
      };
      if(global.pkClient3 != " "){
        autenticazione.clientID = "client3";
        autenticazione.pkClient = global.pkClient3;
        sendKey@client4( autenticazione )
      }
    }
  }

  //METODO PER LA RICEZIONE DELLE TRANSAZIONI DAI NODI
  [sendTransaction( sendTransactionReq )]{
    nodeBuyer = sendTransactionReq.nodeBuyerID.publicKey;
    nodeSeller = sendTransactionReq.nodeSellerID.publicKey;
    jollar = sendTransactionReq.jollar;
    rispostaOk.messaggio = "ok";
    rispostaOk.transaction << sendTransactionReq;
    rispostaNo.messaggio = "errore";
    rispostaNo.transaction << sendTransactionReq;
    println@Console("Ho ricevuto la seguente transazione = NodeBuyer: " + nodeBuyer + " NodeSeller: " + nodeSeller + " Jollar: " + jollar)();
    //CONTROLLO CHE LA CHIAVE DEL CLIENT 1 NON SIA VUOTA
    if(global.pkClient1 != " "){
      //CONTROLLO SE IL CLIENT1 E' IL COMPRATORE
      if(global.pkClient1 == nodeBuyer){
        println@Console("Sto inviando la transazione ricevuta al client 1")();
        scope ( scopeName )
        {
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA OFFLINE
          install( IOException => {
            println@Console("Il client 1 e' offline, transazione cancellata in quanto client compratore")();
              if(nodeSeller == global.pkClient2){
                ackSendTransaction@client2( rispostaNo )
              }else if(nodeSeller == global.pkClient3){
                ackSendTransaction@client3( rispostaNo )
              }else{
                ackSendTransaction@client4( rispostaNo )
              }
          });
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA ONLINE
          //VISTO CHE LA TRANSAZIONE E' AVVENNUTA CORRETTAMENTE, INVIO LA TRANSAZIONE A TUTTI I CLIENT
          if(nodeSeller == global.pkClient2){
            //SE IL CLIENT VENDITORE E' OFFLINE ANNULLA LA TRANSIZIONE IN QUANTO NON POSSO AGGIORNARE IL SUO SALDO
            install( IOException => {
              println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client1( sendTransactionReq );
            sendTransaction@client2( sendTransactionReq );
            ackSendTransaction@client2( rispostaOk );
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else if(nodeSeller == global.pkClient3){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client1( sendTransactionReq );
            sendTransaction@client3( sendTransactionReq );
            ackSendTransaction@client3( rispostaOk );
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else{
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client1( sendTransactionReq );
            sendTransaction@client4( sendTransactionReq );
            ackSendTransaction@client4( rispostaOk );
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient3 != " "){
                  install( IOException => {
                    println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client3( sendTransactionReq )
                }else{
                  println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            }
          }
        }
      }
    }else{
      println@Console("Il client 1 e' offline, non gli ho inviato la transazione")()
    };
    //CONTROLLO CHE LA CHIAVE DEL CLIENT 2 NON SIA VUOTA
    if(global.pkClient2 != " "){
      //CONTROLLO SE IL CLIENT 2 E' IL COMPRATORE
      if(global.pkClient2 == nodeBuyer){
        println@Console("Sto inviando la transazione ricevuta al client 2")();
        scope ( scopeName )
        {
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA OFFLINE
          install( IOException => {
            println@Console("Il client 2 e' offline, transazione cancellata in quanto client compratore")();
              if(nodeSeller == global.pkClient1){
                ackSendTransaction@client1( rispostaNo )
              }else if(nodeSeller == global.pkClient3){
                ackSendTransaction@client3( rispostaNo )
              }else{
                ackSendTransaction@client4( rispostaNo )
              }
          });
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA ONLINE
          //VISTO CHE LA TRANSAZIONE E' AVVENNUTA CORRETTAMENTE, INVIO LA TRANSAZIONE A TUTTI I CLIENT
          if(nodeSeller == global.pkClient1){
            install( IOException => {
              println@Console("Il client 1 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client2( sendTransactionReq );
            sendTransaction@client1( sendTransactionReq );
            ackSendTransaction@client1( rispostaOk );
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else if(nodeSeller == global.pkClient3){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client2( sendTransactionReq );
            sendTransaction@client3( sendTransactionReq );
            ackSendTransaction@client3( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else{
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client2( sendTransactionReq );
            sendTransaction@client4( sendTransactionReq );
            ackSendTransaction@client4( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient3 != " "){
                  install( IOException => {
                    println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client3( sendTransactionReq )
                }else{
                  println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            }
          }
        }
      }
    }else{
      println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
    };
    //CONTROLLO CHE LA CHIAVE DEL CLIENT 3 NON SIA VUOTA
    if(global.pkClient3 != " "){
      //CONTROLLO SE IL CLIENT 3 E' IL COMPRATORE
      if(global.pkClient3 == nodeBuyer){
        println@Console("Sto inviando la transazione ricevuta al client 3")();
        scope ( scopeName )
        {
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA OFFLINE
          install( IOException => {
            println@Console("Il client 3 e' offline, transazione cancellata in quanto client compratore")();
              if(nodeSeller == global.pkClient1){
                ackSendTransaction@client1( rispostaNo )
              }else if(nodeSeller == global.pkClient2){
                ackSendTransaction@client2( rispostaNo )
              }else{
                ackSendTransaction@client4( rispostaNo )
              }
          });
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA ONLINE
          //VISTO CHE LA TRANSAZIONE E' AVVENNUTA CORRETTAMENTE, INVIO LA TRANSAZIONE A TUTTI I CLIENT
          if(nodeSeller == global.pkClient1){
            install( IOException => {
              println@Console("Il client 1 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client3( sendTransactionReq );
            sendTransaction@client1( sendTransactionReq );
            ackSendTransaction@client1( rispostaOk );
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else if(nodeSeller == global.pkClient2){
            install( IOException => {
              println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client3( sendTransactionReq );
            sendTransaction@client2( sendTransactionReq );
            ackSendTransaction@client2( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient4 != " "){
                  install( IOException => {
                    println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client4( sendTransactionReq )
                }else{
                  println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient4 != " "){
              install( IOException => {
                println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client4( sendTransactionReq )
            }else{
              println@Console("il client 4 e' offline, non gli ho inviato la transazione")()
            }
          }else{
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client3( sendTransactionReq );
            sendTransaction@client4( sendTransactionReq );
            ackSendTransaction@client4( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient2 != " "){
                  install( IOException => {
                    println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client2( sendTransactionReq )
                }else{
                  println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            }
          }
        }
      }
    }else{
      println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
    };
    //CONTROLLO CHE LA CHIAVE DEL CLIENT 4 NON SIA VUOTA
    if(global.pkClient4 != " "){
      //CONTROLLO SE IL CLIENT 4 E' IL COMPRATORE
      if(global.pkClient4 == nodeBuyer){
        println@Console("Sto inviando la transazione ricevuta al client 4")();
        scope ( scopeName )
        {
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA OFFLINE
          install( IOException => {
            println@Console("Il client 4 e' offline, transazione cancellata in quanto client compratore")();
              if(nodeSeller == global.pkClient1){
                ackSendTransaction@client1( rispostaNo )
              }else if(nodeSeller == global.pkClient3){
                ackSendTransaction@client3( rispostaNo )
              }else{
                ackSendTransaction@client2( rispostaNo )
              }
          });
          //INDICO LE AZIONI DA FARE IN CASO IL CLIENT COMPRATORE SIA ONLINE
          //VISTO CHE LA TRANSAZIONE E' AVVENNUTA CORRETTAMENTE, INVIO LA TRANSAZIONE A TUTTI I CLIENT
          if(nodeSeller == global.pkClient1){
            install( IOException => {
              println@Console("Il client 1 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client4( sendTransactionReq );
            sendTransaction@client1( sendTransactionReq );
            ackSendTransaction@client1( rispostaOk );
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient2 != " "){
                  install( IOException => {
                    println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client2( sendTransactionReq )
                }else{
                  println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            }
          }else if(nodeSeller == global.pkClient3){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client4( sendTransactionReq );
            sendTransaction@client3( sendTransactionReq );
            ackSendTransaction@client3( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient2 != " "){
                  install( IOException => {
                    println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client2( sendTransactionReq )
                }else{
                  println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient2 != " "){
              install( IOException => {
                println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client2( sendTransactionReq )
            }else{
              println@Console("il client 2 e' offline, non gli ho inviato la transazione")()
            }
          }else{
            install( IOException => {
              println@Console("Il client 2 e' offline, non gli ho inviato la transazione")()
            });
            sendTransaction@client4( sendTransactionReq );
            sendTransaction@client2( sendTransactionReq );
            ackSendTransaction@client2( rispostaOk );
            if(global.pkClient1 != " "){
              install( IOException => {
                println@Console("Il client 1 e' offline, non gli ho inviato la transazione")();
                //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
                if(global.pkClient3 != " "){
                  install( IOException => {
                    println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
                  });
                  sendTransaction@client3( sendTransactionReq )
                }else{
                  println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
                }
              });
              sendTransaction@client1( sendTransactionReq )
            }else{
              println@Console("il client 1 e' offline, non gli ho inviato la transazione")()
            };
            if(global.pkClient3 != " "){
              install( IOException => {
                println@Console("Il client 3 e' offline, non gli ho inviato la transazione")()
              });
              sendTransaction@client3( sendTransactionReq )
            }else{
              println@Console("il client 3 e' offline, non gli ho inviato la transazione")()
            }
          }
        }
      }
    }else{
      println@Console("Il client 4 e' offline, non gli ho inviato la transazione")()
    }
  }

  [sendBlock ( block )]{
    nodoCostruttore = block.clientS.publicKey;
    if(nodoCostruttore == global.pkClient1){
      if(global.pkClient2 != " "){
        install( IOException => {
          println@Console("Il client 2 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient3 != " "){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato il blocco")();
              if(global.pkClient4 != " "){
                install( IOException => {
                  println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
                });
                sendBlock@client4( block )
              }
            });
            sendBlock@client3( block )
          };
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client2( block )
      };
      if(global.pkClient3 != " "){
        install( IOException => {
          println@Console("Il client 3 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client3( block )
      };
      if(global.pkClient4 != " "){
        install( IOException => {
          println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
        });
        sendBlock@client4( block )
      }
    }else if(nodoCostruttore == global.pkClient2){
      if(global.pkClient1 != " "){
        install( IOException => {
          println@Console("Il client 1 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient3 != " "){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato il blocco")();
              //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
              if(global.pkClient4 != " "){
                install( IOException => {
                  println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
                });
                sendBlock@client4( block )
              }
            });
            sendBlock@client3( block )
          };
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client1( block )
      };
      if(global.pkClient3 != " "){
        install( IOException => {
          println@Console("Il client 3 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client3( block )
      };
      if(global.pkClient4 != " "){
        install( IOException => {
          println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
        });
        sendBlock@client4( block )
      }
    }else if(nodoCostruttore == global.pkClient3){
      if(global.pkClient1 != " "){
        install( IOException => {
          println@Console("Il client 1 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient2 != " "){
            install( IOException => {
              println@Console("Il client 2 e' offline, non gli ho inviato il blocco")();
              //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
              if(global.pkClient4 != " "){
                install( IOException => {
                  println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
                });
                sendBlock@client4( block )
              }
            });
            sendBlock@client2( block )
          };
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client1( block )
      };
      if(global.pkClient2 != " "){
        install( IOException => {
          println@Console("Il client 2 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient4 != " "){
            install( IOException => {
              println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client4( block )
          }
        });
        sendBlock@client2( block )
      };
      if(global.pkClient4 != " "){
        install( IOException => {
          println@Console("Il client 4 e' offline, non gli ho inviato il blocco")()
        });
        sendBlock@client4( block )
      }
    }else{
      if(global.pkClient1 != " "){
        install( IOException => {
          println@Console("Il client 1 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient2 != " "){
            install( IOException => {
              println@Console("Il client 2 e' offline, non gli ho inviato il blocco")();
              //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
              if(global.pkClient3 != " "){
                install( IOException => {
                  println@Console("Il client 3 e' offline, non gli ho inviato il blocco")()
                });
                sendBlock@client3( block )
              }
            });
            sendBlock@client2( block )
          };
          if(global.pkClient3 != " "){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client3( block )
          }
        });
        sendBlock@client1( block )
      };
      if(global.pkClient2 != " "){
        install( IOException => {
          println@Console("Il client 2 e' offline, non gli ho inviato il blocco")();
          //DOPO AVER LANCIATO L'ECCEZIONE CONTROLLO IL CLIENT MANCANTE
          if(global.pkClient3 != " "){
            install( IOException => {
              println@Console("Il client 3 e' offline, non gli ho inviato il blocco")()
            });
            sendBlock@client3( block )
          }
        });
        sendBlock@client2( block )
      };
      if(global.pkClient3 != " "){
        install( IOException => {
          println@Console("Il client 3 e' offline, non gli ho inviato il blocco")()
        });
        sendBlock@client3( block )
      }
    }
  }

  [ackSendBlock( ack )]{
    install( IOException => {
      println@Console( "Errore ackSendBlock: il client "+nodoCostruttore+" è offline." )()
    });
    nodoCostruttore = ack.block.clientS.publicKey;
    if(nodoCostruttore == global.pkClient1){
      ackSendBlock@client1( ack )
    }else if(nodoCostruttore == global.pkClient2){
      ackSendBlock@client2( ack )
    }else if(nodoCostruttore == global.pkClient3){
      ackSendBlock@client3( ack )
    }else{
      ackSendBlock@client4( ack )
    }
  }

  [sendSaldo(mysaldo)]{
    posizione = mysaldo.client - 1;
    global.array.arraySaldi[posizione] = mysaldo.saldo;
    install( IOException => {
      println@Console("Errore "+IOException)()
    });
    //salvo i saldi dei client sul file.
    WriteFileRequest.filename = "cash.json";
    testo << global.array;
    WriteFileRequest.content<<testo;
    WriteFileRequest.format = "json";
    writeFile@File(WriteFileRequest)()
  }

  [write(block)]{
    if(block.clientS.publicKey == global.pkClient1){
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client2 offline, non gli ho mandato il write!" )()
        });
        write@client2(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client3 offline, non gli ho mandato il write!" )()
        });
        write@client3(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client4 offline, non gli ho mandato il write!" )()
        });
        write@client4(block)
      }
    }else if(block.clientS.publicKey == global.pkClient2){
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client1 offline, non gli ho mandato il write!" )()
        });
        write@client1(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client3 offline, non gli ho mandato il write!" )()
        });
        write@client3(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client4 offline, non gli ho mandato il write!" )()
        });
        write@client4(block)
      }
    }else if(block.clientS.publicKey == global.pkClient3){
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client2 offline, non gli ho mandato il write!" )()
        });
        write@client2(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client1 offline, non gli ho mandato il write!" )()
        });
        write@client1(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client4 offline, non gli ho mandato il write!" )()
        });
        write@client4(block)
      }
    }else{
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client2 offline, non gli ho mandato il write!" )()
        });
        write@client2(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client3 offline, non gli ho mandato il write!" )()
        });
        write@client3(block)
      };
      scope( scopeName )
      {
        install(IOException => {
          println@Console( "Client1 offline, non gli ho mandato il write!" )()
        });
        write@client1(block)
      }
    }
  }

  [sincro()(response){
    scope( scopeName ){
      install( IOException => println@Console( "BlockChain 1 non presente client offline" )() );
      getBlockchain@client1()(blockchain1);
      listaBlockchain[0] << blockchain1
    };
    scope( scopeName ){
      install( IOException => println@Console( "BlockChain 2 non presente client offline" )() );
      getBlockchain@client2()(blockchain2);
      listaBlockchain[1] << blockchain2
    };
    scope( scopeName ){
      install( IOException => println@Console( "BlockChain 3 non presente client offline" )() );
      getBlockchain@client3()(blockchain3);
      listaBlockchain[2] << blockchain3
    };
    scope( scopeName ){
      install( IOException =>  println@Console( "BlockChain 4 non presente client offline" )());
      getBlockchain@client4()(blockchain4);
      listaBlockchain[3] << blockchain4
    };
    array.listaBlockchain << listaBlockchain;
    response << array
  }]
}
