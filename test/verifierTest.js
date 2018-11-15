const verifier = artifacts.require("verifier");
const fs = require('fs');
 
contract('verifier', function(accounts) {
  it('verifyTx', async function() {
    const proofJson = JSON.parse(fs.readFileSync('./proof.json', 'utf8'));
    const proof = proofJson.proof;
    const _proof = [];
    Object.keys(proof).forEach(key => _proof.push(proof[key]));
    _proof.push(proofJson.input)
    
    let instance = await verifier.deployed();
    console.log('calling verifyTx with proof', _proof);
    const success = await instance.verifyTx.call(..._proof);
    assert(success);
  })

  it('verifyTx should fail for wrong public input', async function() {
    const proofJson = JSON.parse(fs.readFileSync('./proof.json', 'utf8'));
    const proof = proofJson.proof;
    const _proof = [];
    Object.keys(proof).forEach(key => _proof.push(proof[key]));

    // alter public input
    const publicInput = proofJson.input;
    publicInput[0] = 7;
    _proof.push(publicInput)
    
    let instance = await verifier.deployed();
    console.log('calling verifyTx with proof', _proof);
    const success = await instance.verifyTx.call(..._proof);

    // assert that proof wasn't correctly verified
    assert(!success);
  })
})