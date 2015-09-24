// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50

module behavioralDecoder(out0,out1,out2,out3, address0,address1, enable);
output out0, out1, out2, out3;
input address0, address1;
input enable;
assign {out3,out2,out1,out0}=enable<<{address1,address0};
endmodule

module structuralDecoder(out0,out1,out2,out3, address0,address1, enable);
output out0, out1, out2, out3;
input address0, address1;
input enable;
wire nA0;
wire nA1;
`NOT address0inv(nA0,address0);
`NOT address1inv(nA1,address1);
`AND andgate0(out0,enable,nA0,nA1);
`AND andgate1(out1,enable,address0,nA1);
`AND andgate2(out2,enable,nA0,address1);
`AND andgate3(out3,enable,address0,address1);
endmodule

module testDecoder; 
reg addr0, addr1;
reg enable;
wire out0,out1,out2,out3;
//behavioralDecoder decoder (out0,out1,out2,out3,addr0,addr1,enable);
structuralDecoder decoder (out0,out1,out2,out3,addr0,addr1,enable); // Swap after testing

initial begin
$display("En A0 A1| O0 O1 O2 O3 | Expected Output");
enable=0;addr0=0;addr1=0; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | All false", enable, addr0, addr1, out0, out1, out2, out3);
enable=0;addr0=1;addr1=0; #1000
$display("%b  %b  %b |  %b  %b  %b  %b | All false", enable, addr0, addr1, out0, out1, out2, out3);
enable=0;addr0=0;addr1=1; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | All false", enable, addr0, addr1, out0, out1, out2, out3);
enable=0;addr0=1;addr1=1; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | All false", enable, addr0, addr1, out0, out1, out2, out3);
enable=1;addr0=0;addr1=0; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | O0 Only", enable, addr0, addr1, out0, out1, out2, out3);
enable=1;addr0=1;addr1=0; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | O1 Only", enable, addr0, addr1, out0, out1, out2, out3);
enable=1;addr0=0;addr1=1; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | O2 Only", enable, addr0, addr1, out0, out1, out2, out3);
enable=1;addr0=1;addr1=1; #1000 
$display("%b  %b  %b |  %b  %b  %b  %b | O3 Only", enable, addr0, addr1, out0, out1, out2, out3);
end
endmodule

