type Chiavi: void {
  .publicKey: string
  .privateKey: string
}

type FirmaRequest: void {
  .plaintext: string
  .privateKey: string
}

type VerificaRequest: void {
  .plaintext: string
  .publicKey: string
  .ciphertext: string
}

interface MyUtilInterface {
  RequestResponse:
    generaChiavi(void)(Chiavi),
    firma(FirmaRequest)(string),
    verifica(VerificaRequest)(bool)
}
