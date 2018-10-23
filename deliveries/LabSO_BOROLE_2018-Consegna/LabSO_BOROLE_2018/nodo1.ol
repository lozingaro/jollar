include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"



// porte Input

inputPort PP1 {
	Location: "socket://localhost:8000"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

inputPort PP7 {
	Location: "socket://localhost:8060"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

inputPort PP8 {
	Location: "socket://localhost:8070"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

// porte Output

outputPort PP6 {
	Location: "socket://localhost:8050"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

outputPort PP10 {
	Location: "socket://localhost:8090"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

outputPort PP11 {
	Location: "socket://localhost:9000"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}

//porta per il timestamp

outputPort PP13 {
	Location: "socket://localhost:9020"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}

//porta per comunicare con timestamp da server

inputPort PP14 {
	Location: "socket://localhost:9030"
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
	  println@Console( "-------------------------" )();	
	  println@Console( "Ho creato il genesis block!" )();
	  println@Console( "-------------------------" )()
	};

	// timestamp = data
	
	println@Console( "Attendo la connessione di tutti i nodi..." )();
	[nodoConnesso(okConesso_nodo2)];
	println@Console( "nodo2 connesso alla rete: ha scaricato la blockchain" )();
	[nodoConnesso(okConesso_nodo3)];
	println@Console( "nodo3 connesso alla rete: ha scaricato la blockchain" )();
	[nodoConnesso(okConesso_nodo4)];
	println@Console( "nodo4 connesso alla rete: ha scaricato la blockchain" )();
	
	//popola la blockchain con il genesis block
	blockchain.block.id_block_G = genesisBlock.id_block_G;
	blockchain.block.hashBlock_G = genesisBlock.hashBlock_G;
	blockchain.block.previousBlockHash_G = genesisBlock.previousBlockHash_G;
	blockchain.block.difficulty_G = genesisBlock.difficulty_G;

	//servizio che manda parallelamente a tutti i nodi la blockchain
	{
			invioBlockchain@PP6(blockchain)
	  	 	|
	  	 	invioBlockchain@PP10(blockchain)
	  	 	|
	  	 	invioBlockchain@PP11(blockchain)
	}
}

// Da eseguire ancor prima del main

init
{
  	md5@MessageDigest("nodo1")(rispostaHashSegreto);
	md5@MessageDigest("hashnodo1")(rispostaHashPubblico);
	nodo1.publicKey = rispostaHashPubblico;
	nodo1.privateKey = rispostaHashSegreto;
	nodo1.numeroJollar = 6;
	nodo1.id_node = "nodo1";
	// nodo1.exists = true;
	println@Console( "Ho creato il nodo: " + nodo1.id_node )();
	println@Console( "Chiave pubblica nodo: " + nodo1.publicKey )();
	println@Console( "Numero di jollar: " + nodo1.numeroJollar )();

	//manda i dati del nodo al server timestamp per richiesta networkVisualizer
	informazioniNodo1@PP13(nodo1);
	
	genesisBlock	
}



main
{
	registerForInput@Console()();
	println@Console( "" )();
	println@Console( "Vuoi effettuare una transazione ? Y/N" )(); // yes or not
	println@Console( "" )();
	in( newTransaction );

	if( newTransaction == "Y" || newTransaction =="y") {
	  	if( nodo1.numeroJollar > 0 ) {
	  	  println@Console( "Hai a disposizione " + nodo1.numeroJollar + " Jollar da trasferire")();
	  	  println@Console( "A chi vuoi inviare i Jollar ?" )();
	  	  in( nodoScelta );
	  	  println@Console( "Quanti Jollar vuoi trasferire ?" )();
	  	  in( jollarDaTrasferire );
	  	  jollarINT = int( jollarDaTrasferire );

	  	  // nuova transazione
	  	  // popolo i dati della nuova transazione

	  	  md5@MessageDigest("primaTransazione")(rispostaPrimaTransazioneHash);
	  	  nuovaTransazione.hash_transaction = rispostaPrimaTransazioneHash;
	  	  nuovaTransazione.nodeSeller = nodo1.id_node;
	  	  nuovaTransazione.nodeBuyer = nodoScelta;
	  	  nuovaTransazione.jollar = jollarINT;

	  	  //timestamp
	  	  serverTimestamp@PP13("transazione1")(dataTransazione1);
	  	  nuovaTransazione.timestamp=dataTransazione1;
	  	  nuovaTransazione@PP6(nuovaTransazione)(risposta2PrimaTransazione);
	  	  // println@Console( risposta2PrimaTransazione )();
	  	  // aggiorno il numero di jollar
	  	  nodo1.numeroJollar = nodo1.numeroJollar - risposta2PrimaTransazione;
	  	  println@Console( "Transazione effettuata!" )();
	  	  println@Console( "I tuoi jollar ora sono: " + nodo1.numeroJollar)();
	  	  println@Console( "" )();

	  	  //manda in broadcast l'hash del blocco genesis a tutti i nodi 
	  	  {
	  	 	invioHashBloccoGenesis@PP6(genesisBlock.hashBlock_G)
	  	 	|
	  	 	invioHashBloccoGenesis@PP10(genesisBlock.hashBlock_G)
	  	 	|
	  	 	invioHashBloccoGenesis@PP11(genesisBlock.hashBlock_G)
	  	  };

		  {
	  	  // manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
	  	  creaBloccoDopoTransazione@PP6(nuovaTransazione)(risposta);
	  	  println@Console( risposta )()
	 	  |
	  	  creaBloccoDopoTransazione@PP10(nuovaTransazione)(risposta);
	  	  println@Console( risposta )()
	  	  |
	  	  creaBloccoDopoTransazione@PP11(nuovaTransazione)(risposta);
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
	  	blocco1.transaction.hash_transaction = nuovaTransazione.hash_transaction;
	  	blocco1.transaction.nodeSeller = nuovaTransazione.nodeSeller;
	  	blocco1.transaction.nodeBuyer = nuovaTransazione.nodeBuyer;
	  	blocco1.transaction.jollar = nuovaTransazione.jollar;
	  	blocco1.transaction.timestamp = nuovaTransazione.timestamp;

	  	//fa iniziare la POW a tutti i nodi in parallelo
	  	{
	  		inizioPOW@PP6("start")
	  	 	|
	  	 	inizioPOW@PP10("start")
	  	 	|
	  	 	inizioPOW@PP11("start")
	  	};

	  	/*
			INIZIO PROOF OF WORK
	  	*/

	  	println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	proofOfWork;
	  	//controllo == false quando fermat = 0
	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();
	  		proofOfWork
	  	};

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	 		
	 		//finePOW operation per verificare il nodo che ha finito
	 		//per primo la prood of work 	

	  		finePOW@PP13("nodo1")(risposta);
	  		
	  		//risposta del nodo arrivato prima
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concluso la POW: " + rispostaNodoArrivatoPrima )();
			[fineSemaforo(rispostaNodoArrivato2)];
	  		[fineSemaforo(rispostaNodoArrivato3)];
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  		
	  		
	  		/*
	  		se il nodo che ha finito per prima è lui stesso allora 
	  		aggiorna la blockchain, inserisce il blocco e manda la blockchain 
	  		al server timestamp
	  		 */

	  		if( rispostaNodoArrivatoPrima == "nodo1" ) {
	  		  //popola la dificolta del blocco
	  			blocco1.difficulty = difficolta;
	  			blocco1.lunghezzaCatena = lunghezzaCatenaPOW;
	  			
	  			//reward di 6 jollar, aggiorna il numero jollar del nodo
	  			nodo1.numeroJollar = nodo1.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo1.numeroJollar +" jollar" )();
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
				invioBlockchain@PP13(blockchain)

	  		} else {
	  			sleep@Time(1000)();
	  			println@Console( "" )();
	  			println@Console( "Non sei stato il nodo piu' veloce!!" )();
	  			println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo 
	  		//la proof of work effettuata dai nodi

	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[blockchainAttuale(blockchainAttuale)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();

	  	 /*
	  	 
			Seconda transazione

	  	  */


	  	  println@Console( "Vuoi effettuare una nuova transazione? Y/N" )();
	  	  // seconda transazione nodo1 - nodo3
	  	  in( newTransaction2 );
	  	
	  	  if( newTransaction2 == "Y" || newTransaction2 =="y" ) {
	  	  
	  	    if( nodo1.numeroJollar > 0 ) {
	  	        println@Console( "Hai a disposizione " + nodo1.numeroJollar + " Jollar da trasferire")();
	  	  		println@Console( "A chi vuoi inviare i Jollar ?" )();
	  	  		in( nodoScelta2 );
	  	  		println@Console( "" )();
	  	  		println@Console( "Quanti Jollar vuoi trasferire ?" )();
	  	  		in( jollarDaTrasferire2 );
	  	  		jollarINT2 = int(jollarDaTrasferire2);
	  	  		// seconda transazione
	  	  		md5@MessageDigest("secondaTransazione")(rispostaSecondaTransazioneHash);
	  	  		nuovaTransazione2.hash_transaction = rispostaSecondaTransazioneHash;
	  	  		nuovaTransazione2.nodeSeller = nodo1.id_node;
	  	  		nuovaTransazione2.nodeBuyer = nodoScelta2;
	  	  		nuovaTransazione2.jollar = jollarINT2;


	  	  		//timestamp
		  	    serverTimestamp@PP13("transazione2")(dataTransazione2);
		  	    nuovaTransazione2.timestamp=dataTransazione2;
		  	  
		  	  	//effettua transazione, manda transazione a nodo3
	  	  		nuovaTransazione@PP10(nuovaTransazione2)(risposta2SecondaTransazione);
	  	  		//aggiorna numero jollar
	  	  		nodo1.numeroJollar = nodo1.numeroJollar - risposta2SecondaTransazione;
	  	  		println@Console( "" )();
	  	  		println@Console( "Transazione effettuata!" )();
			  	println@Console( "I tuoi jollar ora sono: " + nodo1.numeroJollar)();
			  	println@Console( "" )();
			  	  	

			  {
		  	  // manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
		  	  creaBloccoDopoTransazione@PP6(nuovaTransazione2)(risposta);
		  	  println@Console( risposta )()
		 	  |
		  	  creaBloccoDopoTransazione@PP10(nuovaTransazione2)(risposta);
		  	  println@Console( risposta )()
		  	  |
		  	  creaBloccoDopoTransazione@PP11(nuovaTransazione2)(risposta);
		  	  println@Console( risposta )()
		  	  };




		  	   /*
	  	 	Crea un nuovo blocco con i dati della transazione

	  	  */
	  	blocco2.id_block=2;
	  	 //codice per generare hash blocco random
	  	random@Math()(a);
		b = string(a);
		md5@MessageDigest(b)(hashBlocco);
	  	blocco2.hashBlock = hashBlocco ;

	  	//hash blocco precedente (genesis block)
	  	blocco2.previousBlockHash = blockchainAttuale.block[1].hashBlock;
 	
	  	//inserisce i dati della transazione nel blocco
	  	blocco2.transaction.hash_transaction = nuovaTransazione2.hash_transaction;
	  	blocco2.transaction.nodeSeller = nuovaTransazione2.nodeSeller;
	  	blocco2.transaction.nodeBuyer = nuovaTransazione2.nodeBuyer;
	  	blocco2.transaction.jollar = nuovaTransazione2.jollar;
	  	blocco2.transaction.timestamp = nuovaTransazione2.timestamp;

	  	//fa iniziare la POW a tutti i nodi in parallelo
	  	{
	  		inizioPOW@PP6("start")
	  	 	|
	  	 	inizioPOW@PP10("start")
	  	 	|
	  	 	inizioPOW@PP11("start")
	  	};



	  	/*
			INIZIO PROOF OF WORK

	  	*/
	  	println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	proofOfWork;
	  	//controllo == false quando fermat = 0
	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();


	  		proofOfWork
	  	};

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	 		
	 		//finePOW operation per verificare il nodo che ha finito
	 		//per primo la prood of work 	
	  		finePOW@PP13("nodo1")(risposta);
	  		//risposta del nodo arrivato prima
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concluso la POW: " + rispostaNodoArrivatoPrima )();
			[fineSemaforo(rispostaNodoArrivato2)];
	  		[fineSemaforo(rispostaNodoArrivato3)];
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  		
	  		
	  		/*
	  		se il nodo che ha finito per prima è lui stesso allora 
	  		aggiorna la blockchain, inserisce il blocco e manda la blockchain 
	  		al server timestamp
	  		 */

	  		if( rispostaNodoArrivatoPrima == "nodo1" ) {
	  		  //popola la dificolta del blocco
	  			blocco2.difficulty = difficolta;
	  			blocco2.lunghezzaCatena = lunghezzaCatenaPOW;
	  			
	  			//reward di 6 jollar, aggiorna il numero jollar del nodo
	  			nodo1.numeroJollar = nodo1.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo1.numeroJollar +" jollar" )();
	  			println@Console( "" )();

	  			//aggiorna la blockchain
	  			
	  			blockchainAttuale.block[2].id_block =blocco2.id_block;
				blockchainAttuale.block[2].hashBlock =blocco2.hashBlock;
				blockchainAttuale.block[2].previousBlockHash =blocco2.previousBlockHash;
				blockchainAttuale.block[2].difficulty =blocco2.difficulty;
				blockchainAttuale.block[2].lunghezzaCatena = blocco2.lunghezzaCatena;
				
				//dati relativi alla transazione

				blockchainAttuale.block[2].transaction.hash_transaction=blocco2.transaction.hash_transaction;
				blockchainAttuale.block[2].transaction.nodeSeller=blocco2.transaction.nodeSeller;
				blockchainAttuale.block[2].transaction.nodeBuyer=blocco2.transaction.nodeBuyer;
				blockchainAttuale.block[2].transaction.jollar=blocco2.transaction.jollar;
				blockchainAttuale.block[2].transaction.timestamp=blocco2.transaction.timestamp;
				//invia la blockchain aggiornata al server timestamp
				invioBlockchain@PP13(blockchainAttuale)

	  		} else {
	  			sleep@Time(1000)();
	  			println@Console( "" )();
	  			println@Console( "Non sei stato il nodo piu' veloce!!" )();
	  			println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo 
	  		//la proof of work effettuata dai nodi
	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[blockchainAttuale(blockchainAttuale)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();




	  		/*
	  			Transazione tra il nodo 1 e il nodo 4
	  		 */



	  	  		println@Console( "Vuoi effettuare l'ultima transazione? Y/N" )();
	  	  		// terza transazione nodo1 - nodo4
	  	  		in( newTransaction3 );

		  	  if( newTransaction3 == "Y" || newTransaction3 =="y" ) {
		  	    if( nodo1.numeroJollar > 0 ) {
		  	        println@Console( "Hai a disposizione " + nodo1.numeroJollar + " Jollar da trasferire")();
		  	  		println@Console( "A chi vuoi inviare i Jollar ?" )();
		  	  		in( nodoScelta3 );
		  	  		println@Console( "Quanti Jollar vuoi trasferire ?" )();
		  	  		in( jollarDaTrasferire3 );
		  	  		jollarINT3 = int(jollarDaTrasferire3);
		  	  		// seconda transazione
		  	  		md5@MessageDigest("terzaTransazione")(rispostaTerzaTransazioneHash);
		  	  		nuovaTransazione3.hash_transaction = rispostaTerzaTransazioneHash;
		  	  		nuovaTransazione3.nodeSeller = nodo1.id_node;
		  	  		nuovaTransazione3.nodeBuyer = nodoScelta3;
		  	  		nuovaTransazione3.jollar = jollarINT3;


	  	  		//timestamp
		  	  serverTimestamp@PP13("transazione3")(dataTransazione3);
		  	  nuovaTransazione3.timestamp=dataTransazione3;


		  	  		nuovaTransazione@PP11(nuovaTransazione3)(risposta2TerzaTransazione);
		  	  		nodo1.numeroJollar = nodo1.numeroJollar - risposta2TerzaTransazione;



		  	  	println@Console( "" )();
	  	  		println@Console( "Transazione effettuata!" )();
			  	println@Console( "I tuoi jollar ora sono: " + nodo1.numeroJollar)();
			  	println@Console( "" )();
			  	  	

			  {
		  	  // manda in broadcast i dati della nuova transazione effettuata a tutti i nodi
		  	  creaBloccoDopoTransazione@PP6(nuovaTransazione3)(risposta);
		  	  println@Console( risposta )()
		 	  |
		  	  creaBloccoDopoTransazione@PP10(nuovaTransazione3)(risposta);
		  	  println@Console( risposta )()
		  	  |
		  	  creaBloccoDopoTransazione@PP11(nuovaTransazione3)(risposta);
		  	  println@Console( risposta )()
		  	  };




		  	   /*
	  	 	Crea un nuovo blocco con i dati della transazione

	  	  */
	  	blocco3.id_block=3;
	  	 //codice per generare hash blocco random
	  	random@Math()(a);
		b = string(a);
		md5@MessageDigest(b)(hashBlocco);
	  	blocco3.hashBlock = hashBlocco ;

	  	//hash blocco precedente (genesis block)
	  	blocco3.previousBlockHash = blockchainAttuale.block[2].hashBlock;
 	
	  	//inserisce i dati della transazione nel blocco
	  	blocco3.transaction.hash_transaction = nuovaTransazione3.hash_transaction;
	  	blocco3.transaction.nodeSeller = nuovaTransazione3.nodeSeller;
	  	blocco3.transaction.nodeBuyer = nuovaTransazione3.nodeBuyer;
	  	blocco3.transaction.jollar = nuovaTransazione3.jollar;
	  	blocco3.transaction.timestamp = nuovaTransazione3.timestamp;

	  	//fa iniziare la POW a tutti i nodi in parallelo
	  	{
	  		inizioPOW@PP6("start")
	  	 	|
	  	 	inizioPOW@PP10("start")
	  	 	|
	  	 	inizioPOW@PP11("start")
	  	};



	  	/*
			INIZIO PROOF OF WORK

	  	*/
	  	println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	proofOfWork;
	  	//controllo == false quando fermat = 0
	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();


	  		proofOfWork
	  	};

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();

	 		
	 		//finePOW operation per verificare il nodo che ha finito
	 		//per primo la prood of work 	
	  		finePOW@PP13("nodo1")(risposta);
	  		//risposta del nodo arrivato prima
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concluso la POW: " + rispostaNodoArrivatoPrima )();
			[fineSemaforo(rispostaNodoArrivato2)];
	  		[fineSemaforo(rispostaNodoArrivato3)];
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  		
	  		
	  		/*
	  		se il nodo che ha finito per prima è lui stesso allora 
	  		aggiorna la blockchain, inserisce il blocco e manda la blockchain 
	  		al server timestamp
	  		 */

	  		if( rispostaNodoArrivatoPrima == "nodo1" ) {
	  		  //popola la dificolta del blocco
	  			blocco3.difficulty = difficolta;
	  			blocco3.lunghezzaCatena = lunghezzaCatenaPOW;
	  			
	  			//reward di 6 jollar, aggiorna il numero jollar del nodo
	  			nodo1.numeroJollar = nodo1.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo1.numeroJollar +" jollar" )();
	  			println@Console( "" )();

	  			//aggiorna la blockchain
	  			
	  			blockchainAttuale.block[3].id_block =blocco3.id_block;
				blockchainAttuale.block[3].hashBlock =blocco3.hashBlock;
				blockchainAttuale.block[3].previousBlockHash =blocco3.previousBlockHash;
				blockchainAttuale.block[3].difficulty =blocco3.difficulty;
				blockchainAttuale.block[3].lunghezzaCatena = blocco3.lunghezzaCatena;
				
				//dati relativi alla transazione

				blockchainAttuale.block[3].transaction.hash_transaction=blocco3.transaction.hash_transaction;
				blockchainAttuale.block[3].transaction.nodeSeller=blocco3.transaction.nodeSeller;
				blockchainAttuale.block[3].transaction.nodeBuyer=blocco3.transaction.nodeBuyer;
				blockchainAttuale.block[3].transaction.jollar=blocco3.transaction.jollar;
				blockchainAttuale.block[3].transaction.timestamp=blocco3.transaction.timestamp;
				//invia la blockchain aggiornata al server timestamp
				invioBlockchain@PP13(blockchainAttuale)

	  		} else {
	  			sleep@Time(1000)();
	  			println@Console( "" )();
	  			println@Console( "Non sei stato il nodo piu' veloce!!" )();
	  			println@Console( "" )()
	  		};

	  		//Effettua il download dell'attuale blockchain aggiornata dopo 
	  		//la proof of work effettuata dai nodi
	  		println@Console( "Scarico la blockchain attuale..." )();
	  		[blockchainAttuale(blockchainAttuale)];
	  		println@Console( "------Blockchain scaricata------")();
	  		println@Console( "" )();
	  		println@Console( "FINITO" )();





	  		numeroJollarNodo1@PP13(nodo1.numeroJollar)

	  	    	}
	  	    }
	  	}//fine if
	  }//fine if
	 }
	} 

	else {
		println@Console( "Non è possibile effettuare la tua prima transazione !!" )()
	}
	// println@Console( "I tuoi jollar rimanenti sono " )()*/
}







// metodo per il calcolo della proof of work
define proofOfWork{
		//calcola random un numero tra 1 e 15
		//ogni numero viene associato ad un algoritmo della proof of work
		random@Math()(numeroRandom);
	 	ciao = numeroRandom * 15 ;
	 	round@Math(ciao)(numeroAlgoritmo);


	 	//println@Console( "numero random = " + numeroAlgoritmo )();

	 	if( numeroAlgoritmo == 0 ) {
	 		//println@Console( "numero random 0 non possibile" )();
	 		controllo = false
	 	  
	 	};

	 	if( numeroAlgoritmo == 1 ) {

	 		//println@Console( "numeroAlgoritmo = 1" )();

			  for ( i = 1, i < 6, i++ ) {
					n = 2;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array1pt[i] = p
				};

				/*for ( i = 1, i < #array1pt, i++ ) {
				  println@Console( array1pt[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array1pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array1pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array1pt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	//p1 se fermat non è validato p1 è = 0
			  	//dunque origine fratto 0 risulta NaN
			  	//altrimenti ritorna la difficoltà giusta
			  	origine = array1pt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 5
			  	//println@Console( " La difficolta della catena e' " + difficolta )()


			} else if ( numeroAlgoritmo == 2 ) {

				//println@Console( "numeroAlgoritmo = 2" )();


			  for ( i = 1, i < 5, i++ ) {
					n = 509;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array2pt[i] = p
				};

				/*for ( i = 1, i < #array2pt, i++ ) {
				  println@Console( array2pt[i] )()
				};
*/





			  //convalida Fermat
			  for ( i = 1, i < #array2pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array2pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array2pt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array2pt[1];
			  	difficolta = origine / p1; //pk / R
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()


			} else if ( numeroAlgoritmo == 3 ) {

				//println@Console( "numeroAlgoritmo = 3" )();


			  for ( i = 1, i < 4, i++ ) {
					n = 11;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array3pt[i] = p
				};

				/*for ( i = 1, i < #array3pt, i++ ) {
				  println@Console( array3pt[i] )()
				};*/






			  //convalida Fermat
			  for ( i = 1, i < #array3pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array3pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array3pt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array3pt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 4 ) {

				//println@Console( "numeroAlgoritmo = 4" )();
			  for ( i = 1, i < 4, i++ ) {
					n = 41;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array4pt[i] = p
				};

				/*for ( i = 1, i < #array4pt, i++ ) {
				  println@Console( array4pt[i] )()
				};*/






			  //convalida Fermat
			  for ( i = 1, i < #array4pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array4pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array4pt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array4pt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()


			} else if ( numeroAlgoritmo == 5 ) {
				//println@Console( "numeroAlgoritmo = 5" )();

			  for ( i = 1, i < 7, i++ ) {
					n = 89;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1)+(risultato - 1));
					array5pt[i] = p
				};

				/*for ( i = 1, i < #array5pt, i++ ) {
				  println@Console( array5pt[i] )()
				};*/





			  //convalida Fermat
			  for ( i = 1, i < #array5pt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array5pt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array5pt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array5pt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 6
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 6 ) {
				//println@Console( "numeroAlgoritmo = 6" )();

			  for ( i = 1, i < 4, i++ ) {
					n = 2;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1-risultato - 1));
					array1st[i] = p
				};

				/*for ( i = 1, i < #array1st, i++ ) {
				  println@Console( array1st[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array1st, i++ ) {
			    	test.base = 2;
			    	test.exponent = array1st[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array1st[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array1st[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 7 ) {
				//println@Console( "numeroAlgoritmo = 7" )();

			  for ( i = 1, i < 4, i++ ) {
					n = 19;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1-risultato - 1));
					array2st[i] = p
				};

				/*for ( i = 1, i < #array2st, i++ ) {
				  println@Console( array2st[i] )()
				};*/



			  //convalida Fermat
			  for ( i = 1, i < #array2st, i++ ) {
			    	test.base = 2;
			    	test.exponent = array2st[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array2st[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array2st[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 8 ) {
				//println@Console( "numeroAlgoritmo = 8" )();
			  for ( i = 1, i < 4, i++ ) {
					n = 79;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1-risultato - 1));
					array3st[i] = p
				};

			/*	for ( i = 1, i < #array3st, i++ ) {
				  println@Console( array3st[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array3st, i++ ) {
			    	test.base = 2;
			    	test.exponent = array3st[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array3st[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array3st[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()



			} else if ( numeroAlgoritmo == 9 ) {
				//println@Console( "numeroAlgoritmo = 9" )();
			  for ( i = 1, i < 4, i++ ) {
					n = 331;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1-risultato - 1));
					array4st[i] = p
				};

				/*for ( i = 1, i < #array4st, i++ ) {
				  println@Console( array4st[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array4st, i++ ) {
			    	test.base = 2;
			    	test.exponent = array4st[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array4st[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array4st[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 10 ) {
				//println@Console( "numeroAlgoritmo = 10" )();
			  for ( i = 1, i < 4, i++ ) {
					n = 439;
					p1 = n;
				  	prova.base = n;
					prova.exponent = i - 1; 
					pow@Math(prova)(risultato);
					p = ((risultato * p1-risultato - 1));
					array5st[i] = p
				};

				/*for ( i = 1, i < #array5st, i++ ) {
				  println@Console( array5st[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array5st, i++ ) {
			    	test.base = 2;
			    	test.exponent = array5st[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array5st[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array5st[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 3
			  	//println@Console( " La difficolta della catena e' " + difficolta )()



			} else if ( numeroAlgoritmo == 11 ) {
				//println@Console( "numeroAlgoritmo = 11" )();

			 // primi numeri di ciascuna coppia
				array1bt[1] = 5;
				array1bt[3] = ((array1bt[1] * 2) + 1);
				// arraybt[5] = ((arraybt[3] * 2) + 1);

				// secondi numeri di ciascuna coppia
				array1bt[2] = 7;
				array1bt[4] = ((array1bt[2] * 2) - 1);

				/*for ( i = 1, i < #array1bt, i++ ) {
				  println@Console( array1bt[i] )()
				};*/



			  //convalida Fermat
			  for ( i = 1, i < #array1bt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array1bt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array1bt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array1bt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()



			} else if ( numeroAlgoritmo == 12 ) {
				//println@Console( "numeroAlgoritmo = 12" )();
			  // primi numeri di ciascuna coppia
				array2bt[1] = 23;
				array2bt[3] = ((array2bt[1] * 2) + 1);
				// arraybt[5] = ((arraybt[3] * 2) + 1);

				// secondi numeri di ciascuna coppia
				array2bt[2] = 25;
				array2bt[4] = ((array2bt[2] * 2) - 1);

				/*for ( i = 1, i < #array2bt, i++ ) {
				  println@Console( array2bt[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array2bt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array2bt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array2bt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array2bt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()


			} else if ( numeroAlgoritmo == 13 ) {
				//println@Console( "numeroAlgoritmo = 13" )();


			  // primi numeri di ciascuna coppia
				array3bt[1] = 95;
				array3bt[3] = ((array3bt[1] * 2) + 1);
				// arraybt[5] = ((arraybt[3] * 2) + 1);

				// secondi numeri di ciascuna coppia
				array3bt[2] = 97;
				array3bt[4] = ((array3bt[2] * 2) - 1);

				/*for ( i = 1, i < #array3bt, i++ ) {
				  println@Console( array3bt[i] )()
				};*/






			  //convalida Fermat
			  for ( i = 1, i < #array3bt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array3bt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array3bt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array3bt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()



			} else if ( numeroAlgoritmo == 14 ) {

				//println@Console( "numeroAlgoritmo = 14" )();


			  // primi numeri di ciascuna coppia
				array4bt[1] = 383;
				array4bt[3] = ((array4bt[1] * 2) + 1);
				// arraybt[5] = ((arraybt[3] * 2) + 1);

				// secondi numeri di ciascuna coppia
				array4bt[2] = 385;
				array4bt[4] = ((array4bt[2] * 2) - 1);

				/*for ( i = 1, i < #array4bt, i++ ) {
				  println@Console( array4bt[i] )()
				};*/



			  //convalida Fermat
			  for ( i = 1, i < #array4bt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array4bt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array4bt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array4bt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()




			} else if ( numeroAlgoritmo == 15 ) {

				//println@Console( "numeroAlgoritmo = 15" )();

			  // primi numeri di ciascuna coppia
				array5bt[1] = 1535;
				array5bt[3] = ((array5bt[1] * 2) + 1);
				// arraybt[5] = ((arraybt[3] * 2) + 1);

				// secondi numeri di ciascuna coppia
				array5bt[2] = 1537;
				array5bt[4] = ((array5bt[2] * 2) - 1);

				/*for ( i = 1, i < #array5bt, i++ ) {
				  println@Console( array5bt[i] )()
				};*/




			  //convalida Fermat
			  for ( i = 1, i < #array4bt, i++ ) {
			    	test.base = 2;
			    	test.exponent = array4bt[i] - 1;
			    	pow@Math(test)(elevo);
			    	p1 = elevo % array4bt[i];
			    	if( p1 != 1 ) {
			    	  controllo = false
			    	} else {
			    	  controllo = true
			    	}
			  	};

			  	origine = array4bt[1];
			  	difficolta = origine / p1;
			  	lunghezzaCatenaPOW = 4
			  	//println@Console( " La difficolta della catena e' " + difficolta )()



			}
			

} // metodo proof of work
















