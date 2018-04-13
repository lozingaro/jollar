include "console.iol"

define fibonacci
{
	if( f1 < end ){
		println@Console( f1 )();
		_f2 = f1+f2;
		f1 = f2;
		f2 = _f2;
		fibonacci
	}
}

main
{
	f1 = 0;	f2 = 1;	end = 200;
	fibonacci
}