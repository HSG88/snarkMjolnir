const zkSnark = require('snarkjs')
const compiler = require('circom')
const babyJub = require('circomlib').babyJub
const stringifyBigInts = zkSnark.stringifyBigInts
const unstringifyBigInts = zkSnark.unstringifyBigInts
const fs = require('fs');
const circDef = JSON.parse(fs.readFileSync('circuit.json'));
const circuit = new zkSnark.Circuit(circDef);
const setup = zkSnark.original.setup(circuit);
const strSetup = stringifyBigInts(setup);
fs.writeFileSync("pk.json", JSON.stringify(stringifyBigInts(strSetup.vk_proof)), "utf-8");
fs.writeFileSync("vk.json", JSON.stringify(stringifyBigInts(strSetup.vk_verifier)), "utf-8");



let sk1 = zkSnark.bigInt('3');
let sk2 = zkSnark.bigInt('4')
let sk3 = zkSnark.bigInt('5')
let pk1 = babyJub.mulPointEscalar(babyJub.Base8,sk1)
let pk2 = babyJub.mulPointEscalar(babyJub.Base8,sk2)
const input = {"in":sk3, "Ax":pk2[0], "Ay":pk2[1], "Bx":pk1[0], "By":pk1[1]};
fs.writeFileSync('input.json',JSON.stringify(stringifyBigInts(input)),"utf-8")
const witness = circuit.calculateWitness(input);


const pk = unstringifyBigInts(JSON.parse(fs.readFileSync("pk.json","utf8")));
const vk = unstringifyBigInts(JSON.parse(fs.readFileSync("vk.json","utf8")))
const {proof,publicSignals} = zkSnark.original.genProof(pk,witness)




if(zkSnark.original.isValid(vk,unstringifyBigInts(proof),unstringifyBigInts(publicSignals)))
    console.log("Valid proof")
else
    console.log("Invalid proof")
//console.log(publicSignals);

