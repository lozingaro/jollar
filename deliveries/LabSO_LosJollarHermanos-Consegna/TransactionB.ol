include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "TransInterface.iol"
include "file.iol"
include "NetworkInterface.iol"

outputPort TransactionB {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionSaver2 {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionForBlock2 {
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
		showInputDialog@SwingUI( "NODO B \n Inserisci destinatario (1/3/4)\n")( request.name );
		if((0<request.name) && (request.name<=4) && (request.name!=2)){
			TransactionB.location="socket://localhost:800"+request.name;
			println@Console( TransactionB.location )();
			undef( mon );
			mon.filename="WalletB";
			mon.format="json";
			readFile@File(mon)(monres);
			showInputDialog@SwingUI( "hai "+ monres + " jollar, quanti ne vuoi inviare?" )( request.jollar );
			send.jollar=int(request.jollar);
			send.nodeBuyer="socket://localhost:8002";
			send.nodeSeller=TransactionB.location;
			
			if(send.jollar<=monres && send.jollar>0){
				undef( req );
				req.filename="LocationPorte";
				req.format="json";
				readFile@File(req)(resLoc);
				sendString@Netview("TRANSAZIONE -> "+send.jollar + " JOLLAR"+"\n"+"MITTENTE: " + send.nodeBuyer + "\n" + "RICEVENTE: " + send.nodeSeller);
				sender@TransactionB( send );
				
				for(i=1,i<=resLoc,i++){
					locationControllo=(resLoc.("figlio"+i));
					TransactionForBlock2.location= locationControllo;
					saveForBlockchain@TransactionForBlock2(send);
					
					if((locationControllo==send.nodeBuyer)||(send.nodeSeller==locationControllo)){
						TransactionSaver2.location=resLoc.("figlio"+i);
						saver@TransactionSaver2( send )
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