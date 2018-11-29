template Multiplier() {
  signal private input a;
  signal private input b;
  signal input c;
  
  c === a*b;
}

component main = Multiplier();