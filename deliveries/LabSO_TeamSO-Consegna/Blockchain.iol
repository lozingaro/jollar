/*
Blockchain.iol
*/
type Utxo: void {
  .result[0,*]: string
}
interface BlockchainInterface {
	OneWay:
	setUser(string),
	addValidBlock(undefined),
	writeBlockchain(undefined)
	  RequestResponse: 
	  readPublicKey(string)(string),
	  readPrivateKey(string)(string),
	  readBlockChain(string)(undefined),
	  existOrigin(int)(bool),
	  getDifficulty(int)(double),
	  getUtxo(undefined)(Utxo),
	  getBlockHash(undefined)(string),
	  trovaAltezza(string)(undefined),
	  getLastBlockIndex(void)(int),
	  startBlockchain(string)(undefined),
	  checkIfUnspent(undefined)(bool)
	  }

