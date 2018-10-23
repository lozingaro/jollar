include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "TransInterface.iol"
include "file.iol"
include "NetworkInterface.iol"

outputPort TransactionC {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionSaver3 {
	Protocol: sodep
	Interfaces: TransInterface
}

outputPort TransactionForBlock3 {
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
		showInputDialog@SwingUI( "NODO C \n Inserisci destinatario (1/2/4)\n" )( request.name );
		if((0<request.name) && (request.name<=4) && (request.name!=3)){
			TransactionC.location="socket://localhost:800"+request.name;
			println@Console( TransactionC.location )();
			undef( mon );
			mon.filename="WalletC";
			mon.format="json";
			readFile@File(mon)(monres);
			showInputDialog@SwingUI( "hai "+ monres + " jollar, quanti ne vuoi inviare?" )( request.jollar );
			send.jollar=int(request.jollar);
			send.nodeBuyer="socket://localhost:8003";
			send.nodeSeller=TransactionC.location;
			
			if(send.jollar<=monres && send.jollar>0){
				undef( req );
				req.filename="LocationPorte";
				req.format="json";
				readFile@File(req)(resLoc);
				sendString@Netview("TRANSAZIONE -> "+ send.jollar + " JOLLAR"+"\n"+"MITTENTE: " + send.nodeBuyer + "\n" + "RICEVENTE: " + send.nodeSeller);
				sender@TransactionC( send );
				
				for(i=1,i<=resLoc,i++){
					locationControllo=(resLoc.("figlio"+i));
					TransactionForBlock3.location= locationControllo;
					saveForBlockchain@TransactionForBlock3(send);
					
					if((locationControllo==send.nodeBuyer)||(send.nodeSeller==locationControllo)){
						TransactionSaver3.location=resLoc.("figlio"+i);
						saver@TransactionSaver3( send )
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