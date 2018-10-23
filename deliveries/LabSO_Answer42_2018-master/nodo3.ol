include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"
include "POW.ol"

//inputport
inputPort NODO3 {
	Location: "socket://localhost:8003"
	Protocol: sodep
	Interfaces:BlockchainInterface
}

//nodo 1
outputPort NODO1 {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces: BlockchainInterface
}

//nodo2
outputPort NODO2 {
	Location: "socket://localhost:8002"
	Protocol: sodep
	Interfaces: BlockchainInterface
}

//nodo4
outputPort NODO4 {
	Location: "socket://localhost:8004"
	Protocol: sodep
	Interfaces: BlockchainInterface
}
//timestamp
outputPort TIMESTAMP {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces:BlockchainInterface
}


init
{
  md5@MessageDigest("nodo3")(rispostaHashSegreto);
	md5@MessageDigest("hashnodo3")(rispostaHashPubblico);
	nodo3.publicKey = rispostaHashPubblico;
	nodo3.privateKey = rispostaHashSegreto;
	nodo3.jollarNumb = 0;
	nodo3.id_node = "nodo3";
	println@Console( "*****************************************************" )();
	println@Console( "Benvenuto nel terzo nodo autostoppista" )();
	println@Console( "*****************************************************" )();
	sleep@Time(300)();
	println@Console( "La confederazione VOGON ti augura un buon guadagno" )();
	println@Console( "*****************************************************" )();
	sleep@Time(300)();
	println@Console( "Ho creato il nodo: " + nodo3.id_node )();
	println@Console( "Chiave pubblica nodo: " + nodo3.publicKey )();
	println@Console( "Portafoglio: " + nodo3.jollarNumb )();

	connect@NODO1("Connesso.");
		infoNode3@TIMESTAMP(nodo3)
}

main
{
 	//download blockchain
	[
		sendBlockChain(blockchain)
	];
	println@Console( "---------------------------------------------" )();
	println@Console( "Ho effettuato il download della blockchain!!!" )();
	println@Console( "---------------------------------------------" )();

	//riceve in broadcast l'hash del blocco genesis
 	[ sendGenesisBlock(hashBloccoGenesis)];
 	println@Console( "Hash blocco genesis: "+ hashBloccoGenesis )();

 	//riceve i dati della transazione per la creazione del nuovo blocco
 	[newBlock(transazioneRicevuta)(risposta)
 	{
 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo3"
 	}]	;

 	//crea il blocco con i dati ricevuti
    blocco1.id_block=1;
	//codice per generare hash blocco random
	random@Math()(a);
	b = string(a);
	md5@MessageDigest(b)(hashBlocco);
	blocco1.hashBlock = hashBlocco ;
	//hash blocco precedente (genesis block)
	blocco1.previousBlockHash = hashBloccoGenesis;
	//blocco1.difficulty = ;
	//inserisce i dati della transazione nel blocco
	blocco1.transaction.hash_transaction = transazioneRicevuta.hash_transaction;
	blocco1.transaction.nodeSeller = transazioneRicevuta.nodeSeller;
	blocco1.transaction.nodeBuyer = transazioneRicevuta.nodeBuyer;
	blocco1.transaction.jollar = transazioneRicevuta.jollar;
	blocco1.transaction.timestamp = transazioneRicevuta.timestamp;
	//blocco1.n_catena = ;

		[startPOW(startPOWnodo)];
		println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
	  	println@Console( "*************************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
	  	println@Console( "*********************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
	  	println@Console( "***************************" )();
	  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();

	  	//comincia la proof of work
	  	proofOfWork;

	  	while( boolean == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	  		proofOfWork
	  	}
	  	;

			println@Console( "--------------------------------------" )();
		  	println@Console( "           FERMAT VALIDATO        	" )();
			println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
			println@Console( "			      	42					")();
		  	println@Console( "--------------------------------------" )();

	  		endPOW@TIMESTAMP("nodo3")(risposta);
	  		[endCritics(answNode1)];
				println@Console( "")();
	  		println@Console( "Il vincitore e': " + answNode1 )();
				println@Console( "")();
	  		[endCritics(answNode2)];
	  		[endCritics(answNode3)];
	  		[endCritics(answNode4)];

	  		if( answNode1 == "nodo3" ) {

	  		  //popola la dificolta del blocco
	  			blocco1.difficulty = difficult;
	  			blocco1.lunghezzaCatena = chainLength;
	  			nodo3.jollarNumb = nodo3.jollarNumb + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo3.jollarNumb +" jollar" )();
	  			println@Console( "" )();

	  			//aggiorna la blockchain
	  		blockchain.block[1].id_block =blocco1.id_block;
				blockchain.block[1].hashBlock =blocco1.hashBlock;
				blockchain.block[1].previousBlockHash =blocco1.previousBlockHash;
				blockchain.block[1].difficulty =blocco1.difficulty;
				blockchain.block[1].lunghezzaCatena = blocco1.lunghezzaCatena;

				//dati relativi alla transazione
				blockchain.block[1].transaction.hash_transaction=blocco1.transaction.hash_transaction;
				blockchain.block[1].transaction.nodeSeller=blocco1.transaction.nodeSeller;
				blockchain.block[1].transaction.nodeBuyer=blocco1.transaction.nodeBuyer;
				blockchain.block[1].transaction.jollar=blocco1.transaction.jollar;
				blockchain.block[1].transaction.timestamp=blocco1.transaction.timestamp;
	  			sendBlockChain@TIMESTAMP(blockchain)
	  		}else {
	  			sleep@Time(1000)();
				println@Console( "" )();
	  			println@Console( "Qualcun'altro ha gia' vinto il passaggio." )();
	  			println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo
	  		//la proof of work effettuata dai nodi
	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[sendBlockChain(newBlockChain)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();

	//servizio per la transazione tra il nodo1 e il nodo3
 		[newTransaction(newTransaction)(risultatoTransazione)
 	{
 		// nodo1.jollarNumb = nodo1.jollarNumb - newTransaction.jollar;
 		nodo3.jollarNumb = nodo3.jollarNumb + newTransaction.jollar;
		// risultatoTransazione = newTransaction.jollarINT
		risultatoTransazione = newTransaction.jollar
 	}];

 	println@Console( "-----------------" )();
 	println@Console( "NUOVA TRANSAZIONE" )();
 	println@Console( "-----------------" )();
 	println@Console( "Hai ricevuto: " + newTransaction.jollar + " jollar da --> " +
 		newTransaction.nodeSeller )();
 	println@Console( "Ora i tuoi jollar sono: "+ nodo3.jollarNumb )();

 	[newBlock(transazioneRicevuta)(risposta)
 	{
 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo3"
 	}];

 	//crea il blocco con i dati ricevuti
			 	blocco2.id_block=2;
				//codice per generare hash blocco random
				random@Math()(a);
				b = string(a);
				md5@MessageDigest(b)(hashBlocco);
				blocco2.hashBlock = hashBlocco ;
				//hash blocco precedente (genesis block)
				blocco2.previousBlockHash = newBlockChain.block[1].hashBlock;

				//inserisce i dati della transazione nel blocco
				blocco2.transaction.hash_transaction = transazioneRicevuta.hash_transaction;
				blocco2.transaction.nodeSeller = transazioneRicevuta.nodeSeller;
				blocco2.transaction.nodeBuyer = transazioneRicevuta.nodeBuyer;
				blocco2.transaction.jollar = transazioneRicevuta.jollar;
				blocco2.transaction.timestamp = transazioneRicevuta.timestamp;

		[startPOW(startPOWnodo)];

		println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
	  	println@Console( "*************************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
	  	println@Console( "*********************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
	  	println@Console( "***************************" )();
	  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();

	  	//comincia la proof of work
	  	proofOfWork;

	  	while( boolean == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	  		proofOfWork
	  	}
	  	;

				println@Console( "--------------------------------------" )();
				println@Console( "           FERMAT VALIDATO        " )();
				println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
				println@Console( "								 42							")();
				println@Console( "--------------------------------------" )();

				endPOW@TIMESTAMP("nodo3")(risposta);
	  		[endCritics(answNode1)];
				println@Console( "")();
		  	println@Console( "Il vincitore e': " + answNode1 )();
				println@Console( "")();
	  		[endCritics(answNode2)];
	  		[endCritics(answNode3)];
	  		[endCritics(answNode4)];

	  		if( answNode1 == "nodo3" ) {

	  		  //popola la dificolta del blocco
	  			blocco2.difficulty = difficult;
	  			blocco2.lunghezzaCatena = chainLength;
	  			nodo3.jollarNumb = nodo3.jollarNumb + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo3.jollarNumb +" jollar" )();
	  			println@Console( "" )();

	  			//aggiorna la blockchain
	  			newBlockChain.block[2].id_block =blocco2.id_block;
				newBlockChain.block[2].hashBlock =blocco2.hashBlock;
				newBlockChain.block[2].previousBlockHash =blocco2.previousBlockHash;
				newBlockChain.block[2].difficulty =blocco2.difficulty;
				newBlockChain.block[2].lunghezzaCatena = blocco2.lunghezzaCatena;

				//dati relativi alla transazione
				newBlockChain.block[2].transaction.hash_transaction=blocco2.transaction.hash_transaction;
				newBlockChain.block[2].transaction.nodeSeller=blocco2.transaction.nodeSeller;
				newBlockChain.block[2].transaction.nodeBuyer=blocco2.transaction.nodeBuyer;
				newBlockChain.block[2].transaction.jollar=blocco2.transaction.jollar;
				newBlockChain.block[2].transaction.timestamp=blocco2.transaction.timestamp;
	  			sendBlockChain@TIMESTAMP(newBlockChain)
	  		}else {
	  			sleep@Time(1000)();
					println@Console( "" )();
		  		println@Console( "Qualcun'altro ha gia' vinto il passaggio." )();
		  		println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo
	  		//la proof of work effettuata dai nodi
	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[sendBlockChain(newBlockChain)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();

	  		//aspetta di ricevere la transazione tra il nodo 1 e il nodo4 per la creazione
	  		//del blocco numero 3
	  		[newBlock(transazioneRicevuta)(risposta)
 	{
 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo3"
 	}];

 	//crea il blocco con i dati ricevuti
			 	blocco3.id_block=3;
				//codice per generare hash blocco random
				random@Math()(a);
				b = string(a);
				md5@MessageDigest(b)(hashBlocco);
				blocco3.hashBlock = hashBlocco ;
				//hash blocco precedente (genesis block)
				blocco3.previousBlockHash = newBlockChain.block[2].hashBlock;

				//inserisce i dati della transazione nel blocco
				blocco3.transaction.hash_transaction = transazioneRicevuta.hash_transaction;
				blocco3.transaction.nodeSeller = transazioneRicevuta.nodeSeller;
				blocco3.transaction.nodeBuyer = transazioneRicevuta.nodeBuyer;
				blocco3.transaction.jollar = transazioneRicevuta.jollar;
				blocco3.transaction.timestamp = transazioneRicevuta.timestamp;

		[startPOW(startPOWnodo)];
		println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
	  	println@Console( "*************************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
	  	println@Console( "*********************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
	  	println@Console( "***************************" )();
	  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();
	  	//comincia la proof of work
	  	proofOfWork;

	  	while( boolean == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	  		proofOfWork
	  	}
	  	;

				println@Console( "--------------------------------------" )();
				println@Console( "           FERMAT VALIDATO        " )();
				println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
				println@Console( "								 42							")();
				println@Console( "--------------------------------------" )();

	  		endPOW@TIMESTAMP("nodo3")(risposta);
	  		[endCritics(answNode1)];
				println@Console( "")();
				println@Console( "Il vincitore e': " + answNode1 )();
				println@Console( "")();
	  		[endCritics(answNode2)];
	  		[endCritics(answNode3)];
	  		[endCritics(answNode4)];

	  		if( answNode1 == "nodo3" ) {

	  		  //popola la dificolta del blocco
	  			blocco3.difficulty = difficult;
	  			blocco3.lunghezzaCatena = chainLength;
	  			nodo3.jollarNumb = nodo3.jollarNumb + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo3.jollarNumb +" jollar" )();
	  			println@Console( "" )();

	  			//aggiorna la blockchain
	  			newBlockChain.block[3].id_block =blocco3.id_block;
				newBlockChain.block[3].hashBlock =blocco3.hashBlock;
				newBlockChain.block[3].previousBlockHash =blocco3.previousBlockHash;
				newBlockChain.block[3].difficulty =blocco3.difficulty;
				newBlockChain.block[3].lunghezzaCatena = blocco3.lunghezzaCatena;

				//dati relativi alla transazione
				newBlockChain.block[3].transaction.hash_transaction=blocco3.transaction.hash_transaction;
				newBlockChain.block[3].transaction.nodeSeller=blocco3.transaction.nodeSeller;
				newBlockChain.block[3].transaction.nodeBuyer=blocco3.transaction.nodeBuyer;
				newBlockChain.block[3].transaction.jollar=blocco3.transaction.jollar;
				newBlockChain.block[3].transaction.timestamp=blocco3.transaction.timestamp;
	  			sendBlockChain@TIMESTAMP(newBlockChain)
	  		}else {
	  			sleep@Time(1000)();
					println@Console( "" )();
		  		println@Console( "Qualcun'altro ha gia' vinto il passaggio." )();
		  		println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo
	  		//la proof of work effettuata dai nodi
	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[sendBlockChain(newBlockChain)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();
	  		println@Console( "***********************************" )();
			println@Console( "ADDIO E GRAZIE PER TUTTO IL PESCE!" )();
			println@Console( "***********************************" )();

	  		jollarNumbNodo3@TIMESTAMP(nodo3.jollarNumb)

} // main
