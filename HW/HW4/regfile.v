module regfile(ReadData1,		// Contents of first register read
               ReadData2,		// Contents of second register read
               WriteData,		// Contents to write to register
               ReadRegister1,	// Address of first register to read 
               ReadRegister2,	// Address of second register to read
               WriteRegister,	// Address of register to write
               RegWrite,		// Enable writing of register when High
               Clk);		// Clock (Positive Edge Triggered)

output[31:0]	ReadData1;
output[31:0]	ReadData2;
input[31:0]	WriteData;
input[4:0]	ReadRegister1;
input[4:0]	ReadRegister2;
input[4:0]	WriteRegister;
input		RegWrite;
input		Clk;

wire[31:0] q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,q31;
wire[31:0] enable;
decoder1to32 decoder(enable, RegWrite,WriteRegister);

register32zero reg0(q0,WriteData,enable[0],Clk);
register32 reg1(q1,WriteData,enable[1],Clk);
register32 reg2(q2,WriteData,enable[2],Clk);
register32 reg3(q3,WriteData,enable[3],Clk);
register32 reg4(q4,WriteData,enable[4],Clk);
register32 reg5(q5,WriteData,enable[5],Clk);
register32 reg6(q6,WriteData,enable[6],Clk);
register32 reg7(q7,WriteData,enable[7],Clk);
register32 reg8(q8,WriteData,enable[8],Clk);
register32 reg9(q9,WriteData,enable[9],Clk);
register32 reg10(q10,WriteData,enable[10],Clk);
register32 reg11(q11,WriteData,enable[11],Clk);
register32 reg12(q12,WriteData,enable[12],Clk);
register32 reg13(q13,WriteData,enable[13],Clk);
register32 reg14(q14,WriteData,enable[14],Clk);
register32 reg15(q15,WriteData,enable[15],Clk);
register32 reg16(q16,WriteData,enable[16],Clk);
register32 reg17(q17,WriteData,enable[17],Clk);
register32 reg18(q18,WriteData,enable[18],Clk);
register32 reg19(q19,WriteData,enable[19],Clk);
register32 reg20(q20,WriteData,enable[20],Clk);
register32 reg21(q21,WriteData,enable[21],Clk);
register32 reg22(q22,WriteData,enable[22],Clk);
register32 reg23(q23,WriteData,enable[23],Clk);
register32 reg24(q24,WriteData,enable[24],Clk);
register32 reg25(q25,WriteData,enable[25],Clk);
register32 reg26(q26,WriteData,enable[26],Clk);
register32 reg27(q27,WriteData,enable[27],Clk);
register32 reg28(q28,WriteData,enable[28],Clk);
register32 reg29(q29,WriteData,enable[29],Clk);
register32 reg30(q30,WriteData,enable[30],Clk);
register32 reg31(q31,WriteData,enable[31],Clk);

mux32to1by32 mux1(ReadData1,ReadRegister1,q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,q31);
mux32to1by32 mux2(ReadData2,ReadRegister2,q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,q31);


endmodule

module register(q, d, wrenable, clk);
input	d;
input	wrenable;
input	clk;
output reg q;

always @(posedge clk) begin
    if(wrenable) begin
	q = d;
    end
end
endmodule

module register32(q, d, wrenable, clk);
input[31:0] d;
input	wrenable;
input	clk;
output reg[31:0] q;

always @(posedge clk) begin
    if(wrenable) begin
	q=d;
    end
end
endmodule

module register32zero(q, d, wrenable, clk);
input[31:0] d;
input	wrenable;
input	clk;
output reg[31:0] q;

always @(posedge clk) begin
    if(wrenable) begin
	assign q=0;
    end
end
endmodule

module mux32to1by1(out, address, inputs);
input[31:0] inputs;
input[4:0] address;
output out;
assign out=inputs[address];
endmodule 

module mux32to1by32(out, address, input0, input1, input2,input3,input4,input5,input6,input7,input8,input9,input10,input11,input12,input13,input14,input15,input16,input17,input18,input19,input20,input21,input22,input23,input24,input25,input26,input27,input28,input29,input30, input31);
input[31:0] input0, input1, input2,input3,input4,input5,input6,input7,input8,input9,input10,input11,input12,input13,input14,input15,input16,input17,input18,input19,input20,input21,input22,input23,input24,input25,input26,input27,input28,input29,input30, input31;
input[4:0] address;
output[31:0] out;
wire[31:0] mux[31:0]; // Creates a 2d Array of wires
assign mux[0] = input0; // Connects the sources of the array
assign mux[1] = input1;
assign mux[2] = input2;
assign mux[3] = input3;
assign mux[4] = input4;
assign mux[5] = input5;
assign mux[6] = input6;
assign mux[7] = input7;
assign mux[8] = input8;
assign mux[9] = input9;
assign mux[10] = input10;
assign mux[11] = input11;
assign mux[12] = input12;
assign mux[13] = input13;
assign mux[14] = input14;
assign mux[15] = input15;
assign mux[16] = input16;
assign mux[17] = input17;
assign mux[18] = input18;
assign mux[19] = input19;
assign mux[20] = input20;
assign mux[21] = input21;
assign mux[22] = input22;
assign mux[23] = input23;
assign mux[24] = input24;
assign mux[25] = input25;
assign mux[26] = input26;
assign mux[27] = input27;
assign mux[28] = input28;
assign mux[29] = input29;
assign mux[30] = input30;
assign mux[31] = input31;

assign out=mux[address]; // Connects the output of the array
endmodule

module decoder1to32(out, enable, address);
output[31:0] out;
input enable;
input[4:0] address;
assign out = enable<<address; 
endmodule