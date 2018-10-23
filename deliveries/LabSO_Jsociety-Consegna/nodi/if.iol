type OpMessage: void {
  .sid : string
  .i? : int
  .blockchain?: Blockchain
}

type infoPeer: void {
  .publicKey: string
  .location: string
  .protocol: string
}

// type presi dal pdf
type Blockchain: void {
.block*: Block
}
type Block: void {
.previousBlockHash: string
.difficulty: double  //come si calcola???
.transaction*: Transaction
}
type Transaction: void {
.nodeSeller: Node
.nodeBuyer: Node
.jollar: int
}
type Node: void {
.publicKey: string
.privateKey?: string
}

//non sapevo che nome darle..
interface JollarInterface {
  RequestResponse:
    aggiungiPeer(infoPeer)(OpMessage),
    downloadBlockchain(OpMessage)(Blockchain)
  OneWay:
    invioBlockchain(OpMessage)
}
