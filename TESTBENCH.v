//Verilog Code | Testbench :

`timescale 1ns / 1ps

module testbench;

reg [15:0] data_in;
reg clk,start;
wire done;
wire [15:0] X,Y,Z,Bout, Bus;

MUL_datapath DP (eqz, LdA, LdB, LdP, clrP, decB, data_in,clk);
controller CON (LdA, LdB, LdP, clrP, decB, done, clk, eqz, start);

initial 
begin clk = 1'b0;
#3 start = 1'b1;
#500 $finish;
end

always #5 clk = ~clk;

initial 
begin 
    #17 data_in = 17;  // Value to be loaded in A (Multiplicand) //
    #10 data_in = 5;    // Value to be loaded in B (Multiplier) //
end    

initial 
begin 
$monitor ($time, "%d %b", DP.Y,done);
$dumpfile ("mul.vcd");
$dumpvars (0,testbench);


end
endmodule





