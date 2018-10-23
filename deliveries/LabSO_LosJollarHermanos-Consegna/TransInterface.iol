type Blockchain: void {
.block*: Block
}
type Block: void {
.previousBlockHash: undefined
.difficulty: double
.transaction*: Transaction
}
type Transaction: void {
.nodeSeller: string
.nodeBuyer: string
.jollar: int
}
type Chiavi : void {
.publicKey: string
.privateKey?: string
}

interface TransInterface {
	OneWay: sender(Transaction),
			saver(Transaction),
			saveBlock(Block),
			sendChiavi(Chiavi),
			saveForBlockchain(Transaction),
			resServ(void)
}