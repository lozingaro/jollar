include "time.iol"

main
{   
  //...
  getCurrentTimeMillis@Time()( millis )
  ;
  block.timestamp = millis
  //...
}