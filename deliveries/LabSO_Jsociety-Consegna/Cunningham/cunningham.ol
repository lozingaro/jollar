include "time.iol"
include "console.iol"
include "converter.iol"
include "math.iol"


init{
	numeroScelto = 10;
	p[1] = 2
}

main {
	println@Console( "Catene di Cunningham")();
	println@Console( "Stampo p[1]: " + p[1])();
	for ( i = 2, i < numeroScelto, i++) {
		op.base = 2;
		op.exponent = (i - 1);
		pow@Math(op)(potenza);
		p[i] = potenza * p[1] + (potenza - 1);
		println@Console( "Stampo p["+i+"]: " + p[i])()
	}
}
