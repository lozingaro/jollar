//myproxy.ol ( BROADCAST ! )
//per contattare tutti gli altri nodi.
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "terminal.iol"
include "time.iol"

interface Proxy {//ho due interfacce uguali cioe' questa e l'interfaccia Proxy in terminale.ol , unirle
OneWay: inoltraBlocco(undefined),inoltraTx(undefined),getNextIndex(undefined),inoltraIndex(undefined)
}

inputPort MyProxyIn {
	Location: "socket://localhost:8092"
	Protocol: sodep
	Interfaces: Proxy
}

outputPort Extern { // verso gli altri terminali
	Protocol: http
	Interfaces: ProxyToTerminalI,Terminal,Local
}

define readAllNodes
{
  scope( readScope )
  {
    install( FileNotFound => println@Console( "assicurarsi che sia presente nodelist.txt" )() );
    println@Console( "Leggo da nodelist.txt" )();
    readFile@File({.filename="nodelist.txt"})(fileLetto);
    println@Console(fileLetto )();
    req=fileLetto;
    req.regex=",";
    split@StringUtils(req)(res);
    for ( i=0, i<#res.result, i++ ) {
      println@Console("Letto il nodo p2p numero"+i+" con location:"+res.result[i])();
      global.nodi[i]=res.result[i]
    }
  };
  println@Console( "I nodi sono stati letti, attendo richieste di inoltro..." )()
  

  
}
init
{
  readAllNodes
}
execution{ concurrent }



main
{
  [inoltraBlocco(message)]{//per inoltrare il blocco agli altri nodi in modo trasparente
  	//per il chiamante
  	richiedente=message.me;
  	println@Console( "Ho ricevuto una richiesta di inoltro da parte di .+"+richiedente )();
  	pretty<<message.message;
  	valueToPrettyString@StringUtils(pretty)(prettyres);
    println@Console( prettyres )();

    println@Console( "ATTANCION" )();
    println@Console( "ATTANCION" )();


    undef(message.me);
    for ( j=0, j<#global.nodi, j++ ) {
      Extern.location=global.nodi[j];
      scope( externScope )
      {
        install( IOException => println@Console( "ERRORE NEL CONTATTARE IL SERVER"+j )() );
        sendBlock@Extern(message)

      }
    }  	
  }
  [inoltraTx(messageTx)]{//quando un client vuole inviare una transazione in broadcast
  	richiedente=messageTx.me;
  	undef(messageTx.me);
  	println@Console( "Ho ricevuto una richiesta di inoltro transazione." )();
  	for ( j=0, j<#global.nodi, j++ ) {
      Extern.location=global.nodi[j];
      scope( externScope )
      {
        install( IOException => println@Console( "ERRORE NEL CONTATTARE IL SERVER"+j )() );
        //if(Extern.location!=richiedente)
        sendTransaction@Extern(messageTx);
        println@Console( "contattato:"+global.nodi[j] )()
      }
    }  	
  }
  [getNextIndex(messageIndex)]{//un client la utilizza per controllare se è sincronizzato
  	richiedente=messageIndex.me;
    for ( j=0, j<#global.nodi, j++ ) {
      Extern.location=global.nodi[j];
      if(Extern.location!=richiedente) {
        scope( externScope )
        {
          install( IOException => println@Console( "ERRORE NEL CONTATTARE IL SERVER"+j )() );
          pushMeIndex@Extern(messageIndex)
        }
      }
    }  	
  }
  [inoltraIndex(messageInoltraIndex)]{
    destinatario=messageInoltraIndex.to;
    Extern.location=destinatario;
    scope( externScope )
    {
      install( IOException => println@Console( "ERRORE NEL CONTATTARE IL SERVER"+j )() );
      sendIndex@Extern(messageInoltraIndex)

    }

  }
  
}