include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "TransInterface.iol"
include "file.iol"
include "NetworkInterface.iol"

outputPort TransactionA {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionSaver {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionForBlock {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort Netview {
	Location: "socket://localhost:8010"
	Protocol: sodep
	Interfaces: NetworkInterface
}

main
{   
	undef( send ); 
	keepRunning = true;
	while( keepRunning ){
		//apertura finestra finestra di dialogo per effettuare transazioni
		showInputDialog@SwingUI( "NODO A \n Inserisci destinatario (2/3/4)\n" )( request.name );
		if((0<request.name) && (request.name<=4) && (request.name!=1) ){
			//la locazione soddisfa i requisiti, entro nell' invio della transazione vera e propria
			TransactionA.location="socket://localhost:800"+request.name;
			println@Console( TransactionA.location )();
			undef( mon );
			mon.filename="WalletA";
			mon.format="json";
			readFile@File(mon)(monres);
			showInputDialog@SwingUI( monres + " jollar \n Quanti ne vuoi inviare?" )( request.jollar );
			send.jollar=int(request.jollar);
			send.nodeBuyer="socket://localhost:8001";
			send.nodeSeller=TransactionA.location;
			
			if(send.jollar<=monres && send.jollar>0){
				undef( req );
				req.filename="LocationPorte";
				req.format="json";
				readFile@File(req)(resLoc);
				sendString@Netview("TRANSAZIONE -> "+ send.jollar + " JOLLAR" +"\n"+"MITTENTE: " + send.nodeBuyer + "\n" + "RICEVENTE: " + send.nodeSeller);
				//invio al ricevente la transazione
				sender@TransactionA( send );

				//invio a tutti la transazioni
				for(i=1,i<=resLoc,i++){
					locationControllo=(resLoc.("figlio"+i));
					TransactionForBlock.location=locationControllo;
					saveForBlockchain@TransactionForBlock(send);
				    
				    //invio solo ai nodi coinvolti la transazione
					if((locationControllo==send.nodeBuyer)||(send.nodeSeller==locationControllo)){
						TransactionSaver.location=resLoc.("figlio"+i);
						saver@TransactionSaver( send )
					}
				};
				mon.content<<monres-send.jollar;
				writeFile@File(mon)();
				println@Console("Quantità di jollar disponibili " + mon.content)()
			}
			else{
				println@Console("Non hai fondi sufficienti!")()
			}
		}
	}
}