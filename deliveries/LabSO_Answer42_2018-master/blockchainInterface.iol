// Definizione dei vari data types all'interno dell'interfaccia 

type Blockchain : void {
	.block* : Block | GenesisBlock
}

type GenesisBlock : void {
	.id_block_G : int
	.hashBlock_G : string 
	.previousBlockHash_G : string
	.difficulty_G : int 
}

type Block : void {
	.id_block : int
	.hashBlock : string 
	.previousBlockHash : string
	.difficulty : double 
	.transaction : Transaction 
	.lunghezzaCatena : int
}

type Transaction : void {
	.hash_transaction : string
	.nodeSeller : string 
	.nodeBuyer : string
	.jollar : int 
	.timestamp : string
}

type Node : void {
	.id_node : string
	.publicKey : string
	.privateKey? : string
	.jollarNumb : int
}

// Definizione dell'interfaccia con i relativi servizi One-Way e Request-Response

interface BlockchainInterface
{

	OneWay:

	infoNode1(Node),
	infoNode2(Node),
	infoNode3(Node),
	infoNode4(Node),

	sendInfoNode1(Node),
	sendInfoNode2(Node),
	sendInfoNode3(Node),
	sendInfoNode4(Node),

	jollarNumbNodo1(int),
	jollarNumbNodo2(int),
	jollarNumbNodo3(int),
	jollarNumbNodo4(int),

	sendGenesisBlock(string),
	sendBlockChain(Blockchain),
	connect(string),
	startPOW(string),
	endCritics(string),
	sendBlockChainNetwork(Blockchain),

	qstjollarNumbNodo1(int),
	qstjollarNumbNodo2(int),
	qstjollarNumbNodo3(int),
	qstjollarNumbNodo4(int)

		
	RequestResponse: 
		

	newBlock(Transaction)(string),
	newTransaction(Transaction)(int),
	serverTimestamp(string)(string),
	endPOW(string)(string),
	

}

/*interface NetworkVisualizer {
  OneWay: 
  RequestResponse: 
}
*/
