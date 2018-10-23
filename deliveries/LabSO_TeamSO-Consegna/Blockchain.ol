//FileSystemRW.ol
include "Blockchain.iol"
include "file.iol"
include "console.iol"


inputPort In {
	Location: "local"
	Interfaces: BlockchainInterface
}

define readFile{ //base64 readfile 
	scope( readfile )
	{
		install( FileNotFound => println@Console( "FileNotFound, forse il file non esiste" )());
		readFile@File({.filename=readFileRequest,.format="base64"})(fileLetto)
	  	//;println@Console( "Stringa in base64: "+fileLetto )()
	}
}


define readPub{
	scope( readpub )
	{
		install( FileNotFound => println@Console( "FileNotFound, forse il file non esiste" )() );
		undef( readFileRequest );
		readFileRequest=usernameRequest+"publick";
		readFile
	}
}

define readPriv{
	scope( readpriv )
	{
		install( FileNotFound => println@Console( "FileNotFound, forse il file non esiste" )() );
		undef( readFileRequest );
		println@Console( "La tua chiave privata e':" )();
		readFileRequest=usernameRequest+"privk";
		readFile
	}
	
}

define retrieveBlockchain
{
	scope( retrieveBlockchai )
	{
		install( FileNotFound =>println@Console( " " )() );
		//aggiungere tentativo di sync per ottenere la blockchain dagli altri... TODO
		if(#global.blockchain==0 || sovrascrivi==true){
			readFileRequest.filename="blockchain"+global.username;
			readFileRequest.format="json";
			readFile@File(readFileRequest)(blockchainLetta);
			if(is_defined( blockchainLetta )) global.blockchain<<blockchainLetta
		}

}
}


define saveBlockchain
{
	wFileRequest.filename="blockchain"+global.username;
	wFileRequest.content<<global.blockchain;
	wFileRequest.format="json";
	writeFile@File(wFileRequest)();
	undef( wFileRequest )
}

define aggiorna
{
	sovrascrivi=true;
	retrieveBlockchain;
	sovrascrivi=false
}

execution{ concurrent }
main{
	[readPrivateKey(user)(privkey){
		scope( readKey )
		{
			install( FileNotFound => println@Console( "Errore! Assicurati di aver creato le chiavi ! usa -create "  )());
			global.username=usernameRequest=user;
			readPriv;
			privkey=fileLetto
		}
	}]
	[readPublicKey(user)(pubkey){
		scope( readKey )
		{
			install( TypeMismatch => println@Console( "Errore! Assicurati di aver creato le chiavi ! usa -create "  )());
			global.username=usernameRequest=user;
			readPub;
			pubkey=fileLetto
		}
	}]
	[readBlockChain(user)(res){
		if( is_defined( global.blockchain ) ) {
			undef( res );
			res<<global.blockchain
		}else{
			global.username=usernameRequest=user;
			retrieveBlockchain;
			res<<blockchainLetta
		}
	}]
	[existOrigin(originRequest)(res){
		if( is_defined( global.blockchain ) ) {
			undef( res );
			indexOrigin=#global.origin;
			res=true;
			v=0;
			while( res==true && v<#global.blockchain.block ) {
				if(global.blockchain.block[v].origin==originRequest){
					res=false
				};
				v++
			}
		}else{
			throw( NotSetError )
		}
	}]
	[getBlockHash(reqAltezza)(respBlockHash){
		undef( respBlockHash );
		aggiorna;
		respBlockHash=global.blockchain.block[reqAltezza].hash
	}]
	[checkIfUnspent(req)(res){
		res=true;
		for ( i=req.altezza, i<#global.blockchain.block, i++ ) {
			for ( t=0,t<#global.blockchain.block[i].transaction,t++ ) {
				if(req.hash==global.blockchain.block[i].transaction[t].input.previousUtxoTxid){
  		  //	println@Console( "Ok è stata spesa" )();
					res=false
				}
			}

		}
	}]
	[getDifficulty(indexRequest)(res){
		if( is_defined( global.blockchain ) ) {
			aggiorna;
			res=global.blockchain.block[indexRequest].difficulty
		}else{
			throw( NotSetError )
		}
	}]
	[getUtxo(address)(res){
		undef( res );
		undef(global.myValidUtxo);
		undef(b);
		undef(t);
		global.username=address.user;
		aggiorna;
		utxoAddr=address;
		for (b=0, b<#global.blockchain.block, b++ ) {
			for (t=0, t<#global.blockchain.block[b].transaction, t++ ) {
				if(global.blockchain.block[b].transaction[t].output.payto==utxoAddr){
					global.myValidUtxo[#global.myValidUtxo]=global.blockchain.block[b].transaction[t]
				} ;
				undef( indexListaUtxo );
				for ( indexListaUtxo=0, indexListaUtxo<#global.myValidUtxo, indexListaUtxo++ ) {
					if(global.myValidUtxo[indexListaUtxo]==global.blockchain.block[b].transaction[t].input.previousUtxoTxid) {
						global.myValidUtxo[indexListaUtxo]="remove"
					}  
				}
			}
		}
		;
		for ( iniprint=0, iniprint<#global.myValidUtxo, iniprint++ ) {
			if(global.myValidUtxo[iniprint]!="remove"){
				res.result[#res.result]=global.myValidUtxo[iniprint]
			}

		}
	}]
	[trovaAltezza(hash)(res){//restituisce numero del blocco in cui viene trovata transazione con hash in input
		res=false;
		hashdatrovare=hash;
		scope( trovaAltezzaScope )
		{
			install( Trovato => res=i );
			for(i=0,i<#global.blockchain.block,i++){
  	  		//println@Console( i+"esimo blocco controllo in corso" )();
				for(t=0,t<#global.blockchain.block[i].transaction,t++){
  				//println@Console( t+"esima transazione controllo in corso" )();
					if(hashdatrovare==global.blockchain.block[i].transaction ){
  					//println@Console( "trovato al blocco numero "+i )();
						throw( Trovato )

					}
				}
			}
		}

	}]
	[setUser(user)]{//
		global.username=user;
		aggiorna
	}
	[getLastBlockIndex(void)(res){
		undef( res );
		aggiorna;

		res=#global.blockchain.block-1
	}]
	[addValidBlock(request)]{
		aggiorna;
		global.blockchain.block[#global.blockchain.block]<<request;
		saveBlockchain
	}
	[writeBlockchain(req)]{
		undef(global.blockchain);
		global.username=req.user;
		global.blockchain<<req.blockchain;
		saveBlockchain
	}
	[startBlockchain(user)(res)]{
		scope( startBlockchainScope )
		{
			install( FileNotFound =>
				wFileRequest.filename="blockchain"+user;
				wFileRequest.content<<"";//vuoto
				wFileRequest.format="json";
				writeFile@File(wFileRequest)();
				println@Console( "Creato file vuoto per contenere la blockchain" )();
				println@Console( "Se non l'hai gia fatto, usa il comando -create per creare le chiavi !" )()
				);
			readFileRequest.filename="blockchain"+user;
			readFileRequest.format="json";
			readFile@File(readFileRequest)(res);
			if(is_defined( res ))println@Console( "Importo la blockchain perche' gia presente" )(); global.blockchain<<res;global.username=user
		}
	}


}