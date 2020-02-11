include "./node_modules/circomlib/circuits/comparators.circom"
include "./node_modules/circomlib/circuits/babyjub.circom"
include "./node_modules/circomlib/circuits/gates.circom"

template EqualElement() {
    signal input Ax;
    signal input Ay;
    signal input Bx;
    signal input By;
    signal output out; 
    component eqx = IsEqual();
    component eqy = IsEqual();
    component and = AND();
    eqx.in[0] <== Ax;
    eqx.in[1] <== Bx;
    eqy.in[0] <== Ay;
    eqy.in[1] <== By;
    and.a <== eqx.out;
    and.b <== eqy.out;
    out <== and.out;
}

template OneOutOfMany() {
    signal private input in;
    signal         input Ax;
    signal         input Ay;
    signal         input Bx;
    signal         input By;
    
    component Pbk = BabyPbk();   
    component eq1 = EqualElement();    
    Pbk.in <== in;
    eq1.Ax <== Pbk.Ax;
    eq1.Ay <== Pbk.Ay;
    eq1.Bx <== Ax;
    eq1.By <== Ay;
    component eq2 = EqualElement();    
    eq2.Ax <== Pbk.Ax;
    eq2.Ay <== Pbk.Ay;
    eq2.Bx <== Bx;
    eq2.By <== By;
    component or = OR();
    or.a <== eq1.out;
    or.b <== eq2.out;
    or.out <== 1;
}
component main = OneOutOfMany()