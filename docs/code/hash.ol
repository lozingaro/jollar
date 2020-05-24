include "message_digest.iol"
include "console.iol"

main
{
  
  //...
  md5@MessageDigest( "secret" )( response )
  ;
  println@Console( response )()
  //...
}