// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.4.14;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point p) pure internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x1e5e579652a4db30a29f497c837ecf18b7f9faa6f6ba33d62bfee9f272936a7a, 0x2219e6a379aad1102896e112e0c14b23c3d57d02c6cdf9a195b54d10106cb27a], [0x27f48fda8fff2301c61a3c63876fae6f547d4277f9ff0f46ce64e33b56f5923e, 0x2ee76e547895ce2e5d6b701351119c0da196f80def9cd0d0a57634e0516420d6]);
        vk.B = Pairing.G1Point(0x232c7dbea60d0c643b4264d3a67b4e4db3598f4c7d6d272dc8ea6f76758601be, 0x1faa0f9927af852be37a503dc89a65ba8d962836befc474a3c3597f86b9ef821);
        vk.C = Pairing.G2Point([0x210feca9d51a753f7b14e499fae08bae090a2cdba0dc063b70a1bafda8ba6324, 0x1919e384f0b7cb514ffc4e27053f1d23781ee4c93b300eb9afe4c9f63bcae190], [0x2070947b4f07aa18b147ea227e87889ade5374a8d83c5364843447cbdb0763ad, 0x2903426ad12bfcec2d7d8f9156e964a9bfa3de9e671346175b68c5cb80975e09]);
        vk.gamma = Pairing.G2Point([0x9f761d299436c5f6b75df6af65b0bf6b59ba8559850ecb0c39bae9fe400e2ae, 0x1e1edb043d532f4c807ad492bd8c3f8385425042684d028f4f6aa3109affee9c], [0xa6bae95b3c9d51f6897367086ee60e07a73717d0b2998838be7fd6934dcbd3e, 0x2f23421064aab16a1c4c8a49b8920f2fb0eec43b7ff1d83ad0a5f0ec2fea666a]);
        vk.gammaBeta1 = Pairing.G1Point(0x2be22f2a5e29554a52f46b968737cbd92aa9411cb39d64c9df3c6b9bf057050f, 0xa086916533df09a7c96e388d15628040b1acf1d0d700c29d58ebc3579c61004);
        vk.gammaBeta2 = Pairing.G2Point([0x1b05ca831f6acefdf532aaa7483fe6c9ea9bf02e211063dabefd623f754d2019, 0x14ece44a8418b30b109f0da986c009c9e2130e27b864e0ab460ae40d24eac995], [0x45e5ce64ed701885b0da7362676db9afecb35623f5b88a1d45b340e1bba1b5f, 0x19d8379510a631bbf7f9e317b28ac17d93a106a0b7c1197f908121623d2ec82c]);
        vk.Z = Pairing.G2Point([0x1e39ed4a56e79b0889796f4c48c12ed6119c2cc464e19f9e92b9bfa1f7703b09, 0xd8a89e81130738e1ff46efbe9145134f64ae758fde9889e99af3bd0e01db182], [0x2a3fb978203cdf71163e4534bcb5e0b666c1eb97a960d4a6d5d0edf231127ea, 0x226879af28a5900e7b5e25d96097b94da76b2825e5c76d09f74537ddb6d157c7]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0xad7efa53f9a5bae68b2f0ecca4c90cdafe8195526cc9b4beda219b8cfa03549, 0xba709f7a5b6e59effca7fa53ff0784e7b526d820e7a2a8bc486096a83c00063);
        vk.IC[1] = Pairing.G1Point(0x981a6fcb967e87fc6e432c8325934cbea0094bc5710c88b5a2af71ccf14b69f, 0x1547dbd3bb004bdad7497be1887a81d8cc0bf9f10988a646bce4e03ce47fd53b);
        vk.IC[2] = Pairing.G1Point(0x55c986982b6fa6d8cd3bdbf433a3d1d106747c9966d03d9d4f473e677dae4d4, 0x23a39d71fedb1634295e842cafb3a778972e2f8aa6c0b6cbb0bfd8dab4eb9eae);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[2] input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
