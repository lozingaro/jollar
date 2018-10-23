type Blockchain: void {
	.block*: Block | GenesisBlock
}

type Block: void {
	.previousBlockHash: string
	.nodoGeneratore: string
	.difficulty: double
	.timestamp: long
	.powchain*: double
	.transaction*: Transaction
}

type GenesisBlock: void {
	.previousBlockHash: string
	.nodoGeneratore: string
	.difficulty: double
	.transaction*: Transaction
	.timestamp: long
}

type Transaction: void {
	.nodeSeller: string 
	.nodeBuyer: string 
	.jollar: int 
	.hash: string
	.timestamp: long
}

type Node: void {
	.publicKey: string 
	.privateKey?: string
}

type ListaLocation: void {
	.porta*: string
}

interface Nodo_interface {
	OneWay:
	mandaTransaction(Transaction),
	aggiornaLocations(void)
	RequestResponse:
	mandaBlocco(Block)(bool),
	getTimestamp(void)(long),
	notifyServer(void)(string),
	getLocations(void)(ListaLocation),
	getBlockchain(void)(Blockchain),
	prendiSemaforo(int)(void),
	lasciaSemaforo(int)(void)
}