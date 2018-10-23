include "console.iol"
include "file.iol" 	
include "semaphore_utils.iol"
include "string_utils.iol"
include "interface.iol"
include "time.iol"

//Non eseguibile stand alone

inputPort LocalIn {
    Location: "local"
    Interfaces: InterfaceBroadcasting
}

outputPort Localz {
	Location: Server_location
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

outputPort Antenna {
	Protocol: sodep
	Interfaces: InterfaceBroadcasting
}

define getSplitResult{
	acquire@SemaphoreUtils(semaforoD)(res);
	ReadFileRequest.filename="list.txt";
	ReadFileRequest.format= "text"; 
	readFile@File(ReadFileRequest)(list);

	undef( SplitResult );
	split = list;
	split.length = 23;
	splitByLength@StringUtils(split)(SplitResult);
	release@SemaphoreUtils(semaforoD)(res)	
}

execution{ concurrent }

init{
	semaforoB=null;
	with(semaforoB ){
		.name = "semaforoB";
		.permits = 1
	};
	release@SemaphoreUtils(semaforoB)(res);


	semaforoD=null;
	with(semaforoD ){
		.name = "semaforoD";
		.permits = 1
	};
	release@SemaphoreUtils(semaforoD)(res);
   
	semaforoC=null;
	with(semaforoC ){
		.name = "semaforoC";
		.permits = 1
	};
	release@SemaphoreUtils(semaforoC)(res);

	semaforoE=null;
	with(semaforoE ){
		.name = "semaforoE";
		.permits = 1
	};
	release@SemaphoreUtils(semaforoE)(res)
}

cset {
sessToken: CloseBroad.sessToken 
  		   Ask.sessToken
}	

main{	

	[peerOnline(myInfo)(bk){
		println@Console( "Broadcaster aperto" )();
   		bk.sessToken=csets.sessToken = new;
		
		getSplitResult;
		trovato=false;
		for ( i=0, i<#SplitResult.result, i++ ) {
		  if( SplitResult.result[i]==myInfo ) {
		    trovato=true
		  }
		};
		acquire@SemaphoreUtils(semaforoC)(res);
		if( !trovato ) {		
			WriteFileRequest.filename="list.txt";
			WriteFileRequest.append=1;
			WriteFileRequest.content = myInfo;
			writeFile@File(WriteFileRequest)()
		};
		reqChain<<myInfo;
		reqChain.sessToken=bk.sessToken;
		getSplitResult;
		//invio
		for ( j = 0, j <#SplitResult.result-1, j++ ) {
			Antenna.location = SplitResult.result[j];				  
			scope (ask_Scope){				
				if(SplitResult.result[j]  != myInfo ) {
					install(IOException => println@Console("Richiesta BK fallita con: "+ Antenna.location)());	
					askChain@Antenna(reqChain)(blockChain);
					println@Console( "Mi arriva blockchain da "+ Antenna.location )()
				}else if ( myInfo==SplitResult.result[j] ) {
					println@Console( "" )()
				}
			}
			
		};

		if( blockChain==false || !is_defined( blockChain.block.hash ) ) {
		 	bk.blockchain=false
		}else{
			bk<<blockChain;
			bk.blockchain=true
		};
		release@SemaphoreUtils(semaforoC)(res)
	}]

		[newTrans(transType)]{

			acquire@SemaphoreUtils(semaforoB)(res);
			incomingTransaction<<transType;
			incomingTransaction.transID=new; 
			getSplitResult;
			undef( a );
			b=0;

			for ( j = 0, j <#SplitResult.result, j++ ) {
				Antenna.location =SplitResult.result[j]; 
				scope (ask_Scope){				
					install(IOException => {println@Console("Invio nuova transazione FALLITO n."+a+" : "+ Antenna.location)(); a++});	
					incominTrans@Antenna(incomingTransaction);
					b++					
				}	
			};

			release@SemaphoreUtils(semaforoB)(res)				
		}

		[validAsk(newBlock)]{

			getSplitResult;			
			acquire@SemaphoreUtils(semaforoC)(res);
			//inizializzo variabili
			undef( a );
			b=0;
			undef( valid );
			undef( notValid );
			valid=1;

			for ( j = 0, j <#SplitResult.result, j++ ) {
				
				Antenna.location =SplitResult.result[j]; 
				scope (ask_Scope){		
					install(IOException => {println@Console("Richiesta validazione blocco fallita n."+a+" per: "+ Antenna.location)(); a++});	
					
					if(Antenna.location != Server_location){
																	
						validation@Antenna(newBlock)(isValid);
						
						println@Console( " Invio richiesta validazione a " + Antenna.location + " che risponde " + isValid )();
						if( isValid == true  ) { 
			  				valid++
						}else if( isValid==false ) {
							notValid++
						} 					
					}else{
						println@Console( "NON CHIEDO LA VALIDAZIONE A ME STESSO!" )()
					}
					
				}
				
			};
			
			
			nOnline=#SplitResult.result - a;
			println@Console( a + ": Invii falliti , "+#SplitResult.result+ " nodi totali presenti nella lista" )();
			soglia=(nOnline/2)+(nOnline%2);
			undef( SplitResult );
			getSplitResult;
	
			if( valid>=soglia ) {
	
				for ( i=0, i<#SplitResult.result, i++ ) {
					Antenna.location =SplitResult.result[i];	
					println@Console( "Invio writeBlock n."+ i +" a: " + Antenna.location  )();
					install( IOException => println@Console( "ioex a "+ Antenna.location )() );
					acquire@SemaphoreUtils(semaforoE)(res);
					writeBlock@Antenna(newBlock);
					release@SemaphoreUtils(semaforoE)(res)
					
				}
		
			}else{
				println@Console(" Blocco non convalidato.")()		
			};		
		release@SemaphoreUtils(semaforoC)(res)	
		}

		[close(closeMsg)]{
			println@Console( "Broadcaster chiuso" )()
		}
			
	}				

