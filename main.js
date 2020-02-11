const zkSnark = require('snarkjs')
const compiler = require('circom')
const babyJub = require('circomlib').babyJub
const stringifyBigInts = zkSnark.stringifyBigInts
const unstringifyBigInts = zkSnark.unstringifyBigInts
const fs = require('fs');
const circDef = JSON.parse(fs.readFileSync('circuit.json'));
const circuit = new zkSnark.Circuit(circDef);
console.time("Setup");
const setup = zkSnark.original.setup(circuit);
console.timeEnd("Setup");
let pks = [];
let sk = [];
let n =5;
for(let i=0; i<n; i++) {
    sk[i] = zkSnark.bigInt(i.toString());
    pks[i] = babyJub.mulPointEscalar(babyJub.Base8,sk[i]);
}
let elements = pks.flat();

//const input = {"in":sk[0], "elements":elements}; //valid input
const input = {"in":zkSnark.bigInt(n.toString()), "elements":elements}; //invalid proof input

console.time("Proof Generation")
const witness = circuit.calculateWitness(input);
const {proof,publicSignals} = zkSnark.original.genProof(setup.vk_proof,witness)
console.timeEnd("Proof Generation")
console.time("Proof Verification")
result = zkSnark.original.isValid(setup.vk_verifier,unstringifyBigInts(proof),unstringifyBigInts(publicSignals)))
console.timeEnd("Proof Verification")
console.log(result?"Success":"Fail")

