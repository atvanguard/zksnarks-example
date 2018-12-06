https://iden3.io/blog/circom-and-snarkjs-tutorial2.html
```shell
export CIRCUIT=diffieHellman

cd snarkjs

circom circuits/$CIRCUIT.circom -o circuit.json
snarkjs info -c circuit.json

// generate proving_key.json and verification_key.json
snarkjs setup -c circuit.json

// generate witness.json
snarkjs calculatewitness -i inputs/$CIRCUIT.json

// This command will use the prooving_key.json and the witness.json files by default to generate proof.json and public.json
snarkjs proof

// This command will use verification_key.json, proof.json and public.json to verify that is valid.
snarkjs verify

// Generate the solidity verifier
snarkjs generateverifier
```

### eddsaVerifier
```shell
circom circuits/eddsaVerifier.circom -o circuit.json
```