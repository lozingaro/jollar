include "console.iol"
include "time.iol"
main
{
scope( scope_name )
{
 println@Console( "step 1" )();
 sleep@Time( 1 )();
 install( this => 
  println@Console( "rec step 1" )() );

 println@Console( "step 2" )();
 sleep@Time( 1 )();
 install( this => 
  println@Console( "rec step 2" )();  cH ) ;

 println@Console( "step 3" )();
 sleep@Time( 1 )();
 install( this => 
  println@Console( "rec step 3" )() ; cH );

 println@Console( "step 4" )();
 install( this => 
  println@Console( "rec step 4" )() ); cH
}
|
{sleep@Time( 1 )(); throw( a_fault )}
}