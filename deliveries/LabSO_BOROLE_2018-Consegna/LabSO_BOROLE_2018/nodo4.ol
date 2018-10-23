include "console.iol"
include "blockchainInterface.iol"
include "math.iol"
include "message_digest.iol"
include "time.iol"




// porte Input
inputPort PP4 {
	Location: "socket://localhost:8030"
	Protocol: sodep
	Interfaces: BlockchainInterface
}


inputPort PP11 {
	Location: "socket://localhost:9000"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}


inputPort PP12 {
	Location: "socket://localhost:9010"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}



// porte Output
outputPort PP3 {
	Location: "socket://localhost:8020"
	Protocol: sodep
	Interfaces: BlockchainInterface
}


outputPort PP8 {
	Location: "socket://localhost:8070"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}


outputPort PP9 {
	Location: "socket://localhost:8080"
	Protocol: sodep 
	Interfaces:BlockchainInterface
}
//output server timestamp
outputPort PP13 {
	Location: "socket://localhost:9020"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}

//output per scaricare la blockchain in network visualizer
outputPort PP30 {
	Location: "socket://localhost:9100"
	Protocol: sodep
	Interfaces: BlockchainInterface 
}


inputPort PP17 {
	Location: "socket://localhost:9060"
	Protocol: sodep 
	Interfaces:BlockchainInterface 
}




init
{
  	md5@MessageDigest("nodo4")(rispostaHashSegreto);
	md5@MessageDigest("hashnodo4")(rispostaHashPubblico);
	nodo4.publicKey = rispostaHashPubblico;
	nodo4.privateKey = rispostaHashSegreto;
	nodo4.numeroJollar = 0;
	nodo4.id_node = "nodo4";
	println@Console( "Ho creato il nodo: " + nodo4.id_node )();
	println@Console( "Chiave pubblica nodo: " + nodo4.publicKey )();
	println@Console( "Numero di jollar: " + nodo4.numeroJollar )();
	nodoConnesso@PP8("Connesso");
	informazioniNodo4@PP13(nodo4)
}

main
{
 
 	//download blockchain
	[
		invioBlockchain(blockchain)
	];
	println@Console( "---------------------------------------------" )();
	println@Console( "Ho effettuato il download della blockchain!!!" )();
	println@Console( "---------------------------------------------" )();



	//riceve in broadcast l'hash del blocco genesis
 	[ invioHashBloccoGenesis(hashBloccoGenesis)];

 	println@Console( "Hash blocco genesis: "+ hashBloccoGenesis )();



 	//riceve i dati della transazione per la creazione del nuovo blocco
 	[creaBloccoDopoTransazione(transazioneRicevuta)(risposta)
 	{
 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo4"
 	}];

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

		[inizioPOW(inizioPOWnodo)];
		println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	//comincia la proof of work
	  	proofOfWork;

	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();


	  		proofOfWork
	  	}
	  	;

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();
	  		finePOW@PP13("nodo4")(risposta);
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concludo la POW: "+rispostaNodoArrivatoPrima )();
	  		
	  		[fineSemaforo(rispostaNodoArrivato2)];

	  		[fineSemaforo(rispostaNodoArrivato3)];
	
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  	


	  		if( rispostaNodoArrivatoPrima == "nodo4" ) {
	  		  //popola la dificolta del blocco
	  			blocco1.difficulty = difficolta;
	  			blocco1.lunghezzaCatena = lunghezzaCatenaPOW;
	  			

	  			nodo4.numeroJollar = nodo4.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo4.numeroJollar +" jollar" )();
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
  				invioBlockchain@PP13(blockchain)
	  		}else {
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



	  		[creaBloccoDopoTransazione(transazioneRicevuta)(risposta)
			 	{
			 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo2"
			 	}];	


			 	//crea il blocco con i dati ricevuti
			 	blocco2.id_block=2;
				//codice per generare hash blocco random
				random@Math()(a);
				b = string(a);
				md5@MessageDigest(b)(hashBlocco);
				blocco2.hashBlock = hashBlocco ;
				//hash blocco precedente (genesis block)
				blocco2.previousBlockHash = blockchainAttuale.block[1].hashBlock;
				
				//inserisce i dati della transazione nel blocco
				blocco2.transaction.hash_transaction = transazioneRicevuta.hash_transaction;
				blocco2.transaction.nodeSeller = transazioneRicevuta.nodeSeller;
				blocco2.transaction.nodeBuyer = transazioneRicevuta.nodeBuyer;
				blocco2.transaction.jollar = transazioneRicevuta.jollar;
				blocco2.transaction.timestamp = transazioneRicevuta.timestamp;
				


		[inizioPOW(inizioPOWnodo)];

		println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	//comincia la proof of work
	  	proofOfWork;

	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();


	  		proofOfWork
	  	}
	  	;

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();
	  		finePOW@PP13("nodo4")(risposta);
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concludo la POW: "+rispostaNodoArrivatoPrima )();
	  		
	  		[fineSemaforo(rispostaNodoArrivato2)];

	  		[fineSemaforo(rispostaNodoArrivato3)];
	
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  	


	  		if( rispostaNodoArrivatoPrima == "nodo4" ) {
	  		  //popola la dificolta del blocco
	  			blocco2.difficulty = difficolta;
	  			blocco2.lunghezzaCatena = lunghezzaCatenaPOW;
	  			

	  			nodo4.numeroJollar = nodo4.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo4.numeroJollar +" jollar" )();
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
  				invioBlockchain@PP13(blockchainAttuale)
	  		}else {
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
	  			Transazione tra il nodo1 e il nodo4
	  		 */

 		[nuovaTransazione(nuovaTransazione)(risultatoTransazione)
	 	{
	 		// nodo1.numeroJollar = nodo1.numeroJollar - nuovaTransazione.jollar;
	 		nodo4.numeroJollar = nodo4.numeroJollar + nuovaTransazione.jollar;
			// risultatoTransazione = nuovaTransazione.jollarINT
			risultatoTransazione = nuovaTransazione.jollar
	 	}];

	 	println@Console( "-----------------" )();
	 	println@Console( "NUOVA TRANSAZIONE" )();
	 	println@Console( "-----------------" )();
	 	println@Console( "Hai ricevuto: " + nuovaTransazione.jollar + " jollar da --> " + 
	 		nuovaTransazione.nodeSeller )();
	 	println@Console( "Ora i tuoi jollar sono: "+ nodo4.numeroJollar )();



	 	[creaBloccoDopoTransazione(transazioneRicevuta)(risposta)
			 	
			 	{
			 		risposta = "Transazione inviata in broadcast a tutti i nodi presenti nella rete! --> nodo2"
			 	}];	


			 	//crea il blocco con i dati ricevuti
			 	blocco3.id_block=3;
				//codice per generare hash blocco random
				random@Math()(a);
				b = string(a);
				md5@MessageDigest(b)(hashBlocco);
				blocco3.hashBlock = hashBlocco ;
				//hash blocco precedente (genesis block)
				blocco3.previousBlockHash = blockchainAttuale.block[2].hashBlock;
				
				//inserisce i dati della transazione nel blocco
				blocco3.transaction.hash_transaction = transazioneRicevuta.hash_transaction;
				blocco3.transaction.nodeSeller = transazioneRicevuta.nodeSeller;
				blocco3.transaction.nodeBuyer = transazioneRicevuta.nodeBuyer;
				blocco3.transaction.jollar = transazioneRicevuta.jollar;
				blocco3.transaction.timestamp = transazioneRicevuta.timestamp;
				


		[inizioPOW(inizioPOWnodo)];

		println@Console( "" )();
	  	println@Console( "..." )();
	  	println@Console( "STO MINANDO..." )();
	  	println@Console( "..." )();
	  	println@Console( "" )();


	  	//comincia la proof of work
	  	proofOfWork;

	  	while( controllo == false ) {
	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT NON VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();


	  		proofOfWork
	  	}
	  	;

	  		println@Console( "--------------------------------------" )();
	  		println@Console( "           FERMAT VALIDATO        " )();
	  		println@Console( "--------------------------------------" )();
	  		finePOW@PP13("nodo4")(risposta);
	  		[fineSemaforo(rispostaNodoArrivatoPrima)];
	  		println@Console( "Primo nodo ad aver concludo la POW: "+rispostaNodoArrivatoPrima )();
	  		
	  		[fineSemaforo(rispostaNodoArrivato2)];

	  		[fineSemaforo(rispostaNodoArrivato3)];
	
	  		[fineSemaforo(rispostaNodoArrivato4)];
	  	


	  		if( rispostaNodoArrivatoPrima == "nodo4" ) {
	  		  //popola la dificolta del blocco
	  			blocco3.difficulty = difficolta;
	  			blocco3.lunghezzaCatena = lunghezzaCatenaPOW;
	  			

	  			nodo4.numeroJollar = nodo4.numeroJollar + 6;
	  			println@Console( "" )();
	  			println@Console( "COMPLIMENTI! Sei stato il primo a concludere la proof of work" )();
	  			println@Console( "Hai ricevuto 6 jollar" )();
	  			println@Console( "Ora hai: "+ nodo4.numeroJollar +" jollar" )();
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
	  		numeroJollarNodo4@PP13(nodo4.numeroJollar);
	  		invioBlockchainNetwork@PP30(blockchainAttuale)
 	
}// main

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