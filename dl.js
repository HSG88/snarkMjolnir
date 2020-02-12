const zkSnark = require('snarkjs')
const babyJub = require('circomlib').babyJub
const unstringifyBigInts = zkSnark.unstringifyBigInts
const fs = require('fs');

const circDef = JSON.parse(fs.readFileSync('circuit.json'));
const circuit = new zkSnark.Circuit(circDef);
console.time("Setup");
const setup = zkSnark.original.setup(circuit);
console.timeEnd("Setup");
let x = zkSnark.bigInt('3');
let y = babyJub.mulPointEscalar(babyJub.Generator,x);
//let y2 = babyJub.mulPointEscalar(y, x);
console.time("Proof Generation")
const input = {"in":x, "out":y};
const witness = circuit.calculateWitness(input);
const {proof,publicSignals} = zkSnark.original.genProof(setup.vk_proof,witness)
console.timeEnd("Proof Generation")
console.time("Proof Verification")
const result = zkSnark.original.isValid(setup.vk_verifier,unstringifyBigInts(proof),unstringifyBigInts(publicSignals))
console.timeEnd("Proof Verification")
console.log(result?"Success":"Fail")

