const path = require("path");
const fs = require("fs");
const snarkjs = require("snarkjs");
const chai = require("chai");

const eddsa = require("../cirpedersen/src/eddsa.js");
const babyJub = require("../cirpedersen/src/babyjub.js");

const assert = chai.assert;

const bigInt = snarkjs.bigInt;

function buffer2bits(buff) {
  const res = [];
  for (let i=0; i<buff.length; i++) {
      for (let j=0; j<8; j++) {
          if ((buff[i]>>j)&1) {
              res.push(bigInt.one);
          } else {
              res.push(bigInt.zero);
          }
      }
  }
  return res;
}

async function edd() {
  const circuitDef = JSON.parse(fs.readFileSync("./circuit.json", "utf8"));
  const circuit = new snarkjs.Circuit(circuitDef);
  console.log("NConstrains EdDSA: " + circuit.nConstraints);

  const msg = Buffer.from("00010203040506070809", "hex");
  const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
  
  const pubKey = eddsa.prv2pub(prvKey);
  
  const pPubKey = babyJub.packPoint(pubKey);
  
  const signature = eddsa.sign(prvKey, msg);
  
  const pSignature = eddsa.packSignature(signature);
  const uSignature = eddsa.unpackSignature(pSignature);
  
  assert(eddsa.verify(msg, uSignature, pubKey));
  
  const msgBits = buffer2bits(msg);
  const r8Bits = buffer2bits(pSignature.slice(0, 32));
  const sBits = buffer2bits(pSignature.slice(32, 64));
  const aBits = buffer2bits(pPubKey);
  
  const w = circuit.calculateWitness({A: aBits, R8: r8Bits, S: sBits, msg: msgBits});
  console.log(w)
  assert(circuit.checkWitness(w));

}
edd();