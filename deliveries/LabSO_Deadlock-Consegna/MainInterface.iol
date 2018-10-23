type Blockchain: void {
  .block*: Block
}

type Block: void {
  .previousBlockHash: string
  .difficulty: double 
  .transaction*: Transaction
  .timestamp?: string
 
}

type Transaction: void {
  .nodeSeller: Node
  .nodeBuyer: Node
  .jollar: int
  .timestamp?: long
  .date?: string
  .nodoDown?: bool
}

type Node: void {
  .publicKey: string
  .privateKey?: string
  .location?: string
}

type FermatType: void { 
  .primoFermat: bool 
  .nodoID: int  
  .stampaEsitoPrimo: string 
}

type PowType: void{
  .x: int
  .y: int
}

type PowResponseType: void{
  .difficulty: double
  .validita: bool
}

type RequestBlCh:void {
  .block: Block
  .nomefileBlCh: string
}

type GetDateTimeRequest: long { 
    .format?: string
}

type NuovoNodoType: void {
  .nato: bool
  .jollarGenesis: int
}

type NodoDaControllare: void {
  .location: string
  .numeroBlocchi?: int
}

type InfoNodo: void {
  .chiavePubblicaNodo: string
  .transaction: Transaction
}

type InfoJollarNodo: void {
  .idNodoJ: string
  .jollarNodo: int
}

interface BroadcastInterface {
  RequestResponse: sonoNato(string)(NuovoNodoType), richiestaBlockchainNodi(void)(NodoDaControllare)
  OneWay: invioTrans(Transaction), broadcastTrans(Transaction),  memorizzaNodo(string), checkBlChCorretta(NodoDaControllare), inviaNumBlocchi(NodoDaControllare), checkNodoAttivo(void),richiestaInfoNodo(void)
}

interface PowInterface {
   RequestResponse: givePoW(PowType)(PowResponseType)
}

interface BlockchainInterface {
   RequestResponse: updateBlCh(RequestBlCh)(bool), contaBlocchiBlCh(string)(int) 
}

interface TimestampInterface {  
  RequestResponse: TimeRequestResponse(string)(long) 
}

interface DateInterface{
  RequestResponse: DateRequestResponse(GetDateTimeRequest)(string)              
}

interface GenesisInterface {
  RequestResponse: createGenesis(string)(bool)
}

interface NetInterface {
  RequestResponse: possoPartire(string)(void)
  OneWay: invioInfoNodo(InfoNodo), richiestaInfoBroadcast(void),rispostaNumeroBlocchi(NodoDaControllare),  invioJollarNodo(InfoJollarNodo)

}