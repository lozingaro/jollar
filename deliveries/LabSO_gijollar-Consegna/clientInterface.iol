
type autenticazione: void{
  .clientID: string
  .pkClient: string
}

type Blockchain: void{
  .block[0,*]: Block
}

type Block: void{
  .transaction: Transaction
  .catena: Chain
  .time: long
  .clientS: Node
  .id : string
  .previousId : string
  .difficulty : double
}

type ackBlock: void{
  .block: Block
  .isOk: string
}

type Chain: void{
  .numeriPrimi[0,*]: int
  .lunghezza: int
}

type Transaction: void{
  .nodeSellerID: Node
  .nodeBuyerID: Node
  .jollar: int
  .time: long
  .id: string
}

type Node: void{
  .publicKey: string
  .privateKey?: string
}

type Info: void{
  .pkClient: string
  .saldo: int
  .entrate?: Entrate
  .uscite?: Uscite
  .blockchain: Blockchain
}

type Entrate: void{
  .transaction[0,*] : Transaction
}
type Uscite: void{
  .transaction[0,*]: Transaction
}
type ackTr: void{
  .messaggio: string
  .transaction: Transaction
}
type mySaldo: void{
  .client: int
  .saldo: int
}
type Lista: void{
  .listaBlockchain[0,*]: Blockchain
}

interface ClientInterface{
  OneWay : sendTransaction ( Transaction ),
           ackSendTransaction ( ackTr ),
           sendKey ( autenticazione ),
           sendBlock ( Block ),
           ackSendBlock ( ackBlock ),
           sendSaldo(mySaldo),
           write(Block),
  RequestResponse: requestTime(void)(long),
                   requestDate(void)(string),
                   requestData(void)( Info ),
                   getBlockchain(void)(Blockchain),
                   sincro(void)(Lista),
                   validationTr(Transaction)(string)
}
