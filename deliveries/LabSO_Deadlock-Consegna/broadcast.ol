include "MainInterface.iol"
include "console.iol"
include "file.iol"
include "String_utils.iol"

outputPort ConnNodo {
	Protocol: sodep
	Interfaces: BroadcastInterface, BlockchainInterface
}

inputPort Broadcast {
	Location: "socket://localhost:8000"
	Protocol: sodep 
	Interfaces: BroadcastInterface, BlockchainInterface, NetInterface
}

outputPort Broadcast_Network {  
  Location:"socket://localhost:9000"
  Protocol: sodep
  Interfaces: NetInterface, DateInterface
}

outputPort Blockchain {
	Interfaces: GenesisInterface
}

embedded {
  Jolie: "Blockchain.ol" in Blockchain
}

execution{ concurrent }


init {

  global.path = "." ; //"inserisci percorso"; 
	global.filename = global.path + "/nodesLocations.txt";
  
  //controlla se il file nodesLocations.txt esiste
	exists@File( global.filename )( esiste );
	if (esiste) {
    //se esiste lo elimina
		delete@File(global.filename)(cancellato);
		if (cancellato == true) {
			println@Console( "file eliminato" )()
		}
	};
	global.nNodi = 0 
}

main{

	[sonoNato(location)(res){
      //controlla se esiste il file nodesLocations.txt
			exists@File( global.filename )( esiste );
			if ( esiste ) {
        //se esiste lo aggiorna
				println@Console( "esiste" )();
        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() );
          read.filename = global.filename;
          readFile@File( read )( display )
        };

        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() );
          write.filename = global.filename;
          rigaSucc = "-" + location;
          write.content = display + rigaSucc;
          writeFile@File( write )( void )
        };

        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() ); 
          read.filename = global.filename;
          readFile@File( read )( display );
          println@Console( "Contenuto aggiornato: " + display )();
          x = 0
        }
			}
			else if ( !esiste ) {
        //se non esiste lo crea
				println@Console( "non esiste" )();
		  
        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() );
          write.filename = global.filename;
          write.content = location;
          writeFile@File( write )( void );
          println@Console( "Nuovo file creato " + global.filename )()
        };

        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() );
          read.filename = global.filename;
          readFile@File( read )( display );
          println@Console( "Contenuto: " + display )();
          x = 6
        }
			};
		 	
			res.jollarGenesis = x;
			res.nato = true 
	}]
    
  

	[invioTrans(transRequest1)] {
  		transactionBr.nodeSeller.publicKey = transRequest1.nodeSeller.publicKey;
  		transactionBr.nodeSeller.privateKey = transRequest1.nodeSeller.privateKey;
  		transactionBr.nodeSeller.location = transRequest1.nodeSeller.location;
  		transactionBr.nodeBuyer.publicKey = transRequest1.nodeBuyer.publicKey;
  		transactionBr.jollar = transRequest1.jollar;
  		transactionBr.timestamp = transRequest1.timestamp;
      transactionBr.date = transRequest1.date;
      global.down = false;
  		println@Console("Jollar: " + transactionBr.jollar)();
    	println@Console("NodoDestinatario: " + transactionBr.nodeBuyer.publicKey)();
    	println@Console("NodoMittente: " + transactionBr.nodeSeller.publicKey)();
      //controlla che il nodo destinatario sia ancora attivo
      scope( nodoAttivo ) {
        install( IOException => {println@Console( "Nodo con location socket://localhost:" + transactionBr.nodeBuyer.publicKey  + " down.")() | global.down = true } );
        ConnNodo.location = "socket://localhost:" + transactionBr.nodeBuyer.publicKey;
        checkNodoAttivo@ConnNodo()
      };
      transactionBr.nodoDown = global.down;
      //se non è attivo non invia la transazione
      if (global.down == true) {
        println@Console( "impossibile eseguire la transazione. Nodo destinatario down." )()
      }
      //se è attivo invia la transazione ai nodi
      else {
        //legge il file con le location registrate
        scope( file ) {
          install( FileNotFound => println@Console( "File non trovato" )() );
          read.filename = global.path + "/nodesLocations.txt";
          readFile@File( read )( display );
          display.regex = "-";
          split@StringUtils(display)(riga);
          n = #riga.result;
          //pero ogni location nel file invia la transazione 
          for (i=0, i<n, i++) {
            scope( i ) {
              install( IOException => println@Console( "Nodo con location " + riga.result[i] + " down.")() );
              ConnNodo.location = riga.result[i];
              println@Console( "invio a location: " + ConnNodo.location )();
              broadcastTrans@ConnNodo(transactionBr)
            }
          }
        }
      }
  }
  	
   
    //riceve richiesta dal nodo di farsi inviare le lunghezze delle blockchain degli altri nodi della rete
  	[checkBlChCorretta(nodoDaControllare)] { 
  		numeroRichieste = 0;
      scope( file ) {
        //legge il file con le location registrate
        install( FileNotFound => println@Console( "File non trovato" )() );
          read.filename = global.path + "/nodesLocations.txt";
          readFile@File( read )( display );
          display.regex = "-";
          split@StringUtils(display)(riga);
          n = #riga.result;
          println@Console( "numero di location nel file: " + n)();
          //per ogni location del file invia la richiesta 
          for (i=0, i<n, i++) {
            scope( j ) {
              install( IOException => println@Console( "Nodo con location " + riga.result[i] + " down.")() );
              //non invia la richiesta al nodo che l'ha inviata
              if ( riga.result[i] != nodoDaControllare.location ) {
                ConnNodo.location = riga.result[i];
                println@Console( "invio a location: " + ConnNodo.location )();
                richiestaBlockchainNodi@ConnNodo()(resBlockchainNodi);
                //invia le info ricevute al nodo che le ha richieste
                nodoOk.location = resBlockchainNodi.location;
                nodoOk.numeroBlocchi = resBlockchainNodi.numeroBlocchi;
                ConnNodo.location = nodoDaControllare.location;
                println@Console( "ritorna risposta a: " + ConnNodo.location)();
                inviaNumBlocchi@ConnNodo(nodoOk)
              }
            }
          } 
      }   		
    }

    //riceve dal network la richiesta di chiedere la lunghezza delle blockchain di tutti i nodi della rete
    [richiestaInfoBroadcast(richiestaBlocchi)] {
      scope( file ) {
          //legge il file con le location registrate
          install( FileNotFound => println@Console( "File non trovato" )() );
          read.filename = global.path + "/nodesLocations.txt";
          readFile@File( read )( display );
          display.regex = "-";
          split@StringUtils(display)(riga);
          n = #riga.result;
          //per ogni location del file invia la richiesta 
          for (i=0, i<n, i++) {
            scope( i ) {
              install( IOException => println@Console( "Nodo con location " + riga.result[i] + " down.")() );
              ConnNodo.location = riga.result[i];
              richiestaInfoNodo@ConnNodo()
            }
          }
      }
    }


}

