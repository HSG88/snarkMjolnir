const zkSnark = require('snarkjs')
const compiler = require('circom')
const babyJub = require('circomlib').babyJub
const stringifyBigInts = zkSnark.stringifyBigInts
const unstringifyBigInts = zkSnark.unstringifyBigInts
const fs = require('fs');

index = 1;
let pks = [];
let sk = [];
let n =25;
for(let i=1; i<=n; i++) {
    sk[i] = zkSnark.bigInt(i.toString());
    pks[i] = babyJub.mulPointEscalar(babyJub.Generator,sk[i]);
}
let patientPK = babyJub.mulPointEscalar(babyJub.Generator,zkSnark.bigInt((n*n).toString()));
let r = zkSnark.bigInt('244');
let c1 = babyJub.mulPointEscalar(babyJub.Generator, r)
let c2 = babyJub.mulPointEscalar(patientPK,r)
c2 = babyJub.addPoint(pks[index],c2);
let c = [c1,c2].flat();
let elements = pks.flat();
const input = {"x":sk[index], "r":r, "pk":patientPK, "elements":elements, "ciphertext":c}; 
fs.writeFileSync("input.json",JSON.stringify(stringifyBigInts(input)))
const circDef = JSON.parse(fs.readFileSync('circuit.json'));
const circuit = new zkSnark.Circuit(circDef);
console.time("Setup");
const setup = zkSnark.original.setup(circuit);
console.timeEnd("Setup");

console.time("Proof Generation")
const witness = circuit.calculateWitness(input);
const {proof,publicSignals} = zkSnark.original.genProof(setup.vk_proof,witness)
console.timeEnd("Proof Generation")
console.time("Proof Verification")
result = zkSnark.original.isValid(setup.vk_verifier,unstringifyBigInts(proof),unstringifyBigInts(publicSignals))
console.timeEnd("Proof Verification")
console.log(result?"Success":"Fail")

