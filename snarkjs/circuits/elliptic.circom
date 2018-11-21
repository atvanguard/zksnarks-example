function add(p1, p2) {
  var xp = p1[0];
  var yp = p1[1];

  var xq = p2[0];
  var yq = p2[1];
  var m = (yp - yq) / (xp - xq);

  var xr = m*m;
  xr -= xp;
  //xr -= xq;
  var r[2];
  return r;

  /*var b = (xp - xq);
  var m = (yp - yq) / b;
  var xr = m*m;
  // xr = xr - xp - xq;
  var yr = yq + m*(xr - xq);

  var r[2];
  r[0] = xr;
  r[1] = -1 * yr;
  return r;*/
}

template addT() {
  signal input p1[2];
  signal input p2[2];
  signal output out[2];
  var r[2] = add(p1, p2);

  out[0] = r[0];
  out[1] = r[1];
}

component main = addT();