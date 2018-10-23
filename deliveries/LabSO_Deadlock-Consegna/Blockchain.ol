include "MainInterface.iol"
include "Console.iol"
include "String_utils.iol"
include "file.iol"
include "message_digest.iol"

inputPort LocalInBlCh {
  Location: "local" 
  Interfaces: BlockchainInterface
}

execution{ concurrent}

init {
  global.path = "." 
}

main
{

  //conta il numero di blocchi della blockchain
  [contaBlocchiBlCh(fileDaLeggere)(nBlocchi){
    stringaFilename= fileDaLeggere;
    filename = global.path +  stringaFilename;
    exists@File( filename )( esiste );
    if ( esiste ) {
      read.filename = filename;
      readFile@File( read )( display );
      display.regex = "//";
      split@StringUtils(display)(riga);
      nBlocchi = #riga.result
    } 
    else if ( !esiste ) {
      nBlocchi = 0
    }
  }]

  //aggiorna la blockchain del nodo da cui riceve la richiesta
  [updateBlCh(requestBlCh)(responseBlCh){
    //controlla se il file esiste già
    stringaFilename= requestBlCh.nomefileBlCh;
    filename = global.path +  stringaFilename;
    exists@File( filename )( esiste );
    if ( esiste ) {
      //legge il contenuto e lo aggiorna con il nuovo blocco
      scope( file ) {
        install( FileNotFound => println@Console( "File non trovato" )() );
        read.filename = filename;
        readFile@File( read )( display );
        display.regex = "-";
        split@StringUtils(display)(riga);
        n = #riga.result;
        previous=riga.result[n-7];
        md5@MessageDigest(previous)(hashPrevious)
      };

      scope( file ) {
        install( FileNotFound => println@Console( "File non trovato" )() );
        write.filename = filename;
        rigaSucc = "-" + hashPrevious + 
              "-" + requestBlCh.block.difficulty + 
              "-" + requestBlCh.block.transaction.nodeSeller.publicKey+ 
              "-" + requestBlCh.block.transaction.nodeBuyer.publicKey + 
              "-" + requestBlCh.block.transaction.jollar +
              "-" + requestBlCh.block.transaction.timestamp  + 
              "-" + requestBlCh.block.timestamp  + "//";
        write.content = display + rigaSucc;
        writeFile@File( write )( void )
      };

      //legge il file in seguito all'aggiornamento
      scope( file ) {
        install( FileNotFound => println@Console( "File non trovato" )() );
        read.filename = filename;
        readFile@File( read )( display );
        display.regex = "//";
        split@StringUtils(display)(riga);
        println@Console( "contenuto postscrittura:" )();
        n = #riga.result;
        for (i=0, i<n, i++) {
          println@Console(  i + ". blocco: " + riga.result[i] )()
        } 
      }
    }  
    else if ( !esiste ) { 
      //crea il file scrivendo all'inizio il blocco genesis
      scope( file ) {
        install( FileNotFound => println@Console( "File non trovato" )() );
        idGenesis="";
        md5@MessageDigest(idGenesis)(hashGenesis);
        write.filename = filename;
        write.content = "-" + 0 +
              "-" + 2 +
              "-" + 0 +
              "-" + 0 +
              "-" + 6 +
              "-" + 0 +
              "-" + 0 +
              "//" +
              "-" + hashGenesis + 
              "-" + requestBlCh.block.difficulty + 
              "-" + requestBlCh.block.transaction.nodeSeller.publicKey + 
              "-" + requestBlCh.block.transaction.nodeBuyer.publicKey + 
              "-" + requestBlCh.block.transaction.jollar +
              "-" +  requestBlCh.block.transaction.timestamp + 
              "-" + requestBlCh.block.timestamp
               +"//"; 
        writeFile@File( write )( void );
        println@Console( "Nuovo file creato " + filename )()
      };

      scope( file ) {
        install( FileNotFound => println@Console( "File non trovato" )() );
        read.filename = filename;
        readFile@File( read )( display );
        display.regex = "//";
        split@StringUtils(display)(riga);
        println@Console( "contenuto postscrittura:" )();
        n = #riga.result;
        for (i=0, i<n, i++) {
          println@Console( "indice: " + i + " dati transaction: " + riga.result[i] )()
        } 
      }
  };
    

   responseBlCh = true



    
      
    
  }]

}

