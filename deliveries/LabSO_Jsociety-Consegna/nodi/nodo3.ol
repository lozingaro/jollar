include "console.iol"
include "if.iol"
include "semaphore_utils.iol"
include "time.iol"
include "message_digest.iol"

/* al momento non la uso, poi forse sì
inputPort Nodo3 {
  Location: "socket://localhost:9003"
  Protocol: http
  Interfaces: JollarInterface
}*/

outputPort Tracker {
  Location: "socket://localhost:9000"
  Protocol: http
  Interfaces: JollarInterface
}

init {
  publicKey = "c";
  privateKey = "cc";
  with (info) {
    .publicKey = publicKey;
    .location = "socket://localhost:9003";
    .protocol = "http"
  }
}

main
{
  aggiungiPeer@Tracker(info)(msg);
  println@Console("nodo aggiunto con successo:\n" + info.location + " " + info.protocol)()
  ;
  //se sono il primo nodo...
  if (msg.i == 1) {
    println@Console( "sono il primo nodo, creo il primo blocco" )();
    //creo il primo blocco
    with( transazione ){
      .nodeSeller.publicKey = publicKey;
      .nodeBuyer.publicKey = publicKey;
      .jollar = 6
    } |
    md5@MessageDigest("start")(hash_start);
    with(msg.blockchain.block) {
      .previousBlockHash =  hash_start;
      .difficulty = 0.25; //metto un numero a caso perché non so cos'è;
      .transaction << transazione
    };
    invioBlockchain@Tracker(msg)
  }
  //se non sono il primo nodo
  else {
      downloadBlockchain@Tracker(msg)(blockchain);
      println@Console( "ho scaricato la blockchain ")()
  }

}
