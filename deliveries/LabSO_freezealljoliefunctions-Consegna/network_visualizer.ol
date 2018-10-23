include "console.iol"
include "nodo_interface.iol"
include "time.iol"

// porta per connettersi a nodi e server di timestamp

outputPort Contact {
	Protocol: sodep
	Interfaces: Nodo_interface
}

// metodo per scaricare blockchain più lunga

define getBlockchain
{
  max = 0;
  if (#listaPorte.porta == 0) {
    println@Console("La lista delle locations e' vuota")()
  } else {
    for (j = 0, j < #listaPorte.porta, j++)
      {
           Contact.location = listaPorte.porta[j];
           getBlockchain@Contact()(blockchain);
           blockchainRetrieved[j] << blockchain
      };
      for (j = 0, j < #listaPorte.porta, j++)
      {
          if (#blockchainRetrieved[j].block > max) {
            max = #blockchainRetrieved[j].block;
            blockchain << blockchainRetrieved[j]
          }
      };
      println@Console("Ho scaricato la blockchain piu' lunga!")()
    }
}

main {

	registerForInput@Console()();
	println@Console("Scrivi qualcosa per visualizzare lo stato della rete")();
	in(risposta);

	// contatto timestamp server per avere lista dei nodi online

	Contact.location = "socket://localhost:9000";

	getLocations@Contact()(listaPorte);
	for (j = 0, j < #listaPorte.porta, j++)
	{
		println@Console(listaPorte.porta[j])()
	};

	getTimestamp@Contact()(timestamp);

	// scarico blockchain più lunga

	getBlockchain;

	// aggiorno i bilanci di ogni nodo scorrendo la blockchain
	// aggiungo 6 jollar di reward ai nodi che hanno generato un blocco (poi aggiunto nella blockchain)

	for (j = 0, j < #listaPorte.porta, j++)
	{
		for (k = 0, k < #blockchain.block, k++)
		{
			if (blockchain.block[k].nodoGeneratore == listaPorte.porta[j])
			{
				balance[j] = balance[j] + 6
			};
			if (blockchain.block[k].transaction.nodeBuyer == listaPorte.porta[j])
			{
				balance[j] = balance[j] - blockchain.block[k].transaction.jollar
			};
			if (blockchain.block[k].transaction.nodeSeller == listaPorte.porta[j])
			{
				balance[j] = balance[j] + blockchain.block[k].transaction.jollar
			}
		}
	};

	for (j = 0, j < #listaPorte.porta, j++)
	{
		println@Console("Il bilancio del nodo " + listaPorte.porta[j] + " e' di " + balance[j] + " jollar")()
	};

	// calcolo totale jollar in circolo

	for (j = 0, j < #listaPorte.porta, j++)
	{
		totale = totale + balance[j]
	};

	println@Console("Il totale dei jollar presenti sulla rete e' " + totale)();

	// stampo elenco dettagliato transazioni

	for (k = 1, k < #blockchain.block, k++)
	{
		println@Console("Transazione numero " + k + ":")();
		println@Console("Il nodo " + blockchain.block[k].transaction.nodeBuyer + " ha inviato " + blockchain.block[k].transaction.jollar + " jollar al nodo " + blockchain.block[k].transaction.nodeSeller)()
	}

}