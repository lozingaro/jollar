type IndexMessage: void {
	.sid : string
	.index? : int
}

type BlockchainMessage: void {
	.sid :  string
	.blockchain : Blockchain
}

type SidMessage: void {
	.sid : string
}

type BMsg: void {
	.sid: string
	.b : undefined
}

type infoPeer: void {
	.publicKey: string
	.location: string
	.protocol: string
  	.sid?: string //opzionale perché viene generato in un secondo momento?
}

type Blockchain: void {
	.block*: Block
}

type Block: void {
	.previousBlockHash: string
	.difficulty: double
	.transaction*: Transaction
	.timeStamp: long
}

type Transaction: void {
	.nodeSeller: Node
	.nodeBuyer: Node
	.jollar: int
}
type Node: void {
	.publicKey: string
	.privateKey?: string
	.walletAmount: int
}

type clientType:void{
	.name: string
	.value: int
}

type ListaPeer: void {
	.nodo* : infoPeer
}

interface JollarInterface {
	RequestResponse:
	sendACK( clientType )( int ),
	receiveTime( SidMessage )( long ),
	createRepository( string )( bool ),
	aggiungiPeer( infoPeer )( IndexMessage ),
	downloadBlockchain( SidMessage )( Blockchain ),
	invioPeer( SidMessage )( ListaPeer ),
	isValidChain( SidMessage )( bool ),
	acquisisciSemaforo(string)(void)
	OneWay:
	invioBlockchain( BlockchainMessage ),
	inAttesaDiTuttiIPeer(void),
	invioBlocco(BMsg)
}
