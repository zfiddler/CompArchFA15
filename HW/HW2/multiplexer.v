// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR xor #50

module behavioralMultiplexer(out, address0,address1, in0,in1,in2,in3);
output out;
input address0, address1;
input in0, in1, in2, in3;
wire[3:0] inputs = {in3, in2, in1, in0};
wire[1:0] address = {address1, address0};
assign out = inputs[address];
endmodule

module structuralMultiplexer(out, address0,address1, in0,in1,in2,in3);
output out;
input address0, address1;
input in0, in1, in2, in3;
wire nA0, nA1;
wire out0,out1,out2,out3;
`NOT address0inv(nA0,address0);
`NOT address1inv(nA1,address1);
`AND andgate0(out0,nA0,nA1,in0);
`AND andgate1(out1,address0,nA1,in1);
`AND andgate2(out2,nA0,address1,in2);
`AND andgate3(out3,address0,address1,in3);
`OR orgate(out,out0,out1,out2,out3);
endmodule


module testMultiplexer;
reg addr0,addr1;
reg in0,in1,in2,in3;
wire out;
//behavioralMultiplexer multiplexer (out,addr0,addr1,in0,in1,in2,in3);
structuralMultiplexer multiplexer (out,addr0,addr1,in0,in1,in2,in3);

initial begin
$display("A0 A1 | I0 I1 I2 I3 | OUT | Expected Output");
addr0=0;addr1=0; in0=0; in1=0; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 0", addr0,addr1,in0,in1,in2,in3,out);
addr0=0;addr1=0; in0=1; in1=0; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 1", addr0,addr1,in0,in1,in2,in3,out);
addr0=1;addr1=0; in0=0; in1=0; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 0", addr0,addr1,in0,in1,in2,in3,out);
addr0=1;addr1=0; in0=0; in1=1; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 1", addr0,addr1,in0,in1,in2,in3,out);
addr0=0;addr1=1; in0=0; in1=0; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 0", addr0,addr1,in0,in1,in2,in3,out);
addr0=0;addr1=1; in0=0; in1=0; in2=1; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 1", addr0,addr1,in0,in1,in2,in3,out);
addr0=1;addr1=1; in0=0; in1=0; in2=0; in3=0; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 0", addr0,addr1,in0,in1,in2,in3,out);
addr0=1;addr1=1; in0=0; in1=0; in2=0; in3=1; #1000
$display("%b  %b  |  %b  %b  %b  %b |  %b  | 1", addr0,addr1,in0,in1,in2,in3,out);
end 
endmodule

