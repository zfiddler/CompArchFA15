//------------------------------------------------------------------------------
// Test harness validates hw4testbench by connecting it to various functional 
// or broken register files, and verifying that it correctly identifies each
//------------------------------------------------------------------------------

module hw4testbenchharness();

  wire[31:0]	ReadData1;	// Data from first register read
  wire[31:0]	ReadData2;	// Data from second register read
  wire[31:0]	WriteData;	// Data to write to register
  wire[4:0]	ReadRegister1;	// Address of first register to read
  wire[4:0]	ReadRegister2;	// Address of second register to read
  wire[4:0]	WriteRegister;  // Address of register to write
  wire		RegWrite;	// Enable writing of register when High
  wire		Clk;		// Clock (Positive Edge Triggered)

  reg		begintest;	// Set High to begin testing register file
  wire		dutpassed;	// Indicates whether register file passed tests

  // Instantiate the register file being tested.  DUT = Device Under Test
  regfile DUT
  (
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData),
    .ReadRegister1(ReadRegister1),
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite),
    .Clk(Clk)
  );

  // Instantiate test bench to test the DUT
  hw4testbench tester
  (
    .begintest(begintest),
    .endtest(endtest), 
    .dutpassed(dutpassed),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData), 
    .ReadRegister1(ReadRegister1), 
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .RegWrite(RegWrite), 
    .Clk(Clk)
  );

  // Test harness asserts 'begintest' for 1000 time steps, starting at time 10
  initial begin
    begintest=0;
    #10;
    begintest=1;
    #1000;
  end

  // Display test results ('dutpassed' signal) once 'endtest' goes high
  always @(posedge endtest) begin
    $display("DUT passed?: %b", dutpassed);
  end

endmodule


//------------------------------------------------------------------------------
// Your HW4 test bench
//   Generates signals to drive register file and passes them back up one
//   layer to the test harness. This lets us plug in various working and
//   broken register files to test.
//
//   Once 'begintest' is asserted, begin testing the register file.
//   Once your test is conclusive, set 'dutpassed' appropriately and then
//   raise 'endtest'.
//------------------------------------------------------------------------------

module hw4testbench(begintest, endtest, dutpassed,
		    ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
output reg endtest;
output reg dutpassed;
input	   begintest;

input[31:0]		ReadData1;
input[31:0]		ReadData2;
output reg[31:0]	WriteData;
output reg[4:0]		ReadRegister1;
output reg[4:0]		ReadRegister2;
output reg[4:0]		WriteRegister;
output reg		RegWrite;
output reg		Clk;
integer index=0;

initial begin
WriteData=0;
ReadRegister1=0;
ReadRegister2=0;
WriteRegister=0;
RegWrite=0;
Clk=0;

end

always @(posedge begintest) begin
endtest = 0;
dutpassed = 1;
#10

// Test Case 1: Write to 42 register 2, verify with Read Ports 1 and 2
// This will pass because the example register file is hardwired to always return 42.
WriteRegister = 2;
WriteData = 42;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;	// Generate Clock Edge
if(ReadData1 != 42 || ReadData2!= 42) begin
	dutpassed = 0;
	$display("Test Case 1 Failed");
	end

// Test Case 2: Write to 15 register 2, verify with Read Ports 1 and 2
// This will fail with the example register file, but should pass with yours.
WriteRegister = 2;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;
if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed");
	end

// Test Case 3: Write Enable Broken
WriteRegister = 2;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

WriteRegister = 2;
WriteData = 20;
RegWrite = 0;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 4 Failed. Write Enable Broken");
	end

// Test Case 4: Decoder Broken

WriteRegister = 1;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 1;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

WriteRegister = 2;
WriteData = 20;
RegWrite = 1;
ReadRegister1 = 1;
ReadRegister2 = 1;
#5 Clk=1; #5 Clk=0;

if(ReadData1 !=15 || ReadData2!=15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 5 Failed. Decoder Broken");
	end


// Test Case 5: Zero register broken

WriteRegister = 0;
WriteData = 20;
RegWrite = 1;
ReadRegister1 = 0;
ReadRegister2 = 0;

if(ReadRegister1!=0 || ReadRegister2!=0) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 6 Failed. Zero Register Broken");
	end


// Test Case 6: Port 2 Broken
WriteRegister = 17;
WriteData = 20;
RegWrite = 1;
ReadRegister1 = 17;
ReadRegister2 = 17;

WriteRegister = 15;
WriteData = 10;
RegWrite = 1;
ReadRegister1 = 15;
ReadRegister2 = 15;


if(ReadRegister2==20) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 7 Failed. Port 2 Broken, always reads regster 17");
	end

// Test Case 7: Perfect Register File
for(index=0;index<32;index=index+1) begin 
WriteRegister = index;
WriteData = WriteRegister;
RegWrite = 1;
ReadRegister1 = WriteRegister;
ReadRegister2 = WriteRegister;
#5 Clk=1; #5 Clk=0;

WriteRegister = index;
WriteData = WriteRegister;
RegWrite = 1;
ReadRegister1 = WriteRegister;
ReadRegister2 = WriteRegister;
#5 Clk=1; #5 Clk=0;

if(ReadData1 != WriteRegister || ReadData2!= WriteRegister) begin
	dutpassed = 0;	// On Failure, set to false.
	end
end

if(!dutpassed) begin
	$display("Test Case 7 Failed: Something is wrong with the register file");
	end
else begin
	$display("Everything seems to be working");
	end

//We're done!  Wait a moment and signal completion.
#5
endtest = 1;
end

endmodule