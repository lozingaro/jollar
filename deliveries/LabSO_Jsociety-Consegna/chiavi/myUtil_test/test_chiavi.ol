include "MyUtilInterface.iol"
include "console.iol"

outputPort MyKeyUtil {
Interfaces: MyUtilInterface
}

embedded {
  Java: "myUtil.MyKeyUtil" in MyKeyUtil
}

main {
  //genero le chiavi
  generaChiavi@MyKeyUtil()(keys);
  println@Console( "Public: \n" + keys.publicKey)();
  println@Console( "Private: \n" + keys.privateKey )();

  //firmo un messaggio
  firmareq.privateKey = keys.privateKey;
  firmareq.plaintext = "messaggio in chiaro";
  firma@MyKeyUtil(firmareq)(cipher);
  println@Console( "cipher \n" + cipher )();

  //verifico che il messaggio firmato corrisponda a quello in chiaro
  req.ciphertext = cipher;
  req.plaintext = "messaggio in chiaro";
  req.publicKey = keys.publicKey;
  verifica@MyKeyUtil(req)(verificato);
  println@Console( "La verifica e': " + verificato )()
}
