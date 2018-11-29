Zokrates is a toolbox for zkSNARKs on Ethereum. It helps you create offchain programs (zero-knowledge proofs) and link them to the Ethereum blockchain. For the sake of illustration for this blog post, we will take the example of finding the factors of a number.

There is a whole class of cryptographic/security systems which rely on what are called "trap-door functions". The idea is that they are functions which are generally easy to compute, but for which finding the inverse is very hard. One such example is the function that takes two integers and multiplies them together (something we can do very easily), versus the "inverse", which is a function that takes an integer and gives you proper factors (given n, two numbers p and q such that pq=n and 1<p,q<n). Infact RSA derives its security from this trap-door; difficulty of factoring integers that are the product of two large prime numbers. Multiplying these two numbers is easy, but determining the original prime factors is considered infeasible. Let's say you were able to break a large number being used in the RSA key and you want to _prove_ that you possess knowledge of the factors of the key - without divulging the factors themselves. We will write code enable a partipicant to do so.

First, we will setup zokrates on our local machine and run it as a docker container.
```shell
git clone https://github.com/JacobEberhardt/ZoKrates
cd ZoKrates
docker build -t zokrates .
docker run --name zokrates -ti zokrates /bin/bash
```

Now, initialize a truffle project
```shell
mkdir zksnark && cd zksnark
truffle init
```

Now, we will write the _computation_ function that a prover needs to prove (and the one that the verifier will verify) in the file [computation.code](./computation.code).

```
def main(field c, private field a, private field b) -> (field):
  field d = a * b
  c == d
  return 1
```
Here, `c` (public input) is the large number and `a, b` (private inputs) are its factors. The statement `c == d` is an assertion that infact `c` is the product of the supplied numbers `a, b`. If the assertion passes, we return 1. Now, we will walk you through using zokrates to generate the _proof of our knowledge_.
Copy the file `computation.code` to the zokrates container
```shell
docker cp computation.code zokrates:/home/zokrates/
```

We will now compile `computation.code`. `zokrates compile` takes a file written in the ZoKrates higher level language and compiles it into an arithmetic circuit.
Go to the zokrates container
```shell
./zokrates compile -i computation.code
```
The arithmetic circuit can be viewed as `cat out.code`. Because we have chosen a simple example for the computation, the circuit looks very similar to the input program.
```
def main(_2,private _3,private _4):
	_5 = (_3 * _4)
	_2 == _5
	return 1
```

Now, we generate the proving and verification keys for the computation `C`. `zokrates setup` uses a generator function to generates these keys from the arithemetic circuit and "toxic-waste" parameter lambda `(pk, vk) = G(λ, C)`.
```shell
./zokrates setup
```
You can check that 2 new files, `proving.key` and `verification.key` have been generated. The proving key can be made public for anyone to be able to generate proofs of the knowledge.

Next, we will generate a `verifier` contract that will be deployed on the ethereum blockchain. Luckily, zokrates provides this functionality out of the box.
```shell
./zokrates export-verifier
```
Using the verifying key at `./verifying.key`, it generates a Solidity contract which contains the generated verification key and a public function `verifyTx` to verify a solution to the compiled program.

Now, suppose we want to prove that we know the primes factors of the number 3512941527679. `524287 * 6700417 = 3512941527679`. For that `3512941527679` becomes our public input and its factors `524287, 6700417` are our private inputs - we don't really want to tell what these numbers are but still prove we know them! We use the `zokrates compute-witness` command for the same.

```shell
./zokrates compute-witness --interactive -a 3512941527679

<enter private inputs interactively>
Please enter a value for FlatVariable(id: 2):
524287

Please enter a value for FlatVariable(id: 3):
6700417

Computing witness ...

./zokrates generate-proof
./zokrates export-verifier
```
You can check that the proof has been generated and written to file `proof.json`. Moreover you can verify that if you enter incorrect private inputs (numbers whose product is not the given number), the proof computation will fail with error `Error { message: "Condition not satisfied: _2 should equal _5" }`.

Well, it's time to move to the blockchain world now! We will deploy the `verifier` contract generated above and try passing our proof to the `verifyTx` function to see what happens - _Will our knowledge be proven?_
The next step is to copy the contract and proof from the zokrates container to our truffle project directory.
```shell
docker cp zokrates:/home/zokrates/proof.json .
docker cp zokrates:/home/zokrates/verifier.sol contracts/.
truffle compile
truffle migrate
```

I have written a test ([verifierTest.js](./test/verifierTest.js)) that reads the proof from `proof.json` and invokes the `verifyTx` function in the verifier contract. Following that we assert that indeed our proof was (in)correct.

```shell
truffle test
```