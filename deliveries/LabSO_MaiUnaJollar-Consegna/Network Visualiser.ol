include "console.iol"
include "interface.iol"
include "time.iol"


inputPort ListenerPort {
	Location: "socket://localhost:9510"
	Protocol: sodep
	Interfaces: Interfaccia
}

execution { concurrent }

main {

	[sendInfo(visualizer)] {

		scope( status ) {

			if( visualizer.status.nodeA == true ) {
			  	println@Console("SERVER A IS UP!")()
			}else{
				println@Console("SERVER A IS DOWN!" )() 
			};

			if( visualizer.status.nodeB == true ) {
			  	println@Console("SERVER B IS UP!")()
			}else{
				println@Console("SERVER B IS DOWN!" )() 
			};

			if( visualizer.status.nodeC == true ) {
			  	println@Console("SERVER C IS UP!")()
			}else{
				println@Console("SERVER C IS DOWN!" )() 
			};

			if( visualizer.status.nodeD == true ) {
			  	println@Console("SERVER D IS UP!")()
			}else{
				println@Console("SERVER D IS DOWN!" )() 
			}
		}; 

		println@Console( )();

		scope( transactions ) {														//questi 3 sono nella demo e piu importanti:
		 println@Console( "JOLLAR BUYER: " + visualizer.transactions.nodeBuyer )(); // Manca chi riceve / acquista il Jollar
		 println@Console( "JOLLAR SELLER: " + visualizer.transactions.nodeSeller )(); // Manca chi manda / vende il Jollar
		 																					// Manca l'elenco delle transazioni avvenute
		 println@Console( "TOTAL JOLLAR: " + visualizer.transactions.amount )();
		 println@Console( "NETWORK TOTAL JOLLAR: " + visualizer.transactions.totalNetwork )();	// da aggiornare con i nuovi amount
		 println@Console( "Public Key da seller: " + visualizer.transactions.nodeSeller.publicKey )()
		};
		println@Console()();

		scope(request) {
			println@Console("Il Time Stamp della richiesta: " + visualizer.request)()
		};
		// scope(blockchain) {
			// println@Console( "La blockchain piu lunga nella rete: " + visualizer.blockchain )()  //Manca la blockchain piu lunga nella rete
		// };

		println@Console()()
	}
 } 

