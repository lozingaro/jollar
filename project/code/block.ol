type Block: void {
  .previousBlockHash: string
  .difficulty: double
  .transaction*: Transaction
}