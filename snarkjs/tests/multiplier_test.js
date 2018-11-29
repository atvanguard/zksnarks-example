const zkSnark = require("snarkjs");
const fs = require("fs");

// compile computation beforehand
// export CIRCUIT=computation
// CLI: circom circuits/$CIRCUIT.circom -o circuit.json

const circuitDef = JSON.parse(fs.readFileSync("./circuit.json", "utf8"));
const circuit = new zkSnark.Circuit(circuitDef);

// generate proving_key.json and verification_key.json
// CLI: snarkjs setup -c circuit.json
const setup = zkSnark.groth.setup(circuit);

// TypeError: Do not know how to serialize a BigInt
// fs.writeFileSync("proving_key.json", JSON.stringify(setup.vk_proof), "utf8");
// fs.writeFileSync("verification_key.json", JSON.stringify(setup.vk_verifier), "utf8");

// snarkjs calculatewitness -i inputs/$CIRCUIT.json
const input = {
    "a": 524287,
    "b": 6700417,
    "c": 3512941527679
}

const witness = circuit.calculateWitness(input);
console.log('witness', witness)

// const vk_proof = JSON.parse(fs.readFileSync("./proving_key.json", "utf8"));
// const {proof, publicSignals} = zkSnark.genProof(vk_proof, witness);

// const vk_verifier = JSON.parse(fs.readFileSync("./verification_key.json", "utf8"));

const {proof, publicSignals} = zkSnark.groth.genProof(setup.vk_proof, witness);

if (zkSnark.groth.isValid(setup.vk_verifier, proof, publicSignals)) {
    console.log("The proof is valid");
} else {
    console.log("The proof is not valid");
}
