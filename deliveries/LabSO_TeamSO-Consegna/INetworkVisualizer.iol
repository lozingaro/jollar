interface INetworkVisualizer {
  OneWay: print(undefined)
}

outputPort NetworkVisualizer {
	Location: "socket://localhost:8055"
	Protocol: sodep
	Interfaces: INetworkVisualizer
}