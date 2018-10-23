include "time.iol"
include "console.iol"
include "InterfaceTime2.iol"
include "message_digest.iol"
include "math.iol"
include "file.iol"
include "TransInterface.iol"
include "NetworkInterface.iol"
include "Interfaceservpeer.iol"

execution{ concurrent }

inputPort ServerB {
	Location: LOCATIONSERVERPEER
	Protocol: sodep
	Interfaces: InterfaceTime2,
	Interfaceservpeer,
	TransInterface
}

//Porta usate solo per estrarre location server
outputPort ServerBC {
	Location: "socket://localhost:8002"
}

outputPort Timeoutput {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: InterfaceTime2
}
outputPort Netview {
	Location: "socket://localhost:8010"
	Protocol: sodep
	Interfaces: NetworkInterface
}

outputPort ResetServer {
	Protocol: sodep
	Interfaces: TransInterface
}

init{
	delete@File("TempT2")();
	println@Console( "SERVER B" )();
	sendString@Netview("Nodo B connesso");
	count@Timeoutput(1);
	getTime@Timeoutput()(a);
	getLocation@Timeoutput(ServerBC.location);
	println@Console( ServerBC.location )();
	println@Console( a )();
	//creazione wallet
	delete@File("WalletB")();
    req.filename="WalletB";
    b=0;
    req.content<<b;
    req.format="json";
    writeFile@File(req)()
    
}

main
{  
	[count(a)]{ 
		contatore=contatore+1;
		println@Console( contatore )()
    }
    [controllo(c1)(m){
    	println@Console(c1)();
    	powReq2.base=2;
    	powReq2.exponent=c1-1;
    	pow@Math(powReq2)(result2);
    	m=result2%c1
    }]
    
    // parte di transazione
    [sender( request )]{
        mon.filename="WalletB";
        mon.format="json";
        readFile@File(mon)(monres);
        
        jollar=int(monres)+int(request.jollar);
        println@Console(monres +"  "+request.jollar+"Fanculo")();
        println@Console("Nodo ricevente" + request.nodeSeller)();
        println@Console("Nodo inviante" + request.nodeBuyer)();
        mon.content<<jollar;
        writeFile@File(mon)()
    }
    
    [saver(receive)]{
    	undef(trans2);
    	global.contatoreTran++;
    	println@Console("CONTATORE:    "+global.contatoreTran)();
    	global.block.transaction[global.contatoreTran]<<receive;
    	trans2.filename="TransazioniB";
    	trans2.format="json";
    	trans2.append=1;
    	trans2.content<<receive;
    	writeFile@File(trans2)()
    }
    
    [saveForBlockchain(transactions)]{	
    	global.contatoreTran2++;
    	println@Console("CONTATORE:    "+global.contatoreTran2)();
    	global.block2.transaction[global.contatoreTran2]<<transactions
    }

    [saveBlock(blocco)]{ 
        blocco<<global.block2;
        println@Console(blocco.previousBlockHash)();
        sav.filename="Blockchain";
        sav.format="json";
        sav.append=1;
        sav.content<<blocco;
        writeFile@File(sav)();
        undef( req );
        req.filename="LocationPorte";
        req.format="json";
        readFile@File(req)(resLoc);
        for(i=1,i<=resLoc,i++){
        	locationControl=(resLoc.("figlio"+i));
        	if(locationControl!="socket://localhost:8002"){
        		ResetServer.location=locationControl;
        		resServ@ResetServer()
        	}
        }
    }
    [resServ()]{
    	undef(global.block2);
    	undef(blocco)
    }
}