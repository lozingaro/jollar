 type IndexMessage: void {
	.sid : string
	.index : int
}

type SidMessage: void {
	.sid : string
}


type BlockMsg: void {
	.sid: string
	.cryptoCurrentBlockHash: string
	.block : Block
}

type infoPeer: void {
	.publicKey: string
	.location: string
	.protocol: string
}

type Blockchain: void {
	.block*: Block
}

type Chain: void{
	.tipo: int
	.origine:	int
	.primo: int
	.i: int
}
type Block: void {
	.previousBlockHash: string
	.difficulty: double
	.transaction: Transaction //ho tolto l'* perché una transazione per blocco
	.timeStamp: long
	.chain: Chain
}

type Transaction: void {
	.nodeSeller: Node
	.nodeBuyer: Node
	.jollar: int
}

type Node: void {
	.publicKey: string
	.privateKey?: string
	.index? : int
}

type clientType:void{
	.name: string
	.value: int
}

type ListaPeer: void {
	.nodo* : infoPeer
}

//listaPeer deve essere di tipo: ListaPeer ?! non infopeer
type NetVis: void{
	.dateReq: string
	.listaPeer*: infoPeer //andrebbe ListaPeer
}

interface JollarInterface {
	RequestResponse:
	receiveTime( SidMessage )( long ),
	aggiungiPeer( infoPeer )( IndexMessage ),
	downloadBlockchain( SidMessage )( Blockchain ),
	invioPeer( SidMessage )( ListaPeer ),
	isValidChain( SidMessage )( bool ),
	riceviBlockchain( void )( Blockchain ),
	networkVisualizer( SidMessage )( NetVis )
	OneWay:
	inAttesaDiTuttiIPeer( void ),
	inAttesaDelleTransazioni( void ),
	invioPrimoBlocco( BlockMsg ),
	invioBlocco( BlockMsg )
}
