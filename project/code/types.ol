type User: void {
  .publicKey: string
  .privateKey?: string
}

type TransactionHash: void {
  .buyer: User //remember to undef(Transaction.buyer.privateKey)
  .seller: User
  .jollar: int
}

type Transaction: void {
  .hash: TransactionHash
}

type BlockHash: void {
  .proofOfWork*: int
  .timestamp: long
  .hash: string
}

type Block: void {
  .hash: BlockHash
  .difficulty: double
  .transaction*: Transaction
}

type Blockchain: void {
  .block*: Block
}