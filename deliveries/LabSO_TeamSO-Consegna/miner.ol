//miner.ol
include "miner.iol"
include "console.iol"
include "string_utils.iol" 
include "catene.iol" // servizio embeddato output port Catene
include "terminal.iol"


inputPort In {
	Location: "local"
	Protocol: sodep
	Interfaces: MinerInterface
}


outputPort MyTerm { // per comunicare con il terminale locale che embedda cat.ol
	Location: "null"
	Protocol: http
	Interfaces: Local
}

define checkOrigin{
	notfound=true;
	checkOriginRequest=i;
	for ( checkIndex=0, checkIndex<nextIndex, checkIndex++ ) {
		if(checkOriginRequest==mex.message.block[checkIndex].origine) notfound=false
	}
}

define preparaBlocco
{ 
	constantDiv=double(255)/256;
	currentDiff=resDiff;
	if(currentDiff>=constantDiv){
		lastLenght=lastLenght+1;
		resDiff=0.0
	};

	with( bloccoCreato ){
		.difficulty=resDiff+double(lastLenght);
		.altezza=nextIndex;
		.origine=i;
		.data="Blocco Jollar N. "+nextIndex;
		.previousBlockHash=mex.message.block[lastIndex].hash
	}

}

define inviaBlocco
{
	terminalLocation=mex.location;
	MyTerm.location=terminalLocation;
	pushReq.sid=mex.sid;
	pushReq.message<<bloccoCreato;
	pushBlock@MyTerm(pushReq)
}
execution{ concurrent }
main{
	[minaBlocco(mex)]{
		scope( miningScope )
		{
			install( CatenaValida => println@Console( "----Chunningam chain trovata origine: "+i+" ----"   )();
				preparaBlocco;
				inviaBlocco
				);
			lastIndex=#mex.message.block-1;
			nextIndex=lastIndex+1;
			normale=double(mex.message.block[lastIndex].difficulty);
			lastLenght=int(normale);
			lastDifficulty=double(mex.message.block[lastIndex].difficulty)-int(lastLenght);
			println@Console( "Ultimo indice:"+lastIndex )();
			println@Console( "Blocco da creare:"+nextIndex )();
			println@Console( "Ultima difficulty:"+lastDifficulty)();

			println@Console( "Lunghezza ultima catena:"+lastLenght )();
			println@Console( "difficulty completa"+normale )();


			if(normale<1.0)lastLenght=1;
			for(i=1,i<10000000,i++){
			checkPrime@Catene(i)(resPrime); //restituisce 0 se non è primo , 1 se è primo
			if(resPrime==1){
			//	println@Console( "Controllo sul numero primo: "+i )();
				checkChain@Catene(i)(resChain); // restituisce 0 se non è primo, 1 se èb un singolo primo, 2 se è una catena di 2 numeri primi ecc.
				if(resChain==lastLenght){
					println@Console( "Catena trovata con lunghezza:" +resChain)();
					difficolta@Catene(i)(resDiff);//restituisce la parte decimale difficulty
					if(resDiff>lastDifficulty){
						println@Console( "Catena trovata con origine:"+i+"..controllo che non sia usata  " )();
						checkOrigin;
						if(notfound==true){
							println@Console( "Ok catena di primi mai utilizzata con origine:"+i )();
							undef( notfound );
							throw( CatenaValida )
						}else{
							println@Console( "catena potenzialmente valida ma purtroppo e' gia stata usata !" )()
						}

					}else{
						println@Console( "Mining....  difficulty decimale non sufficiente: "+resDiff+"<"+lastDifficulty)()
					}
				}
			}
		}
	}


}

}