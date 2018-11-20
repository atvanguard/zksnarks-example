const zkSnark = require("snarkjs");
const fs = require("fs");

const circuitDef = JSON.parse(fs.readFileSync("./circuit.json", "utf8"));
const circuit = new zkSnark.Circuit(circuitDef);
const setup = zkSnark.groth.setup(circuit);

const input = {
    "a": "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",
    "b": "0x0000000000000000000000000000000000000000000000000000000000000011"
}

let c = BigInt(input.a) + BigInt(input.b)
console.log(c.toString(16))

const witness = circuit.calculateWitness(input);
// console.log(witness.slice(1, 257).join(''))
console.log(binToHex(witness.slice(1, 257)))


// fs.writeFileSync("myCircuit.vk_proof", JSON.stringify(setup.vk_proof), "utf8");
// fs.writeFileSync("myCircuit.vk_verifier", JSON.stringify(setup.vk_verifier), "utf8");
// const vk_proof = JSON.parse(fs.readFileSync("proving_key.json", "utf8"));
// const {proof, publicSignals} = zkSnark.groth.genProof(setup.vk_proof, witness);
// console.log(publicSignals, proof)
// console.log(witness[256], witness[257], witness[258], witness[259])
// console.log(Buffer.from(witness[1].toString()).toString('hex'))

function binToHex(bits) {
    // bignumber ftw
    let ans = BigInt(0);
    let pow2 = BigInt(1);
    for(let i=0; i<bits.length; i++) {
        if (bits[i]) ans += (pow2)
        pow2 *= BigInt(2);
    }
    return ans.toString(16)
}

// console.log(binToHex([1, 1, 1, 1 ,1]))