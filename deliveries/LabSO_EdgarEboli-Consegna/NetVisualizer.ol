include "time.iol"
include "console.iol"
include "semaphore_utils.iol"
include "math.iol"
include "interface.iol"
include "file.iol"
include "string_utils.iol"
include "message_digest.iol"

outputPort Saas {
	Location: "socket://localhost:7999"
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort Antenna {
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

define getSplitResult{
	acquire@SemaphoreUtils(global.semaforoD)(res);
	ReadFileRequest.filename="list.txt";
	ReadFileRequest.format= "text"; 
	readFile@File(ReadFileRequest)(list);

	undef( SplitResult );
	split = list;
	split.length = 23;
	splitByLength@StringUtils(split)(SplitResult);
	release@SemaphoreUtils(global.semaforoD)(res)	
}

define whatTimeisIt{
  undef(global.time);
  scope (ask_Scope){
	  install(IOException => {println@Console("OROLOGIO SPENTO!")(); global.time = 0;
							  	with(global.time){
							  		.hour = 0;
							  		.second = 0;
							  		.minute = 0
							  	}
	  });	
	  timeRequest@Saas()(ms);
	  msInt = int(ms);
  	getTimeFromMilliSeconds@Time(msInt)(tempo);
  	with(ms){
  		.hour = tempo.hour;
  		.minute = tempo.minute;
  		.second = tempo.second
  	};
	println@Console("H = " + tempo.hour + " M = " + tempo.minute + " S = " + tempo.second )();

	  global.time << tempo
  }  
}

define keys{
	getSplitResult;

	for ( j = 0, j <#SplitResult.result, j++ ) {
		Antenna.location = SplitResult.result[j];				  
		scope (ask_Scope){
			install(IOException =>  {println@Console("CHECK CHIAVE -> " + Antenna.location + " non raggiungibile ")();
										global.keys[j].key[0] = "NULL";
										global.keys[j].key[1] = "NULL";
										global.keys[j].owner = Antenna.location
									});
			askKey@Antenna()(reqKey);			
			
			global.keys[j].key[0] = reqKey.key[0];
			global.keys[j].key[1] = reqKey.key[1];
			global.keys[j].owner = reqKey.owner				
		}			
	}
}

define versioneBK{
	getSplitResult;
	global.best = 0;

	for ( j = 0, j <#SplitResult.result, j++ ) {
		Antenna.location = SplitResult.result[j];				  
		scope (ask_Scope){
			install(IOException =>  {println@Console("CHECK VERSIONE -> " + Antenna.location + " non raggiungibile ")();
										global.version[j] = "NULL";
										global.version[j].owner = Antenna.location;
										global.app = 0										
									});

			askVersion@Antenna()(versione);
			global.app = versione.num;
			global.version[j] = versione.num;
			global.version[j].owner= versione.owner;
			global.version[j].bk << versione.bk;

			if(global.app > global.best){
				global.best = global.app;
				global.best.owner = versione.owner;
				global.best.bk << versione.bk
			}
		}			
	}
}

define infoNodi{

	keys;
	versioneBK;
	for ( j = 0, j < #global.keys, j++ ) {
		println@Console( "
Nodo: " + global.keys[j].owner + "   chiave: (" + global.keys[j].key[0] + " , " + global.keys[j].key[1] + ") versione: "+ global.version[j]+ " 
				")();
				
			saldo=0;

		for ( i=0, i<#global.best.bk.block, i++ ) {
		  
			for ( k=0, k<#global.best.bk.block[i].transaction , k++ ) {
				//se sono il seller, cedo i jollar e il mio saldo e' negativo
				//println@Console( global.best.bk.block[i].transaction[k].publicKeySeller[0] + " . i=" +i + " . k + "+k )();
				if( global.best.bk.block[i].transaction[k].publicKeySeller[0]==global.keys[j].key[0] && global.best.bk.block[i].transaction[k].publicKeySeller[1]== global.keys[j].key[1]
				  ) { 
				  	//uscenti
					println@Console( "---> in uscita  nel blocco " +i+" con hash "+ global.best.bk.block[i].hash +" :"
						+ global.best.bk.block[i].transaction[k].jollar+ " jollar inviati a :" + global.best.bk.block[i].transaction[k].publicKeyBuyer[0] + ", "+global.best.bk.block[i].transaction[k].publicKeyBuyer[1]  )();

				  	saldo=saldo - global.best.bk.block[i].transaction[k].jollar

				};
				//se sono il buyer, prendo i jollar e il mio saldo e' positivo
				if (global.best.bk.block[i].transaction[k].publicKeyBuyer[0]==global.keys[j].key[0]
				 && global.best.bk.block[i].transaction[k].publicKeyBuyer[1]==global.keys[j].key[1] ){
					//entranti
					println@Console( "<--- in entrata nel blocco " +i+" con hash "+ global.best.bk.block[i].hash +" :"
						+ global.best.bk.block[i].transaction[k].jollar+ " jollar ricevuti da :" + global.best.bk.block[i].transaction[k].publicKeySeller[0] + ", "+ global.best.bk.block[i].transaction[k].publicKeySeller[1]  )();

				 	saldo=saldo + global.best.bk.block[i].transaction[k].jollar		
				}
			}		

		};

  		println@Console( "Numero jollar in possesso: " + saldo )();
  		totJoll = totJoll + saldo
	};

	println@Console( "
----- Jollar totali sulla rete: "+ totJoll + " -----" )()		//sono solo di quelli online, se uno va offline non si vedono piu i suoi jollar.
}

define stampBK{
	undef(global.best);
	versioneBK;
	if(global.best != 0){

		println@Console( "
		--------------- BlockChain ---------------
		" )();
		println@Console( "Numero blocchi presenti = " + global.best )();

		for ( i=0, i<#global.best.bk.block, i++ ) {
			println@Console( "Blocco numero : "+i+"
			" )();

			foreach ( child : global.best.bk.block[i] ) {
				if( child != "transaction" ) {
				  
				println@Console(child + " : " +   global.best.bk.block[i].(child))();
				println@Console( " " )()
				}
			};
			println@Console( "Transazioni  del blocco numero : "+i )();

			for ( k=0, k<#global.best.bk.block[i].transaction , k++ ) {
						println@Console( "---------------
		transaction n . "+ k + " 
Jollar scambiati : "+ global.best.bk.block[i].transaction[k].jollar )();
						println@Console( "INVIATO DA :"+global.best.bk.block[i].transaction[k].publicKeySeller[0] + " [publicKeySeller]" )();
						println@Console( "RICEVENTE }> :"+global.best.bk.block[i].transaction[k].publicKeyBuyer[0] + " [publicKeyBuyer]" )();
						
						println@Console( "----------------
							" )()
					}	
		}

	}else{
		println@Console( "Nessuna BlockChain presente nella rete!" )()
	}
}

init{
	global.semaforoA=null;
	with( global.semaforoA ){
		.name = "semaforoA";
		.permits = 1
	};
	release@SemaphoreUtils(global.semaforoA)(res);

	global.semaforoD=null;
	with( global.semaforoD ){
		.name = "semaforoD";
		.permits = 1
	};
	release@SemaphoreUtils(global.semaforoD)(res);
	registerForInput@Console()();
	println@Console( "  ----- WELCOME -----" )();
  	println@Console( "Seleziona la tua scelta.
  					  1  -  Info Nodi
  					  2  -  BlockChain" )()
}

execution{ concurrent }

main{
	
  	in(scelta);

  	if(scelta == 1){
  		whatTimeisIt;
  		println@Console( "InfoNodi " + global.time.hour +"h "+global.time.minute +"m " +global.time.second +"s " )();
  		infoNodi
  	}else if(scelta == 2){
  		whatTimeisIt;
  		println@Console( "BlockChain " + global.time.hour +"h "+global.time.minute +"m " +global.time.second +"s " )();
  		stampBK
  	}else{
  		println@Console( "Comando errato, inserisci 1 per InfoNodi, 2 per vedere la BlockChain" )()
  	}
}