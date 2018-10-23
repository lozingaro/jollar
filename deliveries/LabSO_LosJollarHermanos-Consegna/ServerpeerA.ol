include "time.iol"
include "console.iol"
include "InterfaceTime2.iol"
include "file.iol"
include "math.iol"
include "Interfaceservpeer.iol"
include "TransInterface.iol"
include "NetworkInterface.iol"

execution{ concurrent }

inputPort ServerA {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces: InterfaceTime2,
	Interfaceservpeer,
	TransInterface 
}

//Porta usate solo per estrarre location server perchè non è possibile estrarre da inputport
outputPort ServerAC {
	Location: "socket://localhost:8001"
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
	
	delete@File("TempT1")();
	println@Console( "SERVER A" )();
	sendString@Netview("Nodo A connesso");
	count@Timeoutput(1);
	getTime@Timeoutput()(a);
	
	getLocation@Timeoutput(ServerAC.location);
	println@Console( ServerAC.location )();
	println@Console( a )();
	//creazione wallet
	delete@File("WalletA")();
    req.filename="WalletA";
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
    //controllo del numero primo attraverso l'algoritmo di Fermat
    [controllo(c1)(m){
    	println@Console(c1)();
    	powReq2.base=2;
    	powReq2.exponent=c1-1;
    	pow@Math(powReq2)(result2);
    	m=result2%c1
    }]
    // parte di ricezione di una transazione da un nodo x al nodo A
    [sender( request )]{
        mon.filename="WalletA";
        mon.format="json";
        readFile@File(mon)(monres);
        //aggiornamento wallet 
        jollar=int(monres)+int(request.jollar);
        println@Console("Nodo ricevente" + request.nodeSeller)();
        println@Console("Nodo inviante" + request.nodeBuyer)();
        mon.content<<jollar;
        writeFile@File(mon)()
    }
    //ricezione e salvataggio delle transazioni riguardanti il nodo A
    [saver(receive)]{
    	undef(trans2);
    	global.contatoreTran++;
    	println@Console("CONTATORE:    "+global.contatoreTran)();
    	global.block.transaction[global.contatoreTran]<<receive;
    	trans2.filename="TransazioniA";
    	trans2.format="json";
    	trans2.append=1;
    	trans2.content<<receive;
    	writeFile@File(trans2)()
    }
    
    //ricezione di tutte le transazioni avvenute dopo la scrittura dell'ultimo blocco,
    // e quindi non ancora scritte in blockchain
    [saveForBlockchain(transactions)]{
    	global.contatoreTran2++;
    	println@Console("CONTATORE:    "+global.contatoreTran2)();
    	global.block2.transaction[global.contatoreTran2]<<transactions
    }
    
    //Quando viene trovato un numero primo da parte del rispettivo client, 
    //avremo la scrittura di un nuovo blocco nella blockchain contenente global.block2        
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
    	
    	//reset dinamico dei blocchi temporanei
    	//(una volta che il blocco viene creato manda una richiesta agli altri server per cancellare il blocco temporaneo delle transazioni)         
    	for(i=1,i<=resLoc,i++){
    		locationControl=(resLoc.("figlio"+i));
    		if(locationControl!="socket://localhost:8001"){
    			ResetServer.location=locationControl;
    			resServ@ResetServer()
    		}
        }
    }
    //reset dei blocchi temporanei dopo il blocco viene scritto (vengono azzerate le transazioni precedenti)
    [resServ()]{
    	undef(global.block2);
    	undef(blocco)
    } 
}
