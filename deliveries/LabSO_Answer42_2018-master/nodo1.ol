include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"
include "POW.ol"


//porta input
inputPort NODO1 {
	Location: "socket://localhost:8001"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo2
outputPort NODO2 {
	Location: "socket://localhost:8002"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo3
outputPort NODO3 {
	Location: "socket://localhost:8003"
	Protocol: sodep
	Interfaces:BlockchainInterface
}
//nodo4
outputPort NODO4 {
	Location: "socket://localhost:8004"
	Protocol: sodep
	Interfaces:BlockchainInterface
}

//timestamp
outputPort TIMESTAMP {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces:BlockchainInterface
}

// Metodo creazione blocco genesis

define genesisBlock
{
	genesisBlock.id_block_G = 0;
	md5@MessageDigest("hashBloccoGenesis")(hashGenesis);
	genesisBlock.hashBlock_G = hashGenesis;
	genesisBlock.previousBlockHash_G= "0";
	genesisBlock.difficulty_G = 2;

	if( genesisBlock.id_block_G == 0 && genesisBlock.difficulty_G == 2) { // difficoltà decisa dall'utente per blocco genesis
	  println@Console( "*____________________________________________________" )();
	  println@Console( "Blocco Genesi creato e autorizzato dal lord dei Vogon." )();
	  println@Console( "*____________________________________________________*" )()
	};
	println@Console( "******************************************" )();
	println@Console( "Attendo l'arrivo di altri autostoppisti..." )();
	println@Console( "******************************************" )();
	[connect(okConesso_nodo2)];
	println@Console( "nodo2 ha chiesto un passaggio e ora e' connesso alla rete" )();
	println@Console( "*____________________________________*" )();
	[connect(okConesso_nodo3)];
	println@Console( "nodo3 ha chiesto un passaggio e ora e' connesso alla rete" )();
	println@Console( "*____________________________________*" )();
	[connect(okConesso_nodo4)];
	println@Console( "nodo4 ha chiesto un passaggio e ora e' connesso alla rete" )();
	println@Console( "*____________________________________*" )();

	println@Console( "Si ricorda a tutti gli autostoppisti:" )();
	println@Console( "1) Sono concesse un massimo di tre transazioni." )();
	println@Console( "2) Sara' possibile visualizzare lo stato delle transazioni nel networkVisualizer." )();
	println@Console( "3) E' severamente vietato inviare jollar a vuoto." )();
	println@Console( "4) E' severamente vietato incitare i Vogon a recitare poesie." )();

	//popola la blockchain con il genesis block
	blockchain.block.id_block_G = genesisBlock.id_block_G;
	blockchain.block.hashBlock_G = genesisBlock.hashBlock_G;
	blockchain.block.previousBlockHash_G = genesisBlock.previousBlockHash_G;
	blockchain.block.difficulty_G = genesisBlock.difficulty_G;

	//servizio che manda parallelamente a tutti i nodi la blockchain
	{
			sendBlockChain@NODO2(blockchain)
	  	 	|
	  	 	sendBlockChain@NODO3(blockchain)
	  	 	|
	  	 	sendBlockChain@NODO4(blockchain)
	}
}

init
{
  md5@MessageDigest("nodo1")(rispostaHashSegreto);
	md5@MessageDigest("hashnodo1")(rispostaHashPubblico);
	nodo1.publicKey = rispostaHashPubblico;
	nodo1.privateKey = rispostaHashSegreto;
	nodo1.jollarNumb = 6;
	nodo1.id_node = "nodo1";
	// nodo1.exists = true;
	println@Console( "*****************************************************" )();
	println@Console( "Benvenuto nel primo nodo autostoppista" )();
	println@Console( "*****************************************************" )();
	sleep@Time(300)();
	println@Console( "La confederazione VOGON ti augura un buon guadagno" )();
	println@Console( "*****************************************************" )();
	sleep@Time(300)();
	println@Console( "Ho creato il nodo: " + nodo1.id_node )();
	println@Console( "Chiave pubblica nodo: " + nodo1.publicKey )();
	println@Console( "Numero di jollar: " + nodo1.jollarNumb )();

	//manda i dati del nodo al server timestamp per richiesta networkVisualizer
	infoNode1@TIMESTAMP(nodo1);

	genesisBlock
}

main
{
	registerForInput@Console()();
	println@Console( "*_______________________________________*" )();
	println@Console( "Vuoi effettuare una transazione ? Y/N" )(); // yes or not
	println@Console( "*_______________________________________*" )();
	in( cho );

	if( cho == "Y" || cho =="y") {
	  	if( nodo1.jollarNumb > 0 ) {
				println@Console( "Nel tuo portafoglio ci sono: " + nodo1.jollarNumb + "Jollar")();
	  	  node="nodo2";
	  	  jol = 1;

	  	  // nuova transazione
	  	  // popolo i dati della nuova transazione
	  	  md5@MessageDigest("primaTransazione")(rispostaPrimaTransazioneHash);
	  	  newTransaction.hash_transaction = rispostaPrimaTransazioneHash;
	  	  newTransaction.nodeSeller = nodo1.id_node;
	  	  newTransaction.nodeBuyer = node;
	  	  newTransaction.jollar = jol;

	  	  //timestamp
	  	  serverTimestamp@TIMESTAMP("transazione1")(dataTransazione1);
	  	  newTransaction.timestamp=dataTransazione1;
	  	  newTransaction@NODO2(newTransaction)(risposta2PrimaTransazione);
	  	  // println@Console( risposta2PrimaTransazione )();
	  	  // aggiorno il numero di jollar
	  	  nodo1.jollarNumb = nodo1.jollarNumb - risposta2PrimaTransazione;
	  	  println@Console( "Transazione completata!" )();
	  	  println@Console( "I tuo portafoglio ora ha: " + nodo1.jollarNumb + " jollar.")();
	  	  println@Console( "" )();

		  println@Console( "*_____________________________________*" )();
	  	  println@Console( "Aggiorno gli altri autostoppisti(nodi)" )();
	  	  println@Console( "*_____________________________________*" )();
	  	  //manda in broadcast l'hash del blocco genesis a tutti i nodi
	  	  {
	  	 	sendGenesisBlock@NODO2(genesisBlock.hashBlock_G)
	  	 	|
	  	 	sendGenesisBlock@NODO3(genesisBlock.hashBlock_G)
	  	 	|
	  	 	sendGenesisBlock@NODO4(genesisBlock.hashBlock_G)
	  	  };

				 println@Console("Inizia la gara!")();

		  {
	  	  // manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
	  	  newBlock@NODO2(newTransaction)(risposta);
	  	  println@Console( risposta )()
	 	  |
	  	  newBlock@NODO3(newTransaction)(risposta);
	  	  println@Console( risposta )()
	  	  |
	  	  newBlock@NODO4(newTransaction)(risposta);
	  	  println@Console( risposta )()
	  	  };

	  	/*
	  	    Crea un nuovo blocco con i dati della transazione
	  	 */
	  	blocco1.id_block=1;
	  	 //codice per generare hash blocco random
	  	random@Math()(a);
		b = string(a);
		md5@MessageDigest(b)(hashBlocco);
	  	blocco1.hashBlock = hashBlocco ;

	  	//hash blocco precedente (genesis block)
	  	blocco1.previousBlockHash = genesisBlock.hashBlock_G;

	  	//inserisce i dati della transazione nel blocco
	  	blocco1.transaction.hash_transaction = newTransaction.hash_transaction;
	  	blocco1.transaction.nodeSeller = newTransaction.nodeSeller;
	  	blocco1.transaction.nodeBuyer = newTransaction.nodeBuyer;
	  	blocco1.transaction.jollar = newTransaction.jollar;
	  	blocco1.transaction.timestamp = newTransaction.timestamp;

	  	//fa iniziare la POW a tutti i nodi in parallelo
	  	{
	  		startPOW@NODO2("start")
	  	 	|
	  	 	startPOW@NODO3("start")
	  	 	|
	  	 	startPOW@NODO4("start")
	  	};

	  	/*
			INIZIO PROOF OF WORK
	  	*/
		println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
	  	println@Console( "*************************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
	  	println@Console( "*********************************" )();
	  	sleep@Time(500)();
	  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
	  	println@Console( "***************************" )();
	  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();

	  	proofOfWork;
	  	//boolean == false quando fermat = 0
	  	while( boolean == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();
	  		proofOfWork
	  	};

	  		println@Console( "--------------------------------------" )();
		  	println@Console( "           FERMAT VALIDATO        	" )();
			println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
			println@Console( "			      	42					")();
		  	println@Console( "--------------------------------------" )();

	 		//endPOW operation per verificare il nodo che ha finito
	 		//per primo la prood of work
	  		endPOW@TIMESTAMP("nodo1")(risposta);

	  		//risposta del nodo arrivato prima
	  		[endCritics(answNode1)];
				println@Console( "")();
	  		println@Console( "Il vincitore e': " + answNode1 )();
				println@Console( "")();
				[endCritics(answNode2)];
	  		[endCritics(answNode3)];
	  		[endCritics(answNode4)];

	  		/*
	  		se il nodo che ha finito per prima è lui stesso allora
	  		aggiorna la blockchain, inserisce il blocco e manda la blockchain
	  		al server timestamp
	  		 */
	  		if( answNode1 == "nodo1" ) {
	  		  //popola la dificolta del blocco
	  			blocco1.difficulty = difficult;
	  			blocco1.lunghezzaCatena = chainLength;

	  			//reward di 6 jollar, aggiorna il numero jollar del nodo
	  			nodo1.jollarNumb = nodo1.jollarNumb + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo1.jollarNumb +" jollar" )();
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
				//invia la blockchain aggiornata al server timestamp
				sendBlockChain@TIMESTAMP(blockchain)

	  		} else {
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

		   	//Seconda transazione
	  	  	println@Console( "Vuoi effettuare una nuova transazione? Y/N" )();
	  	 	// seconda transazione nodo1 - nodo3
	  	  	in( cho2 );
	  	  	if( cho2 == "Y" || cho2 =="y" ) {
	  	    	if( nodo1.jollarNumb > 0 ) {
							println@Console( "Hai a disposizione " + nodo1.jollarNumb + " Jollar da trasferire")();

		  	  		node2 = "nodo3";
		  	  		jol2 = 2;
		  	  		// seconda transazione
		  	  		md5@MessageDigest("secondaTransazione")(rispostaSecondaTransazioneHash);
		  	  		newTransaction2.hash_transaction = rispostaSecondaTransazioneHash;
		  	  		newTransaction2.nodeSeller = nodo1.id_node;
		  	  		newTransaction2.nodeBuyer = node2;
		  	  		newTransaction2.jollar = jol2;

		  	  		//timestamp
			  	    serverTimestamp@TIMESTAMP("transazione2")(dataTransazione2);
			  	    newTransaction2.timestamp=dataTransazione2;

			  	  	//effettua transazione, manda transazione a nodo3
		  	  		newTransaction@NODO3(newTransaction2)(risposta2SecondaTransazione);
		  	  		//aggiorna numero jollar
		  	  		nodo1.jollarNumb = nodo1.jollarNumb - risposta2SecondaTransazione;
		  	  		println@Console( "" )();
		  	  		println@Console( "Transazione andata a buon fine!" )();
				  		println@Console( "I tuoi jollar totali ora sono: " + nodo1.jollarNumb)();
				  		println@Console( "" )();

					{
				  	// manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
				  	newBlock@NODO2(newTransaction2)(risposta);
				  	println@Console( risposta )()
				 	|
				  	newBlock@NODO3(newTransaction2)(risposta);
				  	println@Console( risposta )()
				  	|
				  	newBlock@NODO4(newTransaction2)(risposta);
				  	println@Console( risposta )()
				  	};

	  	 		//Crea un nuovo blocco con i dati della transazione
			  	blocco2.id_block=2;
			  	 //codice per generare hash blocco random
			  	random@Math()(a);
				b = string(a);
				md5@MessageDigest(b)(hashBlocco);
			  	blocco2.hashBlock = hashBlocco ;

			  	//hash blocco precedente (genesis block)
			  	blocco2.previousBlockHash = newBlockChain.block[1].hashBlock;

			  	//inserisce i dati della transazione nel blocco
			  	blocco2.transaction.hash_transaction = newTransaction2.hash_transaction;
			  	blocco2.transaction.nodeSeller = newTransaction2.nodeSeller;
			  	blocco2.transaction.nodeBuyer = newTransaction2.nodeBuyer;
			  	blocco2.transaction.jollar = newTransaction2.jollar;
			  	blocco2.transaction.timestamp = newTransaction2.timestamp;

			  	//fa iniziare la POW a tutti i nodi in parallelo
			  	{
			  		startPOW@NODO2("start")
			  	 	|
			  	 	startPOW@NODO3("start")
			  	 	|
			  	 	startPOW@NODO4("start")
			  	};
			  	/*
					INIZIO PROOF OF WORK
			  	*/
				println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
	  			println@Console( "*************************************" )();
			  	sleep@Time(500)();
			  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
			  	println@Console( "*********************************" )();
			  	sleep@Time(500)();
			  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
			  	println@Console( "***************************" )();
			  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();


			  	proofOfWork;

		  		//boolean == false quando fermat = 0
		  		while( boolean == false ) {
		  		println@Console( "--------------------------------------" )();
		  		println@Console( "         NON CAPISCO LA DOMANDA       " )();
		  		println@Console( "--------------------------------------" )();

		  		proofOfWork
		  		};

				println@Console( "--------------------------------------" )();
		  		println@Console( "           FERMAT VALIDATO        	" )();
				println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
				println@Console( "			      	42					")();
		  		println@Console( "--------------------------------------" )();

		 		//endPOW operation per verificare il nodo che ha finito
		 		//per primo la prood of work
		  		endPOW@TIMESTAMP("nodo1")(risposta);
		  		//risposta del nodo arrivato prima
		  		[endCritics(answNode1)];
					println@Console( "")();
		  		println@Console( "Il vincitore e': " + answNode1 )();
					println@Console( "")();
					[endCritics(answNode2)];
		  		[endCritics(answNode3)];
		  		[endCritics(answNode4)];

		  		/*
		  		se il nodo che ha finito per prima è lui stesso allora
		  		aggiorna la blockchain, inserisce il blocco e manda la blockchain
		  		al server timestamp
		  		 */
		  		if( answNode1 == "nodo1" ) {
		  		  //popola la dificolta del blocco
		  			blocco2.difficulty = difficult;
		  			blocco2.lunghezzaCatena = chainLength;

		  			//reward di 6 jollar, aggiorna il numero jollar del nodo
		  			nodo1.jollarNumb = nodo1.jollarNumb + 6;
		  			println@Console( "" )();
		  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
		  			println@Console( "Hai ricevuto 6 jollar" )();
		  			println@Console( "Ora hai: "+ nodo1.jollarNumb +" jollar" )();
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
					//invia la blockchain aggiornata al server timestamp
					sendBlockChain@TIMESTAMP(newBlockChain)

		  		} else {
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

	  			//Transazione tra il nodo 1 e il nodo 4
	  	  		println@Console( "Vuoi effettuare l'ultima transazione? Y/N" )();
	  	  		// terza transazione nodo1 - nodo4
	  	  		in( cho3 );

			  	  if( cho3 == "Y" || cho3 =="y" ) {
			  	    if( nodo1.jollarNumb > 0 ) {
								println@Console( "Hai a disposizione " + nodo1.jollarNumb + " Jollar da trasferire")();

			  	  		node3 = "nodo4";
			  	  		jol3 = 3;
			  	  		// seconda transazione
			  	  		md5@MessageDigest("terzaTransazione")(rispostaTerzaTransazioneHash);
			  	  		newTransaction3.hash_transaction = rispostaTerzaTransazioneHash;
			  	  		newTransaction3.nodeSeller = nodo1.id_node;
			  	  		newTransaction3.nodeBuyer = node3;
			  	  		newTransaction3.jollar = jol3;

				  	  	//timestamp
					  	serverTimestamp@TIMESTAMP("transazione3")(dataTransazione3);
					  	newTransaction3.timestamp=dataTransazione3;

			  	  		newTransaction@NODO4(newTransaction3)(risposta2TerzaTransazione);
			  	  		nodo1.jollarNumb = nodo1.jollarNumb - risposta2TerzaTransazione;

				  	  	println@Console( "" )();
			  	  		println@Console( "Transazione andata a buon fine!" )();
					  		println@Console( "I tuoi jollar ora sono: " + nodo1.jollarNumb)();
					  		println@Console( "" )();

						{
					  	  // manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
					  	newBlock@NODO2(newTransaction3)(risposta);
					  	println@Console( risposta )()
					 	|
					  	newBlock@NODO3(newTransaction3)(risposta);
					  	println@Console( risposta )()
					    |
					  	newBlock@NODO4(newTransaction3)(risposta);
					  	println@Console( risposta )()
					  	};

					  	//Crea un nuovo blocco con i dati della transazione
					  	blocco3.id_block=3;
					  	 //codice per generare hash blocco random
					  	random@Math()(a);
						b = string(a);
						md5@MessageDigest(b)(hashBlocco);
					  	blocco3.hashBlock = hashBlocco ;

					  	//hash blocco precedente (genesis block)
					  	blocco3.previousBlockHash = newBlockChain.block[2].hashBlock;

					  	//inserisce i dati della transazione nel blocco
					  	blocco3.transaction.hash_transaction = newTransaction3.hash_transaction;
					  	blocco3.transaction.nodeSeller = newTransaction3.nodeSeller;
					  	blocco3.transaction.nodeBuyer = newTransaction3.nodeBuyer;
					  	blocco3.transaction.jollar = newTransaction3.jollar;
					  	blocco3.transaction.timestamp = newTransaction3.timestamp;

					  	//fa iniziare la POW a tutti i nodi in parallelo
					  	{
					  		startPOW@NODO2("start")
					  	 	|
					  	 	startPOW@NODO3("start")
					  	 	|
					  	 	startPOW@NODO4("start")
					  	};

					  	/*
							INIZIO PROOF OF WORK

					  	*/
						println@Console( "ATTENZIONE LA GARA STA PER COMINCIARE" )();
					  	println@Console( "*************************************" )();
					  	sleep@Time(500)();
					  	println@Console( "CALCOLO LA DOMANDA FONAMENTALE..." )();
					  	println@Console( "*********************************" )();
					  	sleep@Time(500)();
					  	println@Console( "CALCOLO L'INCALCOLABILE..." )();
					  	println@Console( "***************************" )();
					  	println@Console( "RISOLVO L'IRRISOLVIBILE..." )();

					  	proofOfWork;
					  	//boolean == false quando fermat = 0
					  	while( boolean == false ) {
					  		println@Console( "--------------------------------------" )();
					  		println@Console( "           FERMAT NON VALIDATO        " )();
					  		println@Console( "--------------------------------------" )();

					  		proofOfWork
					  	};

							println@Console( "--------------------------------------" )();
		  					println@Console( "           FERMAT VALIDATO        	" )();
							println@Console( "LA RISPOSTA ALLA DOMANDA FONDAMENTALE E'")();
							println@Console( "			      	42					")();
		  					println@Console( "--------------------------------------" )();

					 		//endPOW operation per verificare il nodo che ha finito
					 		//per primo la prood of work
					  		endPOW@TIMESTAMP("nodo1")(risposta);
					  		//risposta del nodo arrivato prima
					  		[endCritics(answNode1)];
								println@Console( "")();
					  		println@Console( "Il vincitore e': " + answNode1 )();
								println@Console( "")();
								[endCritics(answNode2)];
					  		[endCritics(answNode3)];
					  		[endCritics(answNode4)];

					  		/*
					  		se il nodo che ha finito per prima è lui stesso allora
					  		aggiorna la blockchain, inserisce il blocco e manda la blockchain
					  		al server timestamp
					  		 */
					  		if( answNode1 == "nodo1" ) {
					  		  //popola la dificolta del blocco
					  			blocco3.difficulty = difficult;
					  			blocco3.lunghezzaCatena = chainLength;

					  			//reward di 6 jollar, aggiorna il numero jollar del nodo
					  			nodo1.jollarNumb = nodo1.jollarNumb + 6;
					  			println@Console( "" )();
					  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
					  			println@Console( "Hai ricevuto 6 jollar" )();
					  			println@Console( "Ora hai: "+ nodo1.jollarNumb +" jollar" )();
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
								//invia la blockchain aggiornata al server timestamp
								sendBlockChain@TIMESTAMP(newBlockChain)

						  		} else {
						  			sleep@Time(1000)();
									println@Console( "****************************************" )();
						  			println@Console( "Qualcun'altro ha gia' vinto il passaggio." )();
						  			println@Console( "****************************************" )()
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

					  			jollarNumbNodo1@TIMESTAMP(nodo1.jollarNumb)

					  	 		}
					  		}
					    }//fine if
					}//fine if
				}
			}
			else {
			println@Console( "Non e' possibile effettuare la tua prima transazione." )()
		}
	}
