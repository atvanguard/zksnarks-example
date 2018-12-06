
include "escalarmul.circom";

template Pedersen(n) {
    signal input in[n];
    signal output out[2];

    var nexps = ((n-1) / 250) + 1;
    var nlastbits = n - (nexps-1)*250;

    component escalarMuls[nexps];

    var PBASE = [
                    [ 6842263847932328569390632736104801120816056295876316310227967232893658007436,
                     10520112236148895828506510766039255961372323270202387671483666293012156799229],
                    [ 7512553369533424708326990019377586455744651641787163924108944444109352325495,
                       242060483180498555826438209654403949979206323274480625257315595534333598496],
                    [  480315709862415282411588615813248553518720286084247594626493599605932342246,
                     15016559215090999873142530067666085992648246670781771102893391410239675444873],
                    [ 8311398801616893527636419786153024398643144699386228070202625261657263599049,
                     11125962584728296601438821974884453267303385157860713577195820780853779600315],
                    [ 1924118814882677827825936037840538695314492559747259292440881566152665343441,
                     17232376423406964731689089286495480735310130852288107159412732879983310795144]
                ];

    var i;
    var j;
    var nexpbits;
    for (i=0; i<nexps; i++) {
        nexpbits = (i == nexps-1) ? nlastbits : 250;
        escalarMuls[i] = EscalarMul(nexpbits, PBASE[i]);

        for (j=0; j<nexpbits; j++) {
            escalarMuls[i].in[j] <== in[250*i + j];
        }

        if (i==0) {
            escalarMuls[i].inp[0] <== 0;
            escalarMuls[i].inp[1] <== 1;
        } else {
            escalarMuls[i].inp[0] <== escalarMuls[i-1].out[0];
            escalarMuls[i].inp[1] <== escalarMuls[i-1].out[1];
        }
    }

    escalarMuls[nexps-1].out[0] ==> out[0];
    escalarMuls[nexps-1].out[1] ==> out[1];
}
