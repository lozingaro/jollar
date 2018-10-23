include "console.iol"
include "nodo_interface.iol"
include "message_digest.iol"
include "math.iol"

// Porta d'ascolto per il nodo4

inputPort In {
    Location: "socket://localhost:8003"
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
  if (#listaPorte.porta == 1) {
    println@Console("Sono il primo nodo, genero blockchain")();
    creaBloccoGeneratore
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
    
    pkpotenza.base = double(2);
    pkpotenza.exponent = double(length);
    pow@Math(pkpotenza)(pkrisultato);
    pk = pkrisultato*blocco.powchain[0] + pkrisultato - 1;
    println@Console("Il numero pk e' " + pk)();

    potenza1.base = 2;
    potenza1.exponent = pk - 1;
    pow@Math(potenza1)(potenza1risultato);
    r = potenza1risultato%pk;
    println@Console("Il numero r e' " + r)();

    d = double(length + (pk-r)/pk);
    println@Console("La fractional length e' " + d)();
    if (d >= blocco.difficulty) 
    {
        println@Console("... ed e' superiore o uguale alla difficolta'")();
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
    
    verificaPow;


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

    blocco.nodoGeneratore = myInputPort;
    
    blocco.transaction << trans;
    
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

main
{
    // ricevo la prima transazione dal nodo1, creo il blocco e lo invio a tutti gli altri nodi (escluso me)
    // aspetto conferma di verifica del blocco, se ricevo più del 30% di conferme lo aggiungo alla blockchain

    {{
        mandaTransaction(trans);
        
        println@Console("Ricevuta transazione")();
        creaBlocco;
        println@Console("Blocco creato, procedo all'invio")();

        synchronized( id1 ){
            listaPorte << global.listaPorte
        };
        println@Console("Dimensione lista porte e' " + #listaPorte.porta)();

        prendiSemaforo@TimeOut(1)();
        prendiSemaforo@TimeOut(2)();
        

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaBlocco@Out(blocco)(confermaBlocco);
                confermaBloccoInterna[j] = confermaBlocco
            }
        };


        println@Console("Controllo in quanti me l'hanno validato")();
        countConferme = 0;

        for (j = 0, j < #confermaBloccoInterna, j++)
        {
            if (confermaBloccoInterna[j] == true) {
            countConferme++
            }
        };


        nodiEsterni = #listaPorte.porta - 1;

        if (countConferme > (#confermaBloccoInterna/3)) {
            println@Console(countConferme + " nodi su " + nodiEsterni + " mi hanno validato il blocco")();
            println@Console("Aggiungo il blocco alla blockchain")();
            aggiungiBlocco
        } else {
            println@Console("Me l'hanno rifiutato!")()
        };


        lasciaSemaforo@TimeOut(1)();
        lasciaSemaforo@TimeOut(2)()
    }
    |

    // aspetto ricezione blocco da due nodi

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
    ]}
    ;

    // rifaccio lo stesso procedimento per la transazione2

    {{
        mandaTransaction(trans);
        
        println@Console("Ricevuta transazione")();
        creaBlocco;
        println@Console("Blocco creato, procedo all'invio")();

        synchronized( id1 ){
            listaPorte << global.listaPorte
        };
        println@Console("Dimensione lista porte e' " + #listaPorte.porta)();

        prendiSemaforo@TimeOut(1)();
        

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaBlocco@Out(blocco)(confermaBlocco);
                confermaBloccoInterna[j] = confermaBlocco
            }
        };


        println@Console("Controllo in quanti me l'hanno validato")();
        countConferme = 0;

        for (j = 0, j < #confermaBloccoInterna, j++)
        {
            if (confermaBloccoInterna[j] == true) {
            countConferme++
            }
        };


        nodiEsterni = #listaPorte.porta - 1;

        if (countConferme > (#confermaBloccoInterna/3)) {
            println@Console(countConferme + " nodi su " + nodiEsterni + " mi hanno validato il blocco")();
            println@Console("Aggiungo il blocco alla blockchain")();
            aggiungiBlocco
        } else {
            println@Console("Me l'hanno rifiutato!")()
        };


        lasciaSemaforo@TimeOut(1)();
        lasciaSemaforo@TimeOut(2)()
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
    ]}
    ;

    // e per la transazione3

    {{
        mandaTransaction(trans);
        
        println@Console("Ricevuta transazione")();
        creaBlocco;
        println@Console("Blocco creato, procedo all'invio")();

        synchronized( id1 ){
            listaPorte << global.listaPorte
        };
        println@Console("Dimensione lista porte e' " + #listaPorte.porta)();

        prendiSemaforo@TimeOut(1)();
        

        for (j = 0, j < #listaPorte.porta, j++)
        {
            if (listaPorte.porta[j] != myInputPort)
            {
                Out.location = listaPorte.porta[j];
                mandaBlocco@Out(blocco)(confermaBlocco);
                confermaBloccoInterna[j] = confermaBlocco
            }
        };


        println@Console("Controllo in quanti me l'hanno validato")();
        countConferme = 0;

        for (j = 0, j < #confermaBloccoInterna, j++)
        {
            if (confermaBloccoInterna[j] == true) {
            countConferme++
            }
        };


        nodiEsterni = #listaPorte.porta - 1;

        if (countConferme > (#confermaBloccoInterna/3)) {
            println@Console(countConferme + " nodi su " + nodiEsterni + " mi hanno validato il blocco")();
            println@Console("Aggiungo il blocco alla blockchain")();
            aggiungiBlocco
        } else {
            println@Console("Me l'hanno rifiutato!")()
        };


        lasciaSemaforo@TimeOut(1)();
        lasciaSemaforo@TimeOut(2)()
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
    ]};

    // so che il network visualizer mi chiederà la blockchain

    [
        getBlockchain()(response) {
            response << blockchain
        }
    ]
    

    

    
  
}