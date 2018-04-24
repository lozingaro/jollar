type Block: void {
  .hash: string
  .difficulty: double
  .transaction*: Transaction
}