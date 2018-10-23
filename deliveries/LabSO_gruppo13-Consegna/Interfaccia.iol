type Nodo: void {
 .id: int
  .publicKey: string
  .privateKey: string
  .jollarPosseduti ? : int
}

type Transaction: void {
 .hashTransazione: string
  .nodeSeller ? : int
  .nodeBuyer: string
  .jollar: int
}

type Block: void {
 .id_blocco: int
  .previousBlockHash ? : string
  .blockHash ? : string
  .difficulty ? : double
  .lunghezzaProofOfWork ? : int
  .transaction ? : Transaction
  .timestamp: undefined
  .firma ? : string
}

type Blockchain: void {
 .block * : Block
}

interface InterfacciaJollar {

 //SERVIZI PER IL COLLEGAMENTO DEI NODI
 OneWay: collegamentoNodo1(Nodo)
 OneWay: collegamentoNodo2(Nodo)
 OneWay: collegamentoNodo3(Nodo)
 OneWay: collegamentoNodo4(Nodo)
 OneWay: invioHashGenesi(string)
 OneWay: nodiCollegati(undefined)
 OneWay: invioBlockchain(Blockchain)
 OneWay: blockchainScaricata(string)
 OneWay: proofOfWork(string)
 OneWay: idNodo(int)
 OneWay: invioBlockchainAggiornata(Blockchain)
 OneWay: continuare(string)
 OneWay: netConnesso(string)
 OneWay: fine(string)
 OneWay: jollarTotali(undefined)
 OneWay: fine2(string)


 RequestResponse: nuovaTransazione(Transaction)(undefined)
 RequestResponse: creazioneBloccoPrimo(Transaction)(undefined)
 RequestResponse: creazioneBloccoSecondo(Transaction)(undefined)
 RequestResponse: creazioneBloccoTerzo(Transaction)(undefined)
 RequestResponse: proofOfWorkTerminata(int)(string)

}