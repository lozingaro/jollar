include "types/Binding.iol"

interface WriterInterface {
  OneWay: subscribeForWrite( Binding ), wakeForWrite( void )
  RequestResponse: write( string )( void )
}

interface ReaderInterface {
  RequestResponse: read( void )( string )
}