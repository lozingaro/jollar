//include "console.iol"
//sadasd

type snType: void {
    .x?: void
    .y?: long
    .z?: string
}

type myType: void {
    .m?: string
}

//veccchio tipo
/*type transaction: void {
  .amount?: int
}*/


//chain per cunningamm ecccc.
type chain: void {
  .CunninghamPrimo[0,*]: void{
    .numCunP: int
  }
  .CunninghamSecondo[0,*]: void{
    .numCunS: int
  }
  .BiTwin[0,*]: void{
    .numBiTw: int
  }
  //a che cosa serve sta variabile ???
  .valid?: bool

//per passare il tipo da verificare all altro nodo/i
  .type?: string

  //chi ha creato la CATENA
  .creator?: string
}


type Blockchain: void
{
.block*: Block
}


type Block: void {
.previousBlockHash?: string
.difficulty?: double
.transaction*: Transaction
.TimeStamp?: long
}


type Transaction: void
{
.nodeSeller?: Node
.nodeBuyer?: Node
.amount?: int
.totalNetwork?: int
.totalAmount?: int
}

type Node: void
{
.publicKey?: string
.privateKey?: string
}


//PARTE NUOVA !!! per verificare quali nodi sono attivi
type activeNode: void {

.nodeA?: bool
.nodeB?: bool
.nodeC?: bool
.nodeD?: bool
.nodiAttivi?: int
.verificheTotali?: int
}


type VisualizerType: void {
  .status?: activeNode
  .transactions: Transaction
  .request: string
  // .blockchain: Block
}

type lunghezzaTipo: int {
.lunghezzaCatena?: int                  //lunghezza catena totale
.lunghezzaInviataA?: int
.lunghezzaInviataB?: int
.lunghezzaInviataC?: int
.lunghezzaInviataD?: int
}


interface Interfaccia {
  OneWay: sendInfo(VisualizerType)
	OneWay: inviaMessaggio(myType)
	RequestResponse: requestTimeStampToServer (snType)(snType)
	OneWay: sendNumber( snType )
  OneWay: sendMoney(Transaction)
  // a che serve ?????
  OneWay: inviaLung(lunghezzaTipo)
  RequestResponse: chainValidation (chain)(chain)

  RequestResponse: sendAmount(Transaction)(Transaction)

}







//define moneynowboo {
  //      println@Console("HAI ORA" + totalamount)()
//}


// Network Visualiser

// type TimestampType: void {
// 	.status:int
// }

// type StatusType: void {
// 	.key:int
// 	.version//
// 	.total:int
// 	.transactions//
// }

// type VisualiserType: void {
// 	.server:TimestampType
// 	.
// }

// interface VisualiserInterface {
//   OneWay: GlobalVisualiser(VisualiserType)
// }
