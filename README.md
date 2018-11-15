### 1. Run zokrates
```shell
git clone https://github.com/JacobEberhardt/ZoKrates
cd ZoKrates
docker build -t zokrates .
docker run --name zokrates -ti zokrates /bin/bash
```

### 2. Start truffle project
```shell
mkdir zksnark && cd zksnark
truffle init
```
Now, add the computation that a prover needs to prove (and the one that the verifier will verify) in the file `computation.code`.

### 3. Generate zero-knowledge proof of the computation
Copy the file `computation.code` to the zokrates container
```
docker cp computation.code zokrates:/home/zokrates/
```
Go to the zokrates container
```shell
./zokrates compile -i computation.code
./zokrates setup
./zokrates compute-witness --interactive -a 6
<enter private inputs>
```

### 4. Copy `proof.json` and `verifier.sol` from the zokrates container to the truffle project
```shell
docker cp zokrates:/home/zokrates/proof.json .
docker cp zokrates:/home/zokrates/verifier.sol contracts/.
```

### 5. Assert that `verifyTx` works as expected
See [verifierTest.js](./test/verifierTest.js)
```shell
truffle compile
truffle migrate
truffle test
```