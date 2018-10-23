//questo file e' il lanciatore da terminale
//e' come se fosse il terminale da cui controllare tutta l'applicazione

include "console.iol"
include "CreateInterface.iol" 
include "file.iol"
include "string_utils.iol"
include "time.iol"
include "terminal.iol" //interfaccia tra nodo e nodo ( terminal e terminal) ( terminal.iol)
include "message_digest.iol"
include "Blockchain.iol"
include "miner.iol"
include "INetworkVisualizer.iol"


outputPort Visualizer {
  Location: "socket://localhost:8055"
  Protocol: sodep
  Interfaces: INetworkVisualizer
}
/*
Interfaccia di comunicazione tra terminale e se stesso ( in realta tra time e terminale.ol),
per utilizzare le operation in input choice nel main, tramite le chiamate del 
servizio Time
*/
outputPort Timestamp {
  Protocol: sodep
  RequestResponse: getTime(void)(long),getDate(void)(string)
}
embedded {
  Jolie: "timestamp.ol" in Timestamp
}

constants {
  utente1 = "MIIBtzCCASwGByqGSM44BAEwggEfAoGBAP1/U4EddRIpUt9KnC7s5Of2EbdSPO9EAMMeP4C2USZpRV1AIlH7WT2NWPq/xfW6MPbLm1Vs14E7gB00b/JmYLdrmVClpJ+f6AR7ECLCT7up1/63xhv4O1fnxqimFQ8E+4P208UewwI1VBNaFpEy9nXzrith1yrv8iIDGZ3RSAHHAhUAl2BQjxUjC8yykrmCouuEC/BYHPUCgYEA9+GghdabPd7LvKtcNrhXuXmUr7v6OuqC+VdMCz0HgmdRWVeOutRZT+ZxBxCBgLRJFnEj6EwoFhO3zwkyjMim4TwWeotUfI0o4KOuHiuzpnWRbqN/C/ohNWLx+2J6ASQ7zKTxvqhRkImog9/hWuWfBpKLZl6Ae1UlZAFMO/7PSSoDgYQAAoGATtaVpeV4ETBkNbakaQWl3kSu6VkZbrKVBQTu5S2Zfruc6gJ2BvM1Jb4FKIe3V+tYGNd8iS48tLIPuq61qdBeMk6tWpFlkEmZhecHjvQV2xlnxLmacz3CK09RS9cfW2BUBH0eXqshpJWu6b0qEwhA9qFEnYMCemNUebbRdTjiPZA=",
  utente2 = "MIIBtzCCASwGByqGSM44BAEwggEfAoGBAP1/U4EddRIpUt9KnC7s5Of2EbdSPO9EAMMeP4C2USZpRV1AIlH7WT2NWPq/xfW6MPbLm1Vs14E7gB00b/JmYLdrmVClpJ+f6AR7ECLCT7up1/63xhv4O1fnxqimFQ8E+4P208UewwI1VBNaFpEy9nXzrith1yrv8iIDGZ3RSAHHAhUAl2BQjxUjC8yykrmCouuEC/BYHPUCgYEA9+GghdabPd7LvKtcNrhXuXmUr7v6OuqC+VdMCz0HgmdRWVeOutRZT+ZxBxCBgLRJFnEj6EwoFhO3zwkyjMim4TwWeotUfI0o4KOuHiuzpnWRbqN/C/ohNWLx+2J6ASQ7zKTxvqhRkImog9/hWuWfBpKLZl6Ae1UlZAFMO/7PSSoDgYQAAoGANVeB7tt5pCx8m6sHj19LXX8nbWJB/QqQ5hd0dxNnuH7QgLgZrhkYFyG9YwaO2+f87Lv5tZ24h4EMxVgF73GWqV5LyHqqqSxoHJPF3hCDFYRikub4ZxQOvuccKfJF0K7c3LEVEQqRAksCp/M48L8dsi825kVfIG71FywJX3A6Mg8=",
  utente3 = "MIIBtzCCASwGByqGSM44BAEwggEfAoGBAP1/U4EddRIpUt9KnC7s5Of2EbdSPO9EAMMeP4C2USZpRV1AIlH7WT2NWPq/xfW6MPbLm1Vs14E7gB00b/JmYLdrmVClpJ+f6AR7ECLCT7up1/63xhv4O1fnxqimFQ8E+4P208UewwI1VBNaFpEy9nXzrith1yrv8iIDGZ3RSAHHAhUAl2BQjxUjC8yykrmCouuEC/BYHPUCgYEA9+GghdabPd7LvKtcNrhXuXmUr7v6OuqC+VdMCz0HgmdRWVeOutRZT+ZxBxCBgLRJFnEj6EwoFhO3zwkyjMim4TwWeotUfI0o4KOuHiuzpnWRbqN/C/ohNWLx+2J6ASQ7zKTxvqhRkImog9/hWuWfBpKLZl6Ae1UlZAFMO/7PSSoDgYQAAoGANXXIjfJMG1tWeyi28j3m6xRhBteiSx2AOIdNzSTi0P4p/YE/yas+cxWIZyxyLmHcCAt1o5su9tuv7s6AhbMi3+B+Xe0PZu9kkhz7Hb/XXRTLrbn47Zj7nDJC+Ofg2U2eMrhr07o+FlzmguHKb8c9OCGYQZfT39nXMhnuYw2nOXs="
}

inputPort Local {
  Location: "local"
  Protocol: sodep
  Interfaces: Local,Terminal
}
inputPort Intern { //aggiungo anche l'interfaccia per ricevere dal proprio cat ! .
Location: mylocat
Protocol: http
Interfaces: Terminal,Local
  //,LocalOperationCatTerm
}

//miner

outputPort Miner {
  Location: "local"
  Protocol: sodep
  Interfaces: MinerInterface
}

embedded {
  Jolie: "miner.ol" in Miner
}
//


//Blockchain
outputPort Blockchain {
  Interfaces: BlockchainInterface
}

embedded {
  Jolie: "Blockchain.ol" in Blockchain
}
//fine//

//Altri terminali
outputPort Out { //
  Protocol: http
  Interfaces: Terminal
}
//fine// 


interface Proxy {
OneWay: inoltraBlocco(undefined),inoltraTx(undefined),getNextIndex(undefined),inoltraIndex(undefined)
}
outputPort Proxy {
  Location: "socket://localhost:8092"
  Protocol: sodep
  Interfaces: Proxy }




//fine proxy
  outputPort MySelf {
    Location: mylocat
    Protocol: http
    OneWay: printSet(void),startTerminal(undefined)
  }

  define readNodeList{
    scope( reed )
    {
      install( FileNotFound => println@Console( "assicurarsi che sia presente nodelist.txt" )() );
      readFile@File({.filename="nodelist.txt"})(fileLetto);
      
      println@Console( "Letto da file: "+fileLetto )()

    } 

  }

  define getBlockchain
  {

    scope( reed )
    {
      install( TypeMismatch => println@Console( "Attenzione ! Impostare prima il nome utente (-setUser)" )() );
      undef(global.blockchain);
    readBlockChain@Blockchain(global.username)(global.blockchain)//cambia
  } 
  ;
  valueToPrettyString@StringUtils(global.blockchain)(respretty);
  println@Console( respretty )()
}

define setUser
{
  println@Console( "Inserisci il tuo username" )();
  undef( userin );
  userin="";
  userin.token=global.csets.sid;
  in(userin);
  global.username=userin ;//imposto username (da mettere sync)
  //changeUser@Cunningham(global.username);
  startBlockchain@Blockchain(global.username)(global.blockchain);
  println@Console( "ora per iniziare a minare digita -s, oppure -sync per sincronizzare" )();
  undef( global.blockchain );
  readBlockChain@Blockchain(global.username)(global.blockchain)
}
define printPublic
{
   if( is_defined( global.username ) ) {
    scope( publ )
    {
      install( TypeMismatch => println@Console( "non hai creato le chiavi" )() );
            readPublicKey@Blockchain(global.username)(res);
            println@Console( "La tua chiave pubblica e' :"+res )()

    }
    }else{
      println@Console( "non hai impostato l'username" )()
    } 


}
define creaTransazione
{
  if(is_defined( global.username )){
    println@Console( "Ciao "+global.username+" benvenuto/a nella creazione di una nuova transazione" )();
    println@Console( "Ora ti verrano mostrate le transazioni spendibili " )();
    println@Console( "Selezionane una inserendo il numero corrispondente" )();
    readPublicKey@Blockchain(global.username)(pubKey);
    pubKey.user=global.username;
    getUtxo@Blockchain(pubKey)(res);
    for ( resIndex=0, resIndex<#res.result, resIndex++ ) {
      println@Console( "Numero UTXO: "+resIndex+" | Hash :"+res.result[resIndex]+" | Valore : 6 Jollar" )()
    };
    println@Console( "Ora inserisci il numero della UTXO che vuoi utilizzare" )();
    println@Console( "Inserici un numero da 0 a "+int(#res.result-1))();
    in(inTxUtxoId);
    transactionRequest.transactions.input.previousUtxoTxid=res.result[inTxUtxoId];
    scope( altezzaScope )
    {
      install( TypeMismatch => println@Console( "Altezza non trovata !" )();throw( TxError ) );
      trovaAltezza@Blockchain(res.result[inTxUtxoId])(txAltezza)

    };
    transactionRequest.transactions.input.altezzablocco=txAltezza;
  transactionRequest.transactions.input.amount=6;//sostituire 
  transactionRequest.sid=global.csets.sid;
  transactionRequest.transactions=0; // id della transazione

  println@Console( "Inserisci la chiave pubblica di chi vuoi pagare oppure un numero da 1 a 3 rappresentante
    gli indirizzi in rubrica degli altri nodi della DEMO" )();
    println@Console( "RUBRICA DEMO" )();
    println@Console( "1 | Username: Utente1 | Indirizzo:" +utente1)();
    println@Console( "2 | Username: Utente2 | Indirizzo:" +utente2)();
    println@Console( "3 | Username: Utente3 | Indirizzo:" +utente3)();
  //sostituire con rubrica
    println@Console( "Inserisci un numero da 1 a 3 oppure una chiave pubblica" )();
    in(inPub);
    if(inPub==1 || inPub ==2 || inPub ==3){
      println@Console( "Hai scelto un destinatario della rubrica DEMO" )();
if(inPub==1) transactionRequest.transactions.output.payto=utente1;//utilizzo della costante
if(inPub==2) transactionRequest.transactions.output.payto=utente2;
if(inPub==3) transactionRequest.transactions.output.payto=utente3
}else{
  println@Console( "Hai inserito una chiave pubblica" )();
  transactionRequest.transactions.output.payto=inPub

};
  //transactionRequest.transactions.output.amount=global.blockchain[0].block[inBlocc].transaction[inIndiceTx].output.amount;
println@Console( transactionRequest.transactions.input.signature )();
  //=signature;
scope( sendtoProxy )
{
  install( IOException => println@Console( "ERRORE nell'avviare MyProxy.ol !" )() );
  transactionRequest.me=mylocat;
  inoltraTx@Proxy(transactionRequest)
}
}else{
  println@Console( "Impostare un username prima!" )()
}
}

define comandiUtente
{
  println@Console( "Benvenuti in Jollar " )();
  getDate@Timestamp()(data);
  println@Console( data )();
  println@Console( "Inserisci command (-h for help, -c for exit)" )();
  println@Console( "Digita -h per visualizzare una lista dei comandi" )();
  println@Console( "Inserisci -list per mostrare i portafogli che puoi importare" )();
  while(esci==false){
    inputUtente="nulla";
    ConsoleInputPort.location="socket://localhost";
    in(inputUtente);
    if(inputUtente=="-h"){
      println@Console( "Help" )();
      println@Console( "-chisono?: ritorna il tuo username" )();
      println@Console("-create: Crea portafoglio")();
      println@Console( "-setUser: Se hai gia' un portafoglio, inserisci il tuo username e verrà importato" )();
      println@Console( "-h : Help" )();
      println@Console( "-c : Close " )();
      println@Console( "-list: Mostra i portafogli che puoi importare" )();
      println@Console( "-startMining oppure -s oppure -mining : Inizia ricerca catene di numeri primi " )();
      println@Console( "-inviaJollar: Invia transazione" )();
      println@Console( "-getBlockchain : Stampa la blockchain a video" )();
      println@Console( "-printPublic: Mostra a video la tua chiave pubblica" )();
      println@Console( "-getMyUtxo : Mostra i tuoi jollar spendibili" )();
      println@Console( "-status: Mostra lo stato all'utente e lo invia al Network Visualizer " )();
      println@Console( "-sync: Controlla se la tua blockchain e' sincronizzata con la rete" )()



    }else if(inputUtente=="-s" || inputUtente=="-startMining" || inputUtente== "-mining"){
      scope( userScope )
      {
        install( UsernameError => println@Console( "ERRORE: Chiamare prima SetUser" )() );
        if( !is_defined( global.username ) ) {
          throw( UsernameError )
        }
      }
     // getBlockHash@Blockchain(4)(resBlockHash);//toglierla
     // println@Console( resBlockHash )()
      ;
      scope( reed )
      {  install( IOException => println@Console( "" )() );
      readBlockChain@Blockchain(global.username)(global.blockchain)
    };
    minaRequest.message<<global.blockchain;
    minaRequest.location=mylocat;
    minaRequest.sid=global.csets.tokenSid=global.csets.sid;
    minaBlocco@Miner(minaRequest)
  }else if(inputUtente=="-getMyUtxo"){
    undef( pubKey );
    readPublicKey@Blockchain(global.username)(pubKey);
    pubKey.user=global.username;
    getUtxo@Blockchain(pubKey)(utxo);
    for ( resIndex=0, resIndex<#utxo.result, resIndex++ ) {
      println@Console( "Numero UTXO: "+resIndex+" | Hash :"+utxo.result[resIndex]+" | Valore : 6 Jollar" )()
    };
    println@Console( "Totale Jollar = " +6*#utxo.result)()


  }else if(inputUtente=="-printPublic"){
    printPublic
  }else if(inputUtente=="-getBlockchain"){
   getBlockchain
 }else if(inputUtente=="-inviaJollar"){
  scope( trx )
  {
    install( TxError => println@Console( "Errore nella transazione, riprova" )() );
     //  readNodeList;
    creaTransazione
  }

}else if(inputUtente=="-list"){
      //cerca nella cartella attuale tutte le chiavi private
  undef( res );
  getServiceDirectory@File( void )( dir );
      list@File({.directory=(dir),.regex=".*privk"})(res);//dynamic lookup
      valueToPrettyString@StringUtils(res)(prettyres);

      //rimuovi contenuti da valuetoprettystring
      with( prettyres ){
        .regex="privk";
        .replacement=""
      };
      replaceAll@StringUtils(prettyres)(prettyres);
      with( prettyres){
        .regex=": java.lang.String";
        .replacement=""
      } ;
      replaceAll@StringUtils(prettyres)(prettyres);
      println@Console( "Sono state trovate le seguenti chiavi private:" )();
      println@Console(prettyres)();

      println@Console( "Ora ricopia uno degli username qui sopra (il tuo) e inseriscilo quando ti viene richiesto dal comando -setUser")()
    }else if (inputUtente=="-create"){

      println@Console("ok , inserisci il nome del file su cui verranno salvate le chiavi")();
      undef( resp );
        //nomefile.token="prova";
      in(nomefile);
      CreateWall@CreateWallet(string(nomefile))(resp);
      println@Console("Il nome utente da utilizzare da ora in poi e'  "+ resp )();
      synchronized( tokenUsername ){
        global.username=resp

      }
    }else if(inputUtente=="-listNode"){
      readNodeList
    }
    else if(inputUtente=="-c"){

      println@Console( "Sistema stoppato. Chiudere completamente il terminale? (Y/N)")();
      in(yesornot);
      while( yesornot!= "Y" &&  yesornot !="N" ) {
        println@Console( "Inserisci Y oppure N (maiuscolo!)" )();
        in(yesornot)
      };
      if(yesornot=="Y"){
        println@Console( "Arrivederci...Chiusura in corso..." )();esci=true;throw( ErrorTest )
      }else{println@Console( "Hai deciso di restare qui..." )();  
      println@Console( "Input command (-h for help, -c for exit)" )()
    }

  }else if(inputUtente=="-sync"){
    println@Console( "ATTENZIONE! Se risulterai non sincronizzato, la tua blockchain verrà sovrascritta!" )();
    println@Console( "Si vuole sovrascrivere la propria blockchain aggiornandola ?" )();
    println@Console( "Inserire Y oppure N e premere invio" )();
    in(inputYoN);
    if(inputYoN=="Y"){
      println@Console( "OK, invio la richiesta di sync alla rete" )();
     scope( proxy )
     {
      install( IOException => println@Console( "Avviare myproxy.ol !" )() );
      getNextIndex@Proxy({.me=mylocat})

    }
  }
}else if(inputUtente=="-status" ){
  println@Console( "Invio status al network visualizer" )();
  getDate@Timestamp()(data);
  visualizerReq.data=data;
  visualizerReq.user=global.username;
  readPublicKey@Blockchain(global.username)(visualizerReq.pubkey);
  getUtxo@Blockchain(visualizerReq.pubkey)(visualizerReq.utxo);
  visualizerReq.ultimaAltezza=int(#global.blockchain.block)-int(1);

  if( is_defined(global.username) ) {
   
    scope( visualizer )
    {
      install( IOException => println@Console( "ERRORE: Avviare NetworkVisualizer.ol   !!!!" )() );
      req.from=mylocat;
      req.message="Status Message";
      req.content<<visualizerReq;
      print@Visualizer(req)
    }

  }else{
    println@Console( "Errore, chiamare prima -create o -setUser" )()
  }


}else if(inputUtente=="-setUser"){
  setUser

}else if(inputUtente=="-chisono?"){
  synchronized( tokenUsername ){
    if(global.username!=null){
      println@Console( "il mio username e'"+global.username )()
    }else{
      println@Console( "Username non impostato " )()
    }
  }
}else{
  println@Console( "Comando errato, controlla di averlo scritto correttamente" )()
}

}
}

cset {
  tokenSid: PushBlockReq.sid
}
cset {
  sid: SendTransactionReq.sid
}
cset { coreJavaserviceConsoleToken: InRequest.token }

init
{
  registerForInput@Console({.enableSessionListener=true})();
  subscribeSessionListener@Console({.token=csets.coreJavaserviceConsoleToken=new})( void );
  timeReq=100;
  global.csets.sid=new;
  timeReq.operation="startTerminal";
  timeReq.message.sid<<global.csets.sid;
  setNextTimeout@Time(timeReq);
  esci=false
}
execution{ concurrent }
main
{[startTerminal(message)]{
  global.csets.sid=new;
      comandiUtente //define che mostra il menu su schermo
    }
    [pushBlock(blockreq)]{ //abbiamo appena trovato una catena di num. primi e siamo pronti a pushare il blocco verso la rete
      println@Console(" ." )();
      blockreq.me=mylocat;

      scope( inoltra )
      {

        install( IOException => println@Console( "Errore: Avviare il proxy broadcast !" )() );

        daHashare="defaultyr74r734nx78ry347r"+"6"+blockreq.message.altezza+string(blockreq.message.difficulty);

        md5@MessageDigest(daHashare)(daHashare.hashed);

        blockreq.message.transaction[0]=daHashare.hashed;
        blockreq.message.transaction[0].input.previousUtxoTxid="defaultyr74r734nx78ry347r";
       // blockreq.message.transaction.input="";
        blockreq.message.transaction.input.amount=6;

        getTime@Timestamp(void)(time);
        blockreq.message.timestamp=time;
        scope( readPub )
        { install( IOException => println@Console( "Errore lettura portafoglio ! Chiamare prima il comando -create ! " )() );

        readPublicKey@Blockchain(global.username)(pubKey)

      };
      blockreq.message.transaction.output.payto=pubKey;
      blockreq.message.transaction.output.amount= blockreq.message.transaction.input.amount;
      for ( i=0, i<#global.codaTransazioni, i++ ) {
        blockreq.message.transaction[i+1]<<global.codaTransazioni[i];
        daHashare[i+1]= blockreq.message.transaction[i+1].input.previousUtxoTxid+"6"+blockreq.message.altezza+blockreq.message.difficulty;
        md5@MessageDigest(daHashare[i+1])(daHashare[i+1].hashed);
        println@Console( "Trasformo "+daHashare[i+1]+ " in " +daHashare[i+1].hashed)();
        blockreq.message.transaction[i+1]=daHashare[i+1].hashed


      };
      undef( global.codaTransazioni );
      md5@MessageDigest(blockreq.message.data+blockreq.message.origine+blockreq.message.altezza)(hashed);
      blockreq.message.hash=hashed;
      inoltraBlocco@Proxy(blockreq)
    }

  }

    [sendBlock(mex)]{ // abbiamo ricevuto un blocco dalla rete
         scope( username )
      {
        install( TypeMismatch => println@Console( "Ricevuto blocco ma non so dove agganciarlo!  usa il comando -setUser !" )() );
        

 scope( genesisCheck )
      { 
        install( GenesisError => addValidBlock@Blockchain(mex.message));
        readBlockChain@Blockchain(global.username)(global.blockchain) ;
        getLastBlockIndex@Blockchain()(actualBlockNum)

        ;
        if( mex.message.altezza==0||mex.message.altezza==-1||!is_defined( mex.message.altezza ) ) {
          throw( GenesisError )

        }
      }

      }
     ;
   
      println@Console( "Il blocco attuale e'"+actualBlockNum )();
      expectedBlockNumber=actualBlockNum+1; 
      println@Console( "Aggiunta blocco in corso. " )();
     //
     // stop@Cunningham();//
      if(mex.message.altezza==expectedBlockNumber){
        println@Console( "Ricevuto il blocco Num "+mex.message.altezza+",sono pronto ad agganciare al mio blocco Num "+actualBlockNum)();
        scope( scopeName )
        {         install( IOException => println@Console( "errore nell ottenimento hash" )() );
        if(actualBlockNum!=-1) getBlockHash@Blockchain(actualBlockNum)(expectedPreviousHash)
      } ;
    if( mex.message.previousBlockHash==expectedPreviousHash ) {
      println@Console( "previous hash del blocco giusto..cioe'. continuo il controllo" )();
            //controllo se l'hash della transazione e' giusto:
      undef( i );
      resultBool=true;
      for ( i=0, i<#mex.message.transaction, i++ ) {
        daHashare[i]=""+mex.message.transaction[i].input.previousUtxoTxid+mex.message.transaction[i].input.amount+mex.message.altezza+mex.message.difficulty;
        md5@MessageDigest(daHashare[i])(daHashare[i].hashed);
        println@Console( "la transazione "+i+" ha hash :"+daHashare[i].hashed)();
        if(mex.message.transaction[i]==daHashare[i].hashed){
          println@Console( "La transazione n."+i+" ha un hash CORRETTO" )()

        }else{
          println@Console("La transazione n."+ i+ "ha Hash sbagliato")();
          resultBool=false
        } 
      };
        if( resultBool==true ) {//aggiungiamo il blocco !!!
          addValidBlock@Blockchain(mex.message);
          readBlockChain@Blockchain(global.username)(global.blockchain)
        }
      }else{
        println@Console( "Previous hash errato, non corrisponde al vero Hash Blocco precedente" )()
      }
    }else{
      println@Console( "Numero blocco errato rispetto a cio' che mi aspetto " )();
      println@Console( "perche' il mio e' "+expectedBlockNumber+"mentre quello che mi e' arriv e' "+mex.message.altezza )()
    }
  //ora devo verificare che il blocco ricevuto sia valido....
  //se si,  devo bloccare il mio cat.. che deve smettere di minare
  // e deve ricominciare ! con la giusta difficulty !
  //se il blocco non è valido allora non faccio nulla !
  }



[sendIndex(index)]{//ricevo indice dagli altri per sincronizzarmi !
  println@Console( "Ho ricevuto l' altezza blockchain : "+index )();
  undef( actualBlockNum );
  getLastBlockIndex@Blockchain()(actualBlockNum);
  println@Console( "mentre il mio ultimo blocco (locale) e' :"+ actualBlockNum)();
  if(actualBlockNum<index){
   println@Console( "---Non sincronizzato---" )();
   println@Console( "Aggiorno la blockchain con quella contenente "+index+" blocchi" )();
   global.blockchain<<index.blockchain;
   writeBlockchainReq.blockchain<<global.blockchain;
   writeBlockchainReq.user<<global.username;
   writeBlockchain@Blockchain(writeBlockchainReq)
 }
}
[pushMeIndex(pushMeIndexReq)]{ //qualcuno mi ha chiesto di sincronizzarmi !
  undef( actualBlockNum );
  getLastBlockIndex@Blockchain()(actualBlockNum);//cambiare Cat in filesystemrw
  readBlockChain@Blockchain(global.username)(actualBlockNum.blockchain);
  actualBlockNum.to=pushMeIndexReq.me;
  actualBlockNum.me=mylocat;
  inoltraIndex@Proxy(actualBlockNum)
}
[sendTransaction(req)]{
  println@Console( "Ricevuta la seguente transazione: " )();
  valueToPrettyString@StringUtils(req)(prettyRes);
  println@Console(prettyRes)();
  undef( temphash );
  temphash=req.transactions.input.previousUtxoTxid;
  trovaAltezza@Blockchain(temphash)(tempaltezza);// gli devo passare un hash di un output ()
  if(tempaltezza!=false){
    utxoreq.altezza=tempaltezza;
    utxoreq.hash=temphash;
    checkIfUnspent@Blockchain(utxoreq)(response);
    if( response==true ) {
      println@Console( "OK la transazione ricevuta si riferisce ad un output non speso" )();
        //ora devo controllare la signature
        //
      readBlockChain@Blockchain(global.username)(global.blockchain);
      global.codaTransazioni[#global.codaTransazioni]<<req.transactions
    }else{
      println@Console( "Problema, la transazione ricevuta prova a spendere un output gia speso" )()
        //TODO lanciare eccezione
    }
  }else{
    println@Console( "la transazione non esiste" )()
  }
  // se risponde TRUE, allora non è spesa
  ;
  undef(req.sid)
  //dopo averla verificata, la mando a Cat.ol che puo aggiungerla al blocco su cui sta lavorando
}
}