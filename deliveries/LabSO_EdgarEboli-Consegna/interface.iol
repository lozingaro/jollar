type RichiestaMs: any  

type Keys : any{
	.n:int
	.e:int
}

type TransType: void{
	.publicKeySeller*:undefined
	.publicKeyBuyer*:undefined
	.jollar:any
	.peerID?:string
	.transID?:string
	.signature?: string
}

type CloseBroad: void{
	.sessToken:string
}

type Block: any{
	.hash:string
	.prevHash?: any
	.requester?:string
	.indexOf:int
	.chain*: any
	.time:any
	.difficulty: any
	.transaction[0,10]: TransType
}
type BlockChain: any{
	.blockchain?:bool
	.block[0,100]: Block
	.peerID?:string
	.sessToken?:string
}
type Ask: any{
	.sessToken?:string
	.n?:any
	.e?:any
}
type Versione: any{
	.num: int
	.owner: string
	.bk : BlockChain
}

type ReqKey: any{
	.key*: any
	.owner: string
}


interface InterfaceBroadcasting {
	OneWay: incominTrans(TransType),newTrans(TransType),close(CloseBroad), validAsk(Block), writeBlock(Block),print(void)
	RequestResponse: askChain(Ask)(BlockChain), peerOnline(undefined)(BlockChain), validation(Block)(bool), timeRequest(void)(RichiestaMs), askKey(void)(ReqKey), askVersion(void)(Versione)
}


