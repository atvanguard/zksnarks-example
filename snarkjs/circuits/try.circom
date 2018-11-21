template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * 2**i;
    }

    lc1 === in;
}

template Bits2Num(n) {
    signal input in[n];
    signal output out;
    var lc1=0;

    for (var i = 0; i<n; i++) {
        lc1 += in[i] * 2**i;
    }
    lc1 ==> out;
}

function add256(a, b) {
  var out[256];
  var bitsum = 0;
  for(var i=0; i<256; i++) {
    bitsum += ((a>>i) & 1) + ((b>>i) & 1);
    out[i] = (bitsum % 2);
    bitsum = (bitsum >> 1);
  }
  return out;
}

/*function addModulo(a, b, p) {
  var out[256];
}*/

template add() {
  signal input a;
  signal input b;
  signal output out[256];

  var o[256] = add256(a, b);
  for(var i=0; i<256; i++) {
    out[i] = o[i];
  }
}

component main = add();