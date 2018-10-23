type clientType:void{
	.name:string
	.value:int
}

interface TimeInterface {
	RequestResponse: 
	sendACK(clientType)(int),
	receiveTime(long)(void) 
}