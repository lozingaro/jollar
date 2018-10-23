type chiavi: void {
.publicKey: string
.privateKey?: string
}

interface InterfaceChiavi {
    RequestResponse: getChiavi (void)( chiavi )                
}