function exp(g, a, p) {
  var ans = 1;
  while(a) {
    if (a & 1) ans = (ans * g) % p;
    a = a >> 1;
    g = (g * g) % p;
  }
  return ans;
}

// verify that g^a mod p == ans
template dh() {
  signal input g;
  signal input p;
  signal input ans;

  signal private input a;

  var out = exp(g, a, p);
  out === ans;
}

component main = dh();