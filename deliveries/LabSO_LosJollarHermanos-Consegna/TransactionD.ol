include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "TransInterface.iol"
include "file.iol"
include "NetworkInterface.iol"

outputPort TransactionD {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionSaver4 {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionForBlock4 {
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
		showInputDialog@SwingUI( "NODO A \n Inserisci destinatario (1/2/3)\n")( request.name );
		if((0<request.name) && (request.name<=4) && (request.name!=4)){
			TransactionD.location="socket://localhost:800"+request.name;
			println@Console( TransactionD.location )();
			undef( mon );
			mon.filename="WalletD";
			mon.format="json";
			readFile@File(mon)(monres);
			showInputDialog@SwingUI( "hai "+ monres + " jollar, quanti ne vuoi inviare?" )( request.jollar );
			send.jollar=int(request.jollar);
			send.nodeBuyer="socket://localhost:8004";
			send.nodeSeller=TransactionD.location;
			
			if(send.jollar<=monres && send.jollar>0){
				undef( req );
				req.filename="LocationPorte";
				req.format="json";
				readFile@File(req)(resLoc);
				sendString@Netview("TRANSAZIONE -> "+ send.jollar + " JOLLAR" +"\n"+"MITTENTE: " + send.nodeBuyer + "\n" + "RICEVENTE: " + send.nodeSeller);
				
				sender@TransactionD( send );
				
				for(i=1,i<=resLoc,i++){
					locationControllo=(resLoc.("figlio"+i));
					TransactionForBlock4.location=locationControllo;
					saveForBlockchain@TransactionForBlock4(send);
					
					if((locationControllo==send.nodeBuyer)||(send.nodeSeller==locationControllo)){
						TransactionSaver4.location=resLoc.("figlio"+i);
						saver@TransactionSaver4( send )
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