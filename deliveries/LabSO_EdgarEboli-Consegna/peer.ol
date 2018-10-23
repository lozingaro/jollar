include "time.iol"
include "console.iol"
include "semaphore_utils.iol"
include "math.iol"
include "interface.iol"
include "file.iol"
include "string_utils.iol"
include "message_digest.iol"

//Tommaso Pagni
//Domenico Papandrea
//Daniel Fabbrica
// UNIBO 2018

/*
	Per avviare inserisci nella location del file>
	jolie -C "Server_location=\"socket://localhost:8001\"" peer.ol
*/

constants { 
	Server_location="socket://localhost:8000"
}

inputPort PortaIn {
	Location: Server_location
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort Localz {
	Location: Server_location
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort Saas {
	Location: "socket://localhost:7999"
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort Antenna {
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort BroadService {
    Interfaces: InterfaceBroadcasting
}

embedded {
    Jolie: "broadcaster.ol" in BroadService
}


define isPrime{
  
  presumedPrime = true;
  if (global.check % 2 == 0 && global.check!=2) {
    	presumedPrime =  false
        } else {
            
            powReq.base=global.check;
			powReq.exponent=0.5; 
			pow@Math(powReq)(threshold);

            testPrimeDiv = 3;
            presumedPrime = true;

            while (presumedPrime && testPrimeDiv <= threshold) {
                presumedPrime = ((global.check % testPrimeDiv) != 0);
                testPrimeDiv = testPrimeDiv+ 2
            }
            
        };
  global.prime = presumedPrime
}

define createKeys{
	global.check=3;
	//calcolo p e q
	global.prime=false;
	while( !global.prime )  {
		random@Math()(num);             
		global.check =int( num*1000); 
		isPrime
	};
	p=global.check;
	
	global.prime=false;
	while( !global.prime )  {
		random@Math()(num);
		global.check =int( num*1000); 
		isPrime
		};
	q=global.check;
	
	//calcolo N = p per q
	n = long(p*q);
	
	//calcolo Z come sotto
	z = ((p-1)*(q-1));
	
	//Calcolo e coprimo con Z
	prova=true;
	while( prova ) {
	
		random@Math()(num);
		e = int(num*n);

		if( e>z ) {
		  	a=e;
		  	b=z
		} else{
		  	a=z;
		  	b=e
		};

		while (b > 0){
			temp = b;
			b = a % b; // % is remainder
			a = temp
		};
		if( a==1 ) {
		prova=false
		}
	};
	
	//calcolo d come (e*d)-1 mod z = 0
	modD=2;
	d=1;
	
	while( modD!=1 ) {
		d++;
		k=int(e*d);
		modD= (k%z) 
	};
	
	// stampo chiave pubblica e chiave privata
	println@Console( "La tua chiave pubblica e'" +"(" + n + "," + e+")")();
	println@Console( "La tua chiave privata e'" +"(" + n + "," + d+")")();
	println@Console("Non perderle!!")();
	global.publicKey[n]=n;
	global.publicKey[e]=e;
	global.privateKey[n]=n;
	global.privateKey[d]=d;
	global.check=3
	}

define catena{
	//***** VERIFICO CHE SIA UN NUMERO PRIMO ***** //
	isPrime;

	// ***** CREA LA CATENA PRIMO TIPO **** // 
	if( !global.prime || global.check==global.blockchain.block[#global.blockchain.block-1].chain ) {
		global.check++;
		catena	
	}else if ( global.check>89 ) {
		println@Console( "out of bounds///////////////////////////////////////" )()
	}else{
		i=0;
		potentialElement=global.check;
		controllo=true;

		while( controllo ) { 
			result.chain[i]=potentialElement;
			potentialElement = 2*potentialElement + 1; //1° tipo
			global.check = potentialElement;

			isPrime;

			if(!global.prime && #result.chain<2){
				controllo = false;
				global.check=++result.chain[0];
				catena
			}else if ( !global.prime ) {
				
				controllo = false
			};

			i++			
		}

	};
	//calcolo della difficulty
	pk=result.chain[#result.chain-1];
	p= pk-1;

	powReq.base=2;
	powReq.exponent=double(p);
	pow@Math(powReq)(threshold);

	// calcolo il modulo e mi ricavo il resto del teorema di Fermat
	resto= (threshold%pk);

	// pk è il nostro ultimo valore, che nel nostro caso sarà sempre uguale a p
	// calcolo la difficoltà della catena (Difficulty=Pk/r)

	difficulty = (pk/resto)
}
		
define myReward{

	indexTr=#newBlock.transaction;
	with( newBlock.transaction[indexTr] ){
	  	.publicKeySeller="REWARD";
		.publicKeyBuyer[0]=global.publicKey[n];
		.publicKeyBuyer[1]=global.publicKey[e];
		.jollar=6
	};		
	synchronized( tokenHash ){
	
		undef(rewStr);
		undef(preSignature);


		rewStr="a";		/*uso "a" come nel calcolo dell'hash del blocco perche' artimnenti i valori numerici non si concatenano ma si sommano. */

		foreach ( child : newBlock.transaction[indexTr] ) {
			rewStr= rewStr + newBlock.transaction[indexTr].(child)
		};

		md5@MessageDigest(rewStr)(preSignature); 
		//firma della transazione con la chiave privata
		md5@MessageDigest(preSignature + global.privateKey[d] + global.privateKey[n])(newBlock.transaction[indexTr].signature) 

	}
}

define createBlock{
	acquire@SemaphoreUtils(global.semaforoC)(res);
	catena;	
	for ( i=0, i<#result.chain, i++ ) {		  
		newBlock.chain[i]=result.chain[i] // Eseguo la POW e la inserisco
	};
	newBlock.difficulty=difficulty;	//Inserisco la difficoltà
			
	global.check=result.chain[0] + 1; //aggiorno il valore di check per la prossima esecuzione del metodo catena

	undef(result.chain);//resetto catena per il prossimo blocco
				println@Console( "Creo il blocco numero : "+ #global.blockchain.block )();
	newBlock.indexOf=#global.blockchain.block; //Setto l'indice del blocco
				
	synchronized( tokenTrans ){
			//copio transazioni  
		foreach ( child : global.w8trans ) {
			for ( l=0, l<#global.w8trans, l++) {
					newBlock.transaction[indexTr].(child)=global.w8trans[l].(child);
					if( child == "publicKeyBuyer" ) {
					  newBlock.transaction[indexTr].(child)[1]=global.w8trans[l].(child)[1]
					};
					if( child == "publicKeySeller" ) {
					  newBlock.transaction[indexTr].(child)[1]=global.w8trans[l].(child)[1]

					}
				}
		};
		//undef del contenitore provvisiorio di transazioni
		undef( global.w8trans )
	};


	myReward;
	
	if(#global.blockchain == 0){
		 newBlock.prevHash = 0
	}else{
		newBlock.prevHash=global.blockchain.block[#global.blockchain.block-1].hash //inserisco hash del blocco precedente se presente
	};

	timeRequest@Saas()(newBlock.time); //Inserisco l'orario	

	synchronized( tokenHash ){
	  

		undef( hashString );
		hashString = "a";		//valore di controllo standard per il calcolo dell'hash
		foreach ( child : newBlock ) {

			if( child != "requester" ) {
			  
				hashString = hashString + newBlock.(child)		
			}

		};
		md5@MessageDigest(hashString)(newBlock.hash) //preparo lo hash del blocco
	};
		newBlock.requester=Server_location; //inserisco il mio indirizzo
			
		release@SemaphoreUtils(global.semaforoC)(res);

		validAsk@BroadService(newBlock)
			//invio per validare
		//broadcaster invia req res per vedere se valido
}

define imOnline{
	acquire@SemaphoreUtils(global.semaforoB)(res);
	posta=false;
	with( myInfo ){
	  .n=global.publicKey[n];
	  .e=global.publicKey[e]
	};
	myInfo=Server_location;
	peerOnline@BroadService(myInfo)(bk);
	global.broadID=bk.peerID;
	if(!bk.blockchain || !is_defined(bk.block.hash) ){		//cambio !bk con !bk.blockchain vedi 119 broadcaster
		//calcolo primo blocco
		posta = true

	} else{
		global.blockchain<<bk;
		global.check=global.blockchain.block[#global.blockchain.block-1].chain;
		posta=false
	};

	release@SemaphoreUtils(global.semaforoB)(res);

	if( posta ) {
		createBlock
	}
}

define checkMaCash{
	acquire@SemaphoreUtils(global.semaforoB)(res);
	saldo=0;
	for ( i=0, i<#global.blockchain.block, i++ ) {
	  
	
			for ( k=0, k<#global.blockchain.block[i].transaction , k++ ) {
				if( global.blockchain.block[i].transaction[k].publicKeySeller[0] == global.publicKey[n] && global.blockchain.block[i].transaction[k].publicKeySeller[1] == global.publicKey[e]
				  ) { 
				  saldo=saldo - global.blockchain.block[i].transaction[k].jollar;
				println@Console( "ciao" )()
				
				};

				 if (global.blockchain.block[i].transaction[k].publicKeyBuyer[0]==global.publicKey[n]
				 && global.blockchain.block[i].transaction[k].publicKeyBuyer[1]==global.publicKey[e]){
						saldo=saldo + global.blockchain.block[i].transaction[k].jollar
				}
			}
		};
		release@SemaphoreUtils(global.semaforoB)(res)
}

define charity{
		acquire@SemaphoreUtils(global.semaforoA)(res);

		println@Console( "Ehi i soldi del regalo di compleanno!." 
		+ global.pplOnline[#global.pplOnline-1].n + "  /  "+ global.pplOnline[#global.pplOnline-1].e )();
		checkMaCash;		
		random@Math()(nRandom);
		elemosina= nRandom * saldo;
		println@Console( saldo + " : saldo disponible" )();
		if( elemosina>1 ) {
			transType.jollar=int(elemosina)
		}else{
			transType.jollar=1
		};
		with( transType ){
		  	.publicKeySeller[0]=global.publicKey[n];
		  	.publicKeySeller[1]=global.publicKey[e];
			.publicKeyBuyer[0]=global.pplOnline[#global.pplOnline-1].n;
			.publicKeyBuyer[1]=global.pplOnline[#global.pplOnline-1].e
		};

		synchronized( tokenHash ){
		
			undef(rewStr);
			undef(preSignature);

			rewStr="a";		/*uso "a" come nel calcolo dell'hash del blocco perche' artimnenti i valori numerici non si concatenano ma si sommano. */

			foreach ( child : transType ) {
				rewStr= rewStr + transType.(child)[0];
				rewStr= rewStr + transType.(child)[1]
			};

			md5@MessageDigest(rewStr)(preSignature); 
			//firma con la chiave privata
			md5@MessageDigest(preSignature + global.privateKey[d] + global.privateKey[n])(transType.signature) //hash transazione

		};

		release@SemaphoreUtils(global.semaforoA)(res);
		newTrans@BroadService(transType)
}


init{

	//inizializzo semaforo
		global.semaforoA=null;
		with( global.semaforoA ){
			.name = "semaforoA";
			.permits = 1
		};
		release@SemaphoreUtils(global.semaforoA)(res);

		global.semaforoB=null;
		with( global.semaforoB ){
			.name = "semaforoB";
			.permits = 1
		};
		release@SemaphoreUtils(global.semaforoB)(res);

		global.semaforoC=null;
		with( global.semaforoC ){
			.name = "semaforoC";
			.permits = 1
		};
		release@SemaphoreUtils(global.semaforoC)(res);

		println@Console( "Ciao io sono " + Server_location )();
		createKeys;
		imOnline	
}

execution{ concurrent }


main{	

	[askChain(ask)(resChain){
		acquire@SemaphoreUtils(global.semaforoB)(res);
		//semaforo in entrata
		global.pplOnline<<ask;
		println@Console( global.pplOnline.n + " join the room")();
		//release semaforo
		if( is_defined( global.blockchain.block.hash ) ) {
		  	resChain<<global.blockchain;
		  	resChain=true
		}else{
			resChain=false
		};
		release@SemaphoreUtils(global.semaforoB)(res)
	}]{
		checkMaCash;
		if( saldo>0 ) {
			charity
		  	}
		
		}

	[incominTrans(incomingTransaction)]{
		
		synchronized( tokenTrans ){
			//inserisco la transazione in coda
				foreach ( child : incomingTransaction ) {
					global.w8trans.(child)=incomingTransaction.(child);
					if( child == "publicKeySeller" ) {
					  global.w8trans.(child)[1]=incomingTransaction.(child)[1]
					};
					if( child == "publicKeyBuyer" ) {
					  global.w8trans.(child)[1]=incomingTransaction.(child)[1]
					}
				}
			};
			
			println@Console( "///////NUOVA TRANSAZIONE IN ENTRATA!!!!///// ")();
		
				//avvio creazione blocco
			createBlock			
	}

	[writeBlock(newBlock)]{
		acquire@SemaphoreUtils(global.semaforoC)(res);
		acquire@SemaphoreUtils(global.semaforoB)(res);
		index=#global.blockchain.block;
		if(newBlock.indexOf > index-1){		
			global.blockchain.block[index]<<newBlock
		};
		release@SemaphoreUtils(global.semaforoC)(res);
		release@SemaphoreUtils(global.semaforoB)(res)
	}
		
	[validation(aBlock)(isValid){
		acquire@SemaphoreUtils(global.semaforoB)(res);
		isValid = false;
		if( !is_defined(global.blockchain.block.hash) ){ //Se non ho una blockchain
		
			isValid=true 
		
		}else if(aBlock.time>global.blockchain.block[#global.blockchain.block-1].time && aBlock.indexOf>=#global.blockchain.block){ //Se il tempo e l'indice sono maggiori dell'ultimo
		
			synchronized( tokenHash ){
			  
				hashCheck = "a";
				foreach ( child : aBlock ) {

					if( child != "requester"  && child != "hash") {
					  
						hashCheck = hashCheck + aBlock.(child)		
					}						
				};



				md5@MessageDigest(hashCheck)(h2)
			};

			if( #aBlock.transaction>=2 && aBlock.indexOf!=0 ) {
				isValid=true
			}else{
				println@Console( "UNA TRANS SOLA" )()
			}

		}else{
			println@Console( "Blocco non validato >" +aBlock.indexOf + " di "+ aBlock.requester )();
			isValid=false
		};
		release@SemaphoreUtils(global.semaforoB)(res)
	}]

	[askKey()(reqKey){ 

		reqKey.key[0] = global.publicKey[n];
		reqKey.key[1] = global.publicKey[e];
		reqKey.owner = Server_location
	}]

	[askVersion()(versione){ 
		acquire@SemaphoreUtils(global.semaforoB)(res);
		versione.num = #global.blockchain.block;
		versione.owner = Server_location;
		versione.bk << global.blockchain;
		release@SemaphoreUtils(global.semaforoB)(res)
	}]


}




