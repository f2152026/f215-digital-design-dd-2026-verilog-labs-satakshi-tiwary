module cla64_flat(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [63:0] p, g;
  wire [64:1] c;   // c[1]..c[64]

  // Step 1: P/G signals
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // Step 2: direct carry equations, built algorithmically
  genvar k, j;
  generate
    for (k = 1; k <= 64; k = k + 1) begin : gen_carry
      wire [k:0] t;   // t[0..k-1] = product terms, t[k] = cin term

      for (j = 0; j < k; j = j + 1) begin : gen_term
        if (j == k - 1)
          assign #(2) t[j] = g[j];
        else
          assign #(2) t[j] = g[j] & (&p[k-1:j+1]);
      end

      assign #(2) t[k] = (&p[k-1:0]) & cin;
      assign #(2) c[k] = |t;
    end
  endgenerate

  assign cout = c[64];

  // Step 3: sum bits
  assign #(2) sum = p ^ {c[63:1], cin};

endmodule