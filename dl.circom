include "./node_modules/circomlib/circuits/comparators.circom"
include "./node_modules/circomlib/circuits/babyjub.circom"
include "./node_modules/circomlib/circuits/gates.circom"
include "./node_modules/circomlib/circuits/bitify.circom"
include "./node_modules/circomlib/circuits/escalarmulany.circom"

template DiscreteLog() {
    signal private input in; 
    signal input G[2];
    signal output out[2];

    component pvkBits = Num2Bits(256);
    pvkBits.in <== in;
    component mulAny = EscalarMulAny(256);
    mulAny.p[0] <== G[0];
    mulAny.p[1] <== G[1];

    var i;
    for (i=0; i<256; i++) {
        mulAny.e[i] <== pvkBits.out[i];
    }
    out[0]  <== mulAny.out[0];
    out[1]  <== mulAny.out[1];
}
component main = DiscreteLog();