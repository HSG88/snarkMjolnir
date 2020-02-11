include "./node_modules/circomlib/circuits/comparators.circom"
include "./node_modules/circomlib/circuits/babyjub.circom"
include "./node_modules/circomlib/circuits/gates.circom"
include "./node_modules/circomlib/circuits/bitify.circom"
include "./node_modules/circomlib/circuits/escalarmulany.circom"

template DiscreteLogAny() {
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
    out[0] <== mulAny.out[0];
    out[1] <== mulAny.out[1];
}

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

template EqualElement() {
    signal input in[4];
    signal output out; 
    component eqx = IsEqual();
    component eqy = IsEqual();
    component and = AND();
    eqx.in[0] <== in[0];
    eqx.in[1] <== in[2];
    eqy.in[0] <== in[1];
    eqy.in[1] <== in[3];
    and.a <== eqx.out;
    and.b <== eqy.out;
    out <== and.out;
}

template OneOutOfMany(n) {
    signal private input in;
    signal input elements[n*2];
    signal output out;
    component eq[n];
    component or[n];
    component pk = DiscreteLogFixed();
    pk.in <== in;
    for(var i=0; i<n; i++) {
        eq[i] = EqualElement();
        or[i] = OR();        
        eq[i].in[0] <== pk.out[0];
        eq[i].in[1] <== pk.out[1];
        eq[i].in[2] <== elements[i*2];
        eq[i].in[3] <== elements[i*2+1];
        or[i].b <== eq[i].out;
        if(i==0) {
            or[i].a <== 0;
        }
        if(i>0) {
            or[i].a <== or[i-1].out;
        }
    }
    or[n-1].out ==> out;
}
template ElGamalEncryption() {
    
    signal private input m[2];
    signal private input r;
    signal input pk[2];
    signal output c[4];
 

    //rG
    component dl1 = DiscreteLogFixed();
    dl1.in <== r;
    c[0] <== dl1.out[0];
    c[1] <== dl1.out[1];
    //rPK
    component dl2 = DiscreteLogAny();
    dl2.in <== r;
    dl2.G[0] <== pk[0];
    dl2.G[1] <== pk[1];
    
    component add = BabyAdd();
    add.x1 <== m[0];
    add.y1 <== m[1];
    add.x2 <== dl2.out[0];
    add.y2 <== dl2.out[0];
    c[2] <== add.xout;
    c[3] <== add.yout;
}
template Mjolnir(n) {
    signal private input x;  //doctor secret key
    signal private input r;
    signal input pk[2];
    signal input elements[n*2];
    signal input ciphertext[4];

    component oneOutOfMany = OneOutOfMany(n);
    oneOutOfMany.in <== x;
    for(var i =0; i<n*2; i++) {
        oneOutOfMany.elements[i] <== elements[i];
    }
    oneOutOfMany.out === 1
    
    component dl = DiscreteLogFixed();
    dl.in <== x;
    
    component elGamal = ElGamalEncryption();
    elGamal.m[0] <== dl.out[0];
    elGamal.m[1] <== dl.out[1];
    elGamal.r <== r;
    elGamal.pk[0] <== pk[0];
    elGamal.pk[1] <== pk[1];
    for(var i=0; i<4; i++) {
        elGamal.c[i] === ciphertext[i];
    }
}
component main = Mjolnir(5)