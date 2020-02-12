include "./node_modules/circomlib/circuits/comparators.circom"
include "./node_modules/circomlib/circuits/babyjub.circom"
include "./node_modules/circomlib/circuits/gates.circom"
include "./node_modules/circomlib/circuits/bitify.circom"
include "./node_modules/circomlib/circuits/escalarmulany.circom"

template DiscreteLogFixed() {
    signal private input in; 
    signal output out[2];

    component pvkBits = Num2Bits(256);
    pvkBits.in <== in;
    component mulAny = EscalarMulAny(256);
    mulAny.p[0] <== 995203441582195749578291179787384436505546430278305826713579947235728471134;
    mulAny.p[1] <== 5472060717959818805561601436314318772137091100104008585924551046643952123905;

    var i;
    for (i=0; i<256; i++) {
        mulAny.e[i] <== pvkBits.out[i];
    }
    out[0] <== mulAny.out[0];
    out[1] <== mulAny.out[1];
}

component main = DiscreteLogFixed();