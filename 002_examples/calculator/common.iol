type SumRequest:void {
	.x:int
	.y:int
}

interface CalculatorInterface {
RequestResponse:
	sum(SumRequest)(int)
}
