interface CateneInterface {
    RequestResponse:    checkPrime( int )( int ),checkChain( int )(int),difficolta(int)(double)

}
outputPort Catene {
    Interfaces: CateneInterface
}

embedded {
    Java:     "catene.catened" in Catene
}




