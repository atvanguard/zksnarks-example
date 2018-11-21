const zkSnark = require("snarkjs");
const fs = require("fs");

const circuitDef = JSON.parse(fs.readFileSync("./circuit.json", "utf8"));
const circuit = new zkSnark.Circuit(circuitDef);

const input = {
    p1: [1, 2],
    p2: [3, 4]
}

const witness = circuit.calculateWitness(input);
console.log(witness)