type OpMessage: void {
  .sid : string
  .i? : int
  .blockchain?: Blockchain
}

type infoPeer: void {
  .publicKey: string
  .location: string
  .protocol: string
  .sid: string
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

interface JollarInterface {
	RequestResponse:
	sendACK( clientType )( int ),
	receiveTime( void )( long ),
	createRepository( string )( bool ),
	aggiungiPeer( infoPeer )( OpMessage ),
	downloadBlockchain( OpMessage )( Blockchain ),
	invioPeer( void )( string )
	OneWay:
	invioBlockchain( OpMessage ),
	isValidChain( undefined )
}