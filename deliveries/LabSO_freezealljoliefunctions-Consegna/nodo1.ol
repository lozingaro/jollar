include "console.iol"
include "nodo_interface.iol"
include "message_digest.iol"
include "math.iol"

// Porta d'ascolto per il nodo1

inputPort In1 {
    Location: "socket://localhost:8000"
    Protocol: sodep
	  Interfaces: Nodo_interface
}

// Porta di output per contattare gli altri nodi (cambio di location con binding dinamico)

outputPort Out {
    Protocol: sodep
    Interfaces: Nodo_interface
}

// Porta di output per contattare timestamp server

outputPort TimeOut {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: Nodo_interface
}

// Funzione che crea blocco generatore - difficoltà fissa a 4

define creaBloccoGeneratore
{
    blocco.previousBlockHash = "nessuno";
    blocco.difficulty = 4;
    blocco.nodoGeneratore = myInputPort;
    blocco.transaction.hash = "primo";
    blocco.transaction.jollar = 0;
    blocco.transaction.nodeBuyer = "NA";
    blocco.transaction.nodeSeller = "NA";

    getTimestamp@TimeOut()(timestamp);
    blocco.transaction.timestamp = timestamp;
    blocco.timestamp = timestamp;

    blockchain.block << blocco;
    println@Console("Creata blockchain e blocco origine")()
}

// Funzione per il download della blockchain

define getBlockchain
{
  max = 0;

  // Se sono l'unico nodo

  if (#listaPorte.porta == 1) {
    println@Console("Sono il primo nodo, genero blockchain")();
    creaBloccoGeneratore

  // Altrimenti
  } else {
    for (j = 0, j < #listaPorte.porta, j++)
      {
          if (listaPorte.porta[j] != myInputPort)
          {
            Out.location = listaPorte.porta[j];
            getBlockchain@Out()(blockchain);
            blockchainRetrieved[j] << blockchain
          }
      };

  // Confronto le blockchain ricevute dagli altri nodi e prendo quella di lunghezza maggiore 

      for (j = 0, j < #listaPorte.porta, j++)
      {
          if (#blockchainRetrieved[j].block > max) {
            max = #blockchainRetrieved[j].block;
            blockchain << blockchainRetrieved[j]
          }
      };
      println@Console("Blockchain scaricata!")()
    }
}

// funzione per l'aggiunta di un blocco

define aggiungiBlocco
{
    blockchain.block[#blockchain.block] << blocco;
    println@Console("Blocco aggiunto!")()
}

// funzione per la verifica della proof of work - prima vedo se la lunghezza frazionaria è maggiore o uguale alla difficoltà, 
// poi faccio test di fermat per ogni valore della catena

define verificaPow
{
    println@Console("Verifico la proof of work...")();
    length = #blocco.powchain;

    // se la catena è (p1, p2, ... , pk-1), pk è l'elemento successivo alla catena
    
    pkpotenza.base = double(2);
    pkpotenza.exponent = double(length);
    pow@Math(pkpotenza)(pkrisultato);
    pk = pkrisultato*blocco.powchain[0] + pkrisultato - 1;
    println@Console("Il numero pk e' " + pk)();

    // r è il resto di fermat del numero pk

    potenza1.base = 2;
    potenza1.exponent = pk - 1;
    pow@Math(potenza1)(potenza1risultato);
    r = potenza1risultato%pk;
    println@Console("Il numero r e' " + r)();

    // k è la lunghezza della catena
    // lunghezza frazionaria d = k + (pk-r)/k

    d = double(length + (pk-r)/pk);
    println@Console("La fractional length e' " + d)();
    if (d >= blocco.difficulty) 
    {
        println@Console("... ed e' superiore o uguale alla difficolta'")();

        // test di fermat per ogni elemento della catena

        for (j = 0, j < length, j++)
        {
            potenza2.base = 2;
            potenza2.exponent = blocco.powchain[j] - 1;
            pow@Math(potenza2)(ptrisultato);
            if (blocco.powchain[j] == 2)
            {
                conferma[j] = true
            } else if (ptrisultato%blocco.powchain[j] == 1) {
                conferma[j] = true
            } else {
                conferma[j] = false
            }
        };

        confermaInterna = true;

        for (j = 0, j < #blocco.powchain, j++)
        {
            if (conferma[j] == false) {
                confermaInterna = false;
                index = j + 1
            }
        }
    } else {
        println@Console("... ed e' inferiore alla difficolta'")();
        confermaInterna = false
    }
}

// nell'init notifico il timestamp della mia connessione, scarico la lista degli altri nodi collegati e scarico la blockchain

init
{
    notifyServer@TimeOut()(response);

    // il server mi risponde con la mia location, che fungerà da chiave pubblica 

    myInputPort = response;
    println@Console("Sono il nodo " + myInputPort)();
    getLocations@TimeOut()(listaPorte);

    synchronized( id1 ){
          global.listaPorte << listaPorte
    };
    println@Console("Ho preso la lista delle porte")();
    getBlockchain
}

// metodo per generare proof of work - catena di Cunningham di primo tipo


define proofOfWork
{

    println@Console("Inizio proof of work")();

    length = blockchain.block[#blockchain.block - 1].difficulty;
   
    for (j = 1, j < length, j++)
    { 
        esp.base = double(2);
        esp.exponent = double(j);
        pow@Math(esp)(potenza);
    
        powchain[j] = potenza*powchain[0] + potenza - 1
    };

    println@Console("Catena generata")();

    blocco.powchain << powchain;

    // verifico la mia stessa catena
    
    verificaPow;

    // se la verifica non va bene, rifaccio proof of work, partendo dall'elemento successivo della catena


    if (confermaInterna == false) {
        println@Console("Proof of work errata, non tutti i numeri sono primi")();
        esp.base = double(2);
        esp.exponent = double(index);
        pow@Math(esp)(potenza);
    
        powchain[0] = potenza*powchain[0] + potenza - 1;
        proofOfWork
    }
}

// metodo per creare blocco, data una transazione

define creaBlocco
{
    println@Console("Creo blocco contenente transazione")();
    blocco.previousBlockHash = blockchain.block[#blockchain.block - 1].transaction.hash;
    blocco.difficulty = blockchain.block[#blockchain.block - 1].difficulty;

    // il campo nodoGeneratore mi servirà per sapere a chi assegnare il reward

    blocco.nodoGeneratore = myInputPort;
    
    blocco.transaction << trans;
    
    // proof of work, con p0 = 2

    powchain[0] = double(2);
    proofOfWork;

    println@Console("Proof of work terminata")();

    

    for (j = 0, j < length, j++)
    { 
        println@Console("Catena, numero: " + j)();
        println@Console(blocco.powchain[j])()
    };

    getTimestamp@TimeOut()(timestamp);
    blocco.timestamp = timestamp
}

// metodo per verificare che la transazione non sia stata già spesa - prima controllo che il timestamp sia successivo a quello dell'ultimo blocco aggiunto, 
// poi controllo che l'hash della transazione non sia già presente

define verificaBlocco
{

    confermaVerificaBlocco = true;

    if (blocco.timestamp > blockchain.block[#blockchain.block -1].timestamp)
    {
        for (j = 0, j < #blockchain.block, j++)
        {
            if(blocco.transaction.hash == blockchain.block[j].transaction.hash)
            {
                println@Console("Trovato un blocco nella blockchain con hash uguale!")();
                confermaVerificaBlocco = false
            }
        }
    } else {
        println@Console("Il blocco ha un timestamp inferiore all'ultimo timestamp!")();
        confermaVerificaBlocco = false
    }
}

// main

main
{

    // aggiornaLocations() e getBlockchain()() saranno chiamati la prima volta dal nodo2

    {{
        aggiornaLocations();
        
        println@Console("Sembra che un altro nodo si sia collegato, aggiorno lista nodi")();
        getLocations@TimeOut()(listaPorte);
        println@Console("Lista nodi aggiornata")();

        synchronized( id1 ){
              global.listaPorte << listaPorte
        };
            
        println@Console("La dimensione della lista nodi e' " + #listaPorte.porta)()
    }
    |
    [
        getBlockchain()(response) {
            response << blockchain
        }
    ]}
    ;

    // poi dal nodo 3

    {{
        aggiornaLocations();
        
        println@Console("Sembra che un altro nodo si sia collegato, aggiorno lista nodi")();
        getLocations@TimeOut()(listaPorte);
        println@Console("Lista nodi aggiornata")();

        synchronized( id1 ){
            global.listaPorte << listaPorte
        };
            
        println@Console("La dimensione della lista nodi e' " + #listaPorte.porta)()
    }
    |
    [
        getBlockchain()(response) {
            response << blockchain
        }
    ]}
    ;

    // poi dal nodo4

    {{
        aggiornaLocations();
        
        println@Console("Sembra che un altro nodo si sia collegato, aggiorno lista nodi")();
        getLocations@TimeOut()(listaPorte);
        println@Console("Lista nodi aggiornata")();

        synchronized( id1 ){
            global.listaPorte << listaPorte
        };
            
        println@Console("La dimensione della lista nodi e' " + #listaPorte.porta)()
    }
    |
    [
        getBlockchain()(response) {
            response << blockchain
        }
    ]}
    ;

    // genero la prima transazione - mando 1 jollar al nodo 2

  { {
        println@Console("")();
        println@Console("Genero transazione: invio di 1 jollar al nodo socket://localhost:8001")();
        trans.nodeSeller = "socket://localhost:8001";
        trans.nodeBuyer = "socket://localhost:8000";
        trans.jollar = 1;
        getTimestamp@TimeOut()(timestamp);
        trans.timestamp = timestamp;

        // la private key è hardcoded

        myPrivateKey = "matteodeggi";

        // genero hash
      
        md5@MessageDigest(trans.timestamp + trans.nodeBuyer + trans.nodeSeller + trans.jollar + myPrivateKey)(hashedTransaction);
        trans.hash = hashedTransaction;

        // mando la transazione a tutti i nodi in lista, escluso me

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaTransaction@Out(trans);
                println@Console("Ho mandato la transazione al nodo " + Out.location)()
            }
        }
    }
    |

    // in parallelo aspetto di ricevere il blocco da 3 nodi

    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    }
    ;

    // il blocco è stato aggiunto, rifaccio lo stesso procedimento per transazione 2 - mando 2 Jollar al nodo 3

    { {
        prendiSemaforo@TimeOut(2)();
        prendiSemaforo@TimeOut(2)();
        prendiSemaforo@TimeOut(2)();
        registerForInput@Console()();
        println@Console("")();
        println@Console("Rispondi per procedere con la prossima transazione")();
        println@Console("")();
        in(input);
        println@Console("Genero transazione: invio di 2 jollar al nodo 8002")();
        trans.nodeSeller = "socket://localhost:8002";
        trans.nodeBuyer = "socket://localhost:8000";
        trans.jollar = 2;
        getTimestamp@TimeOut()(timestamp);
        trans.timestamp = timestamp;
        myPrivateKey = "matteodeggi";

      
        md5@MessageDigest(trans.timestamp + trans.nodeBuyer + trans.nodeSeller + trans.jollar + myPrivateKey)(hashedTransaction);
        trans.hash = hashedTransaction;

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaTransaction@Out(trans);
                println@Console("Ho mandato la transazione al nodo " + Out.location)()
            }
        }
    }
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    }
    ;

    // stessa cosa per transazione3 - mando 3 jollar al nodo 4

    { {
        prendiSemaforo@TimeOut(2)();
        prendiSemaforo@TimeOut(2)();
        prendiSemaforo@TimeOut(2)();
        println@Console("")();
        println@Console("Rispondi per procedere con la prossima transazione")();
        println@Console("")();
        in(input);
        println@Console("Genero transazione: invio di 3 jollar al nodo 8003")();
        trans.nodeSeller = "socket://localhost:8003";
        trans.nodeBuyer = "socket://localhost:8000";
        trans.jollar = 3;
        getTimestamp@TimeOut()(timestamp);
        trans.timestamp = timestamp;
        myPrivateKey = "matteodeggi";

      
        md5@MessageDigest(trans.timestamp + trans.nodeBuyer + trans.nodeSeller + trans.jollar + myPrivateKey)(hashedTransaction);
        trans.hash = hashedTransaction;

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaTransaction@Out(trans);
                println@Console("Ho mandato la transazione al nodo " + Out.location)()
            }
        }
    }
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    |
    [
        mandaBlocco(blocco)(confermaBlocco) 
        {
            println@Console("Blocco ricevuto")();

            verificaBlocco;

            if (confermaVerificaBlocco == true)
            {
                println@Console("Ho verificato l'integrità del blocco")();
                verificaPow;

                if (confermaInterna == true) {
                    println@Console("Blocco validato!")()
                };
                confermaBlocco = confermaInterna;

                if (confermaInterna == true) {
                    aggiungiBlocco
                }
            } else {
                confermaBlocco = false
            }
        }
    ]
    };

    // so che il network visualizer mi chiederà la blockchain

    [
        getBlockchain()(response) {
            response << blockchain
        }
    ]
    

}