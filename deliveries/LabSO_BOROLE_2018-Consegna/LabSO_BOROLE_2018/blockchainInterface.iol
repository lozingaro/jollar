// Definizione dei vari data types all'interno dell'interfaccia 

type Blockchain : void {
	.block* : Block | GenesisBlock
}

type Block : void {
	.id_block : int
	.hashBlock : string 
	.previousBlockHash : string
	.difficulty : double 
	.transaction : Transaction 
	.lunghezzaCatena : int
}

type Transaction : void {
	.hash_transaction : string
	.nodeSeller : string 
	.nodeBuyer : string
	.jollar : int 
	.timestamp : string
}

type GenesisBlock : void {
	.id_block_G : int
	.hashBlock_G : string 
	.previousBlockHash_G : string
	.difficulty_G : int 
}

type Node : void {
	.id_node : string
	.publicKey : string
	.privateKey? : string
	.numeroJollar : int
}

// Definizione dell'interfaccia con i relativi servizi One-Way e Request-Response

interface BlockchainInterface
{

	OneWay:

	informazioniNodo1(Node),
	informazioniNodo2(Node),
	informazioniNodo3(Node),
	informazioniNodo4(Node),

	invioInformazioniNodo1(Node),
	invioInformazioniNodo2(Node),
	invioInformazioniNodo3(Node),
	invioInformazioniNodo4(Node),

	numeroJollarNodo1(int),
	numeroJollarNodo2(int),
	numeroJollarNodo3(int),
	numeroJollarNodo4(int),

	invioHashBloccoGenesis(string),
	riceviBlocco(Block),
	invioBlockchain(Blockchain),
	nodoConnesso(string),
	inizioPOW(string),
	fineSemaforo(string),
	blockchainAttuale(Blockchain),
	invioBlockchainNetwork(Blockchain),

	richiestaNumeroJollarNodo1(int),
	richiestaNumeroJollarNodo2(int),
	richiestaNumeroJollarNodo3(int),
	richiestaNumeroJollarNodo4(int)

		
	RequestResponse: 
		

	richiestaInformazioniNodo1(string)(Node),
	richiestaInformazioniNodo2(string)(Node),
	richiestaInformazioniNodo3(string)(Node),
	richiestaInformazioniNodo4(string)(Node),

	creaBloccoDopoTransazione(Transaction)(string),
	nuovaTransazione(Transaction)(int),
	numeroTransazioniBlocco(Block)(int),
	lunghezzaPOW(Node)(int),
	serverTimestamp(string)(string),
	finePOW(string)(string),
	richiediBloccoValidato(string)(Block),
	invioBlocco(Block)(string),

}

/*interface NetworkVisualizer {
  OneWay: 
  RequestResponse: 
}
*/