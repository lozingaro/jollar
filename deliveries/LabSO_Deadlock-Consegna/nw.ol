include "time.iol"
include "MainInterface.iol"
include "console.iol"
include "String_utils.iol"
include "file.iol"
include "message_digest.iol"

inputPort Network {  
	Location:"socket://localhost:9000"
	Protocol: sodep
	Interfaces: NetInterface, DateInterface
}
 
outputPort Network_Broadcast { 
  Location: "socket://localhost:8000"
  Protocol: sodep
  Interfaces: NetInterface, BroadcastInterface
}

outputPort Network_Timestamp { 
  Location: "socket://localhost:8100"
  Protocol: sodep
  Interfaces: TimestampInterface, NetInterface, DateInterface
}

inputPort InPortTime {
  Location: "local"
  Protocol: sodep
  Interfaces: TimeInterface
  OneWay: myTimeout(string)
}

outputPort Blockchain {
  Interfaces: BlockchainInterface
}

embedded {
  Jolie: "Blockchain.ol" in Blockchain
}

//restituisce timestamp in millisecondi
define RichiestaTime { 
  request = "Richiesta da Network";
  TimeRequestResponse@Network_Timestamp( request )( response );
  millis = response
}

//restituisce timestamp in formato data-ora
define RichiestaData {
  request = millis; 
  DateRequestResponse@Network_Timestamp(request)(response);
  data=response;
  println@Console("Data e ora: "+data)() 
}

//imposta il timeout
define sendRequestWithTimer 
{
  timeoutRequest = int(30000);
  timeoutRequest.operation = "myTimeout";
  timeoutRequest.message= "Hello world! ";

  setNextTimeout@Time( timeoutRequest )   
}

//stampa la blockchain più lunga nel sistema
define stampaBlockchainMax {
  
  filename = global.path + "/fileBlockchain" + global.chiavePubblicaMax + ".txt";
  exists@File( filename )( esiste );
  if ( esiste ) {
    read.filename = filename;
    readFile@File( read )( display );
    display.regex = "//";
    split@StringUtils(display)(riga);
    n = #riga.result;
    for (i=0, i<n, i++) {
      println@Console( riga.result[i] )()
    } 
  } 
  else {
    println@Console( "Blockchain attualmente vuota" )()
  }
}

//stampa la blockchain del nodo
define stampaBlockchainNodo {
  synchronized( numNodiRegistratiToken ){
    global.numNodiRegistrati = #global.arrayTransazioni;
    for(i = 0, i < global.numNodiRegistrati, i++){
      filename = global.path + "/fileBlockchain" + global.arrayTransazioni[i] + ".txt";
      exists@File( filename )( esiste );
      if ( esiste ) {
        read.filename = filename;
        readFile@File( read )( display );  
        display.regex = "//";
        split@StringUtils(display)(riga);
        println@Console( "BLOCKCHAIN NODO:" + global.arrayTransazioni[i] )();
        n = #riga.result;
        for (j=0, j<n, j++) {
          println@Console( " blocco: " + j + " dati transaction: " + riga.result[j] )()
        }   
      } 
      else {
        println@Console( "Blockchain del nodo attualmente vuota" )()
      }

    }
  }
} 


execution {concurrent}

init{
        
        global.path =  "inserisci percorso";  
        global.maxNumBlocchi = 0;
        global.maxLocation = ""
}


main
{
  //Riceve dal nodo il via 
  [possoPartire(avvioNwReq)(){
    println@Console( avvioNwReq )();
    //registra le chiavi pubbliche dei nodi registrati alla rete
    synchronized( nNodiToken ) {
      if ( global.nNodi == 0) {
        global.arrayTransazioni[0] = avvioNwReq;
        global.nNodi = global.nNodi + 1
      }
      else {
        //controlla che l'id non sia già registrato
        if( avvioNwReq != arrayTransazioni[global.nNodi-1] ) {
          global.arrayTransazioni[global.nNodi] = avvioNwReq
        };
        global.nNodi = global.nNodi + 1
      }
    };
    sendRequestWithTimer
  }]

  //Stampa le informazioni della rete 
  [myTimeout(req)] {   

    synchronized( richiestaToken ){
    //richiedo al brodcast di chiedere ai nodi la lunghezza della blockchain
    println@Console("------ NUOVA RICHIESTA DATI ALLA RETE ------")();  
    
    richiestaInfoBroadcast@Network_Broadcast(); 
    
    RichiestaTime; 
    RichiestaData;
    
    sendRequestWithTimer
    

    }
  } 
 
  //riceve dai nodi il numero di blocchi della loro blockchain
  [rispostaNumeroBlocchi(rispostaNumero)]{
    synchronized( maxNumBlocchiToken ){
      synchronized( maxLocationToken ){
        //cerca la lunghezza massima delle blockchain
        if (rispostaNumero.numeroBlocchi > global.maxNumBlocchi) {
          global.maxNumBlocchi = rispostaNumero.numeroBlocchi;
          global.maxLocation = rispostaNumero.location;
          println@Console( "Blockchain più lunga:" )();
          println@Console( global.maxNumBlocchi )();
          reqSplit = global.maxLocation;
          reqSplit.regex = ":";
          split@StringUtils(reqSplit)(resSplit);
          global.chiavePubblicaMax = resSplit.result[2];

          stampaBlockchainMax;
          stampaBlockchainNodo
        } 
      }
    }
  }

  //riceve informazioni del nodo
  [invioInfoNodo(infoNodo)] {
        //scorre l'array che contiene le chiavi pubbliche dei nodi registrati
        for ( i = 0, i < global.nNodi, i++ ) {
          //controlla che l'id non sia già registrato
          if ( global.arrayTransazioni[i] == infoNodo.chiavePubblicaNodo ) {
            println@Console("TRANSAZIONI DEL NODO: " +  global.arrayTransazioni[i])();

            global.nTransazioni = #global.arrayTransazioni[i].transaction ;

            if ( global.nTransazioni== 0) {

              global.arrayTransazioni[i].transaction[0].nodeSeller.publicKey = infoNodo.transaction.nodeSeller.publicKey;
              global.arrayTransazioni[i].transaction[0].nodeBuyer.publicKey = infoNodo.transaction.nodeBuyer.publicKey;
              global.arrayTransazioni[i].transaction[0].jollar = infoNodo.transaction.jollar;
              global.arrayTransazioni[i].transaction[0].timestamp = infoNodo.transaction.timestamp;
              global.arrayTransazioni[i].transaction[0].date  = infoNodo.transaction.date;


              global.nTransazioni = #global.arrayTransazioni[i].transaction //+ 1
            }
            else {
               //controlla che la transazione non sia già registrata
              if( infoNodo.transaction.timestamp != global.arrayTransazioni[i].transaction[0].timestamp[global.nTransazioni-1] ) {

                global.arrayTransazioni[i].transaction[global.nTransazioni].nodeSeller.publicKey = infoNodo.transaction.nodeSeller.publicKey;
                global.arrayTransazioni[i].transaction[global.nTransazioni].nodeBuyer.publicKey = infoNodo.transaction.nodeBuyer.publicKey;
                global.arrayTransazioni[i].transaction[global.nTransazioni].jollar = infoNodo.transaction.jollar;
                global.arrayTransazioni[i].transaction[global.nTransazioni].timestamp = infoNodo.transaction.timestamp;
                global.arrayTransazioni[i].transaction[global.nTransazioni].date  = infoNodo.transaction.date
              };
              global.nTransazioni = #global.arrayTransazioni[i].transaction //+ 1

            };

            for ( j = 0, j <  #global.arrayTransazioni[i].transaction , j++  ) { 
              //stampa le transazioni in Uscita del nodo 
              if(global.arrayTransazioni[i] == global.arrayTransazioni[i].transaction[j].nodeSeller.publicKey ) {
                      println@Console( "Transazioni in USCITA:" )();
                      println@Console( "Nodo destinatario: "   + global.arrayTransazioni[i].transaction[j].nodeBuyer.publicKey)();
                      println@Console( "Jollar trasferiti: "   + global.arrayTransazioni[i].transaction[j].jollar)();
                      println@Console( "Data della transazione: "   + global.arrayTransazioni[i].transaction[j].date)()
              } 
            };

            for ( j = 0, j <  #global.arrayTransazioni[i].transaction , j++  ) {   

             //stampa le transazioni in Entrata del nodo 
              if ( global.arrayTransazioni[i]  == global.arrayTransazioni[i].transaction[j].nodeBuyer.publicKey) {
                println@Console( "Transazioni in ENTRATA:" )();
                println@Console( "Nodo mittente: "  + global.arrayTransazioni[i].transaction[j].nodeSeller.publicKey)();
                println@Console( "Jollar trasferiti: "  + global.arrayTransazioni[i].transaction[j].jollar)();
                println@Console( "Data della transazione: "   + global.arrayTransazioni[i].transaction[j].date)()  
              }
            }
          }
        }
    }

    //riceve il numero di jollar nel conto dei nodi
   [invioJollarNodo(infoJollarNodo)] {
    
      //ad ogni chiamata azzera i jollar della rete
    jollarRete = 0;

      for ( i = 0, i < global.nNodi, i++ ) {

              

                if ( global.arrayTransazioni[i] == infoJollarNodo.idNodoJ ) {

                  global.arrayTransazioni[i].jollarTot = infoJollarNodo.jollarNodo;
                  println@Console("Il NODO: " +  global.arrayTransazioni[i] +  " ha Jollar : "  + global.arrayTransazioni[i].jollarTot )()

                };
                 jollarRete = jollarRete + global.arrayTransazioni[i].jollarTot       
         
      };
       println@Console("I jollar in circolo nella rete sono: " + jollarRete )()  


   }

}//main