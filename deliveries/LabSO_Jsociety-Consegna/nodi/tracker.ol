include "console.iol"
include "if.iol"
include "semaphore_utils.iol"

inputPort Tracker {
Location: "socket://localhost:9000"
Protocol: http
Interfaces: JollarInterface
}

//insieme di correlazione, contiene un id per "non fare confusione tra i client e behaviour"
cset {
  sid: OpMessage.sid
}

execution{ concurrent }

init {
  with(global.listaPeer.nodo) {
    .publicKey = "start";
    .location = "socket://localhost:9000";
    .protocol = "http"
  };
  global.rw_mutex.name = "rw_mutex";
  global.r_mutex.name = "r.mutex";
  release@SemaphoreUtils(global.r_mutex)()
}

main {
  aggiungiPeer(peer)(risp) {
    synchronized( token ){
      i = #global.listaPeer.nodo;
      with(global.listaPeer.nodo[i]) {
        .publicKey = peer.publicKey;
        .location = peer.location;
        .protocol = peer.protocol
      };
      risp.i = i;
      risp.sid = csets.sid = new
    }
  }
  ;

  {
    {
      invioBlockchain(msg);
      global.blockchain << msg.blockchain;
      // incremento il semaforo solo dopo che è stato scritto il primo blocco
      // così i nodi successivi scaricheranno una blockchain non vuota
      release@SemaphoreUtils(global.rw_mutex)()
    }
    |
    {
      //è simile al problema reader-writer
      downloadBlockchain(info)(bc) {
        acquire@SemaphoreUtils(global.r_mutex)();
        global.read_count++;
        if (global.read_count == 1) {
          acquire@SemaphoreUtils(global.rw_mutex)()
        };
        release@SemaphoreUtils(global.r_mutex)();
        //scarico la blockchain
        bc << global.blockchain;
        acquire@SemaphoreUtils(global.r_mutex)();
        global.read_count--;
        if (global.read_count == 0) {
          release@SemaphoreUtils(global.rw_mutex)()
        };
        release@SemaphoreUtils(global.r_mutex)()
      }
    }
  }
}
