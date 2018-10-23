interface CreateWalletInterface {
    RequestResponse:    CreateWall( undefined )( string )

}
outputPort CreateWallet {
    Interfaces: CreateWalletInterface
}

embedded {
    Java:     "wallet.CreateWallet" in CreateWallet
}