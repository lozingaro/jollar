type Blockchain: void {
  .block*: Block
}

type Block: void {
  .previousBlockHash: string
  .difficulty: double
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