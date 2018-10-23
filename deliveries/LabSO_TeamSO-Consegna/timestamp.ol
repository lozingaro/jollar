//Timestamp.ol
include "time.iol"

inputPort Local {
	Location: "local"
	Protocol: sodep
	RequestResponse: getTime(void)(long),getDate(void)(string)
}

execution{ concurrent}
main
{
  [getTime(void)(res){
  	getCurrentTimeMillis@Time()( res )
  }]
  [getDate(void)(res){
  	getCurrentDateTime@Time()(res)
  }]
}