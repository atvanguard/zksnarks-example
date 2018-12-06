const compiler = require("circom");
const path = require("path");

async function edd() {
  // const cirDef = await compiler(path.join(__dirname, "circuits", "eddsa_test.circom"));
  const cirDef = await compiler(path.join("/Users/arpit/projects/zksnark/snarkjs/pedersen_circuits", "eddsa_component.circom"));
  
  circuit = new snarkjs.Circuit(cirDef);
  console.log("NConstrains EdDSA: " + circuit.nConstraints);
}
edd();