// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR xor #50

module behavioralFullAdder(sum, carryout, a, b, carryin);
output sum, carryout;
input a, b, carryin;
assign {carryout, sum}=a+b+carryin;
endmodule

module structuralFullAdder(sum, carryout, a, b, carryin);
output sum, carryout;
input a, b, carryin;
wire AandBandC, AorBorC;
wire AandB, AandC, BandC;
`XOR xorgate(AorBorC, a,b,carryin);
`AND andgate0(AandBandC,a,b,carryin);
`AND andgate1(AandB,a,b);
`AND andgate2(AandC,a,carryin);
`AND andgate3(BandC,b,carryin);
`OR orgate0(sum, AandBandC, AorBorC);
`OR orgate1(carryout, AandB, AandC, BandC);
endmodule

module testFullAdder;
reg a, b, carryin;
wire sum, carryout;
//behavioralFullAdder adder (sum, carryout, a, b, carryin);
structuralFullAdder adder (sum,carryout,a,b,carryin);

initial begin
$display("A B Cin | Cout S | Cout S Expected");
a=0;b=0;carryin=0; #1000
$display("%b %b  %b  |  %b   %b |  0   0", a,b,carryin,carryout,sum);
a=0;b=0;carryin=1; #1000
$display("%b %b  %b  |  %b   %b |  0   1", a,b,carryin,carryout,sum);
a=0;b=1;carryin=0; #1000
$display("%b %b  %b  |  %b   %b |  0   1", a,b,carryin,carryout,sum);
a=0;b=1;carryin=1; #1000
$display("%b %b  %b  |  %b   %b |  1   0", a,b,carryin,carryout,sum);
a=1;b=0;carryin=0; #1000
$display("%b %b  %b  |  %b   %b |  0   1", a,b,carryin,carryout,sum);
a=1;b=0;carryin=1; #1000
$display("%b %b  %b  |  %b   %b |  1   0", a,b,carryin,carryout,sum);
a=1;b=1;carryin=0; #1000
$display("%b %b  %b  |  %b   %b |  1   0", a,b,carryin,carryout,sum);
a=1;b=1;carryin=1; #1000
$display("%b %b  %b  |  %b   %b |  1   1", a,b,carryin,carryout,sum);
end
endmodule


endmodule
