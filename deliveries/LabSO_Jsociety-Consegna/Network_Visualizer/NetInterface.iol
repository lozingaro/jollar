type clientType:void{
	.name:string
	.value:int
}

type netVisualType: void{
.nodoA:long
.nodoB:long
.nodoC:long
.nodoD:long
}

interface NetInterface {
	RequestResponse: 
	sendACK(clientType)(int),
	receiveTime(long)(void),
	netVisualRequest(int)(void),
	sendTimeStamp(netVisualType)(void)
	
}
	