module ALU
(
    output[31:0]    result,
    output          carryout,
    output          zero,
    output          overflow,
    input[31:0]     operandA,
    input[31:0]     operandB,
    input[2:0]      command
);

    wire[31:0] xoro, ando, nando, noro, oro, add, sub, slt;
    wire cadd, oadd, csub, osub, csub_sel, cadd_sel, osub_sel, oadd_sel, neg_zero, zero_acc, sltbit;
    or32 op_or(operandA, operandB, oro);
    and32 op_and(operandA, operandB, ando);
    xor32 op_xor(operandA, operandB, xoro);
    nor32 op_nor(operandA, operandB, noro);
    nand32 op_nand(operandA, operandB, nando);
    FullAdderNbit adder(operandA, operandB, add, cadd, oadd);
    subtractorNbit subb(operandA, operandB, sub, csub, osub);
//    generate
//    genvar i;
//    for (i=0; i<32; i=i+1) begin: slt_set
//        assign slt[i] = 1'b0;
//    end
//    endgenerate

    MUX multi(command, add, sub, xoro, {31'b0, sltbit}, ando, nando, noro, oro, result);

    nor #320 set_zero(zero_acc, result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]);
    xor #20 slt_bit(sltbit, osub, sub[31]);

    wire neg_lsb, neg_msb, neg_mb, add_zero_ok, sub_zero_ok;
    not #10 neg_sel_lsb1(neg_lsb, command[0]);
    not #10 neg_sel_lsb2(neg_msb, command[2]);
    not #10 neg_sel_lsb3(neg_mb, command[1]);

    and #40 cadd_allowed(cadd_sel, cadd, neg_lsb, neg_msb, neg_mb);
    and #40 csub_allowed(csub_sel, csub, command[0], neg_msb, neg_mb);
    or #20 cout(carryout, cadd_sel, csub_sel);

    and #40 oadd_allowed(oadd_sel, oadd, neg_lsb, neg_msb, neg_mb);
    and #40 osub_allowed(osub_sel, osub, command[0], neg_msb, neg_mb);
    or #20 oout(overflow, oadd_sel, osub_sel);

    and #40 zero_allowed_add(add_zero_ok, zero_acc, neg_lsb, neg_msb, neg_mb);
    and #40 zero_allowed_sub(sub_zero_ok, zero_acc, command[0], neg_msb, neg_mb);
    or #20 zero_actual(zero, add_zero_ok, sub_zero_ok);

endmodule

module FullAdderNbit
(
    input[31:0] a,     // First operand in 2?s complement format
    input[31:0] b,     // Second operand in 2?s complement format
    output[31:0] sum,  // 2?s complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    output overflow  // True if the calculation resulted in an overflow
);

    wire[30:0] carry;
    fullAdder adder0(sum[0], carry[0], a[0], b[0], 1'b0);
    generate
    genvar i;
    for (i=1; i<31; i=i+1) begin: adderN
    fullAdder adder(sum[i], carry[i], a[i], b[i], carry[i-1]);
    end
    endgenerate
    fullAdder adder3(sum[31], carryout, a[31], b[31], carry[30]);
    xor #20 xorgate(overflow, carryout, carry[30]);
endmodule

module subtractorNbit
(
    input[31:0] a,     // First operand in 2?s complement format
    input[31:0] b,     // Second operand in 2?s complement format
    output[31:0] sum,  // 2?s complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    output overflow  // True if the calculation resulted in an overflow
);

    wire[30:0] carry;
    wire[31:0] negated;
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: sub_negate
        not #10 neg(negated[i], b[i]);
    end
    endgenerate
    //set carry in to one to get free incrementation of second number
    fullAdder adder0(sum[0], carry[0], a[0], negated[0], 1'b1);
    generate
    genvar j;
    for (j=1; j<31; j=j+1) begin: subN
        fullAdder adder(sum[j], carry[j], a[j], negated[j], carry[j-1]);
    end
    endgenerate
    fullAdder adder3(sum[31], carryout, a[31], negated[31], carry[30]);
    xor #20 orgate(overflow, carryout, carry[30]);
endmodule

module fullAdder(
    output sum, 
    output carryout,
    input a, 
    input b, 
    input carryin
);
    wire AxorB, AandB, AxorBandC;

    xor #20 xorgate0(AxorB,a,b);
    xor #20 xorgate1(sum,AxorB, carryin);
    and #20 andgate0(AxorBandC,AxorB,carryin);
    and #20 andgate1(AandB, a, b);
    or #20 orgate(carryout, AandB, AxorBandC);
endmodule

module or32
(
    input[31:0] a,
    input[31:0] b,
    output[31:0] out
);
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: or_op
        or #20 or_32(out[i], a[i], b[i]);
    end
    endgenerate
endmodule

module nor32
(
    input[31:0] a,
    input[31:0] b,
    output[31:0] out
);
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: nor_op
        nor #20 nor_32(out[i], a[i], b[i]);
    end
    endgenerate
endmodule

module xor32
(
    input[31:0] a,
    input[31:0] b,
    output[31:0] out
);
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: xor_op
        xor #20 xor_32(out[i], a[i], b[i]);
    end
    endgenerate
endmodule

module nand32 
(
    input[31:0] a,
    input[31:0] b,
    output[31:0] out
);
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: nand_op
        nand #20 nand_32(out[i], a[i], b[i]);
    end
    endgenerate
endmodule

module and32
(
    input[31:0] a,
    input[31:0] b,
    output[31:0] out
);
    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: and_op
        and #20 or_32(out[i], a[i], b[i]);
    end
    endgenerate
endmodule

module MUX
(
    input [2:0] select,
    input [31:0] i0,
    input [31:0] i1,
    input [31:0] i2,
    input [31:0] i3,
    input [31:0] i4,
    input [31:0] i5,
    input [31:0] i6,
    input [31:0] i7,
    output [31:0] out
);
    wire n0, n1, n2;
    wire a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7;
    wire[31:0] b_0, b_1, b_2, b_3, b_4, b_5, b_6, b_7;
    not #10 s0(n0, select[0]);
    not #10 s1(n1, select[1]);
    not #10 s2(n2, select[2]);
    and #30 a0(a_0, n2, n1, n0);
    and #30 a1(a_1, n2, n1, select[0]);
    and #30 a2(a_2, n2, select[1], n0);
    and #30 a3(a_3, n2, select[1], select[0]);
    and #30 a4(a_4, select[2], n1, n0);
    and #30 a5(a_5, select[2], n1, select[0]);
    and #30 a6(a_6, select[2], select[1], n0);
    and #30 a7(a_7, select[2], select[1], select[0]);

    generate
    genvar i;
    for (i=0; i<32; i=i+1) begin: and_32
        and #20 b0(b_0[i], i0[i], a_0); 
        and #20 b1(b_1[i], i1[i], a_1);
        and #20 b2(b_2[i], i2[i], a_2);
        and #20 b3(b_3[i], i3[i], a_3);
        and #20 b4(b_4[i], i4[i], a_4);
        and #20 b5(b_5[i], i5[i], a_5);
        and #20 b6(b_6[i], i6[i], a_6);
        and #20 b7(b_7[i], i7[i], a_7);
    end
    endgenerate

    generate
    genvar j;
    for (j=0; j<32; j=j+1) begin: or_32
        or #80 or_32(out[j], b_0[j], b_1[j], b_2[j], b_3[j], b_4[j], b_5[j], b_6[j], b_7[j]);
    end
    endgenerate
endmodule

module test;
    reg[31:0] opa, opb;
    reg[2:0] command;
    wire[31:0] result, xoro;
    wire co, ofl, zero;
    ALU alu(result, co, zero, ofl, opa, opb, command);
    parameter del =10000;
    initial begin
	$display("<-----------------------Testing Adder ---------------------------------------------------------------------------------------------->");
	$display("          Testing Addition gives expected value for small values (no carryout or overflow)");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=5;opb=6;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	opa=4;opb=3;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=100;opb=100;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with carryout but no overflow");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-5000;opb=10000;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	opa=80000;opb=-50000;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-40000;opb=-60000;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with overflow but no carryout");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=1073741824;opb=1073741824;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=1073745555;opb=1073955824;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with both overflow and carryout");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-1073745555;opb=-1073955824;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-1999945555;opb=-2073955824;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing inverses sum to 0, Zero flag set to 1, carryout but no overflow");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-298;opb=298;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-10000;opb=10000;command=0; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("<-----------------------Testing Subtraction------------------------------------------------------------------------------------------>");
	$display("          Testing Subtraction gives expected value for small values (no carryout or overflow)");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=5;opb=-6;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	opa=4;opb=-3;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=100;opb=-100;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with carryout but no overflow");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-5000;opb=-10000;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	opa=80000;opb=50000;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-40000;opb=60000;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with overflow but no carryout");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=1073741824;opb=-1073741824;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=1073745555;opb=-1073955824;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing cases with both overflow and carryout");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-1073745555;opb=1073955824;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-1999945555;opb=2073955824;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("          Testing the difference between a number and itself is 0, Zero flag set to 1");
	$display("       Operand 1                      Operand 2                      |            Result                  | Zero  Carryout  Overflow");
        opa=-298;opb=-298;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=10000;opb=10000;command=1; #del
	$display("%b   %b  |  %b  |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	$display("<-----------------------Testing Logic Operations ------------------------------------------------------------------------------------>");
	opa=1999945555;opb=2073955824;command=4; #del
	$display(" Operand A: %b, Operand B: %b ", opa, opb);
	$display("                Expected                 |                Result              |    Zero  Carryout  Overflow"); 
	$display(" AND:  01110011000101000000110101010000  |  %b  |     %b       %b        %b", result, zero, co, ofl);
	command=5; #del
	$display("NAND:  10000000010000010100000000001100  |  %b  |     %b       %b        %b", result, zero, co, ofl);
	command=6; #del
	$display("  OR:  10000000010000010100000000001100  |  %b  |     %b       %b        %b", result, zero, co, ofl);
	command=7; #del
	$display(" NOR:  01111111101111101011111111110011  |  %b  |     %b       %b        %b", result, zero, co, ofl);
	command=2; #del
	$display(" XOR:  00001100101010101011001010100011  |  %b  |     %b       %b        %b", result, zero, co, ofl);

	$display("<-----------------------Testing SLT ------------------------------------------------------------------------------------>");
	$display("       Operand 1                      Operand 2                      |            Result                  | Expected | Zero  Carryout  Overflow");
        opa=5;opb=10;command=3; #del
	$display("%b   %b  |  %b  |    1    |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=10;opb=5;command=3; #del
	$display("%b   %b  |  %b  |    0    |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=5;opb=5;command=3; #del
	$display("%b   %b  |  %b  |    0    |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-5;opb=-10;command=3; #del
	$display("%b   %b  |  %b  |    0    |   %b       %b        %b", opa, opb, result, zero, co, ofl);
        opa=-10;opb=-5;command=3; #del
	$display("%b   %b  |  %b  |    1    |   %b       %b        %b", opa, opb, result, zero, co, ofl);
	

    end
endmodule
//module testMux;
//    reg[31:0] i0, i1, i2, i3, i4, i5, i6, i7;
//    reg[2:0] sel;
//    wire[31:0] out;
//    MUX mux(sel, i0, i1, i2, i3, i4, i5, i6, i7, out);
//    initial begin
//    i0=1;i1=2;i2=32'd3;i3=4;i4=5;i5=6;i6=7;i7=8;sel=7; #1000
//    $display("%d", out);
//    sel=6; #1000
//    $display("%d", out);
//    sel=5; #1000
//    $display("%d", out);
//    sel=4; #1000
//    $display("%d", out);
//    sel=3; #1000
//    $display("%d", out);
//    sel=2; #1000
//    $display("%d", out);
//    sel=1; #1000
//    $display("%d", out);
//    sel=0; #1000
//    $display("%d", out);
//    end
//endmodule
