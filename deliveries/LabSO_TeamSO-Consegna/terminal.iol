type SendTransactionReq:void{ //transazione
  .sid:string
  .transactions?:int{
    .input?:void{
      .amount?:int
      .altezzablocco?:int
      .previousUtxoTxid?:string
      .signature?:string
    }
    .output?:void{
      .payto?:string
      .amount?:int
    }
  }
}

type PushBlockReq: void {
  .sid: string
  .message?: undefined
}

interface ProxyToTerminalI {
  OneWay: sendBlock(undefined),sendTx(undefined),sendTransaction(SendTransactionReq),pushMeIndex(undefined),sendIndex(undefined)
}
type StartMessage: void{
    .sid: string
}

interface Terminal{
  OneWay: 
  sendTransaction(SendTransactionReq),
  sendBlock(undefined),
  pushMeIndex(undefined),
  sendIndex(undefined)}

interface Local {
  OneWay: 
  startTerminal(StartMessage),
  pushBlock(PushBlockReq)
}
