/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Verilog Code | Data Path Module :
`timescale 1ns / 1ps

module MUL_datapath(eqz, LdA, LdB, LdP, clrP, decB, data_in,clk);

input  LdA, LdB, LdP, clrP, decB,clk;
input [15:0] data_in;
output eqz;
wire [15:0] X,Y,Z,Bout, Bus;
assign Bus=data_in;



PIPO1 A (Bus,LdA,clk,X);          // Register for A //
PIPO2 P (Z,LdP,clrP,clk,Y);	 // Register for P //
CNTR B(Bus,LdB,decB,clk,Bout);	// Down counter for B //
ADD AD (Z,X,Y);		       // Adder Module //
EQZ COMP (eqz,Bout);	      // A comparator ,that checks if B = zero or not //



endmodule





//Verilog Code | Blocks in  Datapath Module :


/************************* Register Module for data of A **********************/

module PIPO1(
    input [15:0] din,
    input ld,
    input clk,
    output reg [15:0] dout
    );

always@(posedge clk)

    if(ld)
            dout<= din;

endmodule

/************************* Register Module for data of P **********************/

module PIPO2(
    input [15:0] din,
    input ld,
     input clr,
    input clk,
    output reg [15:0] dout
    );

always@(posedge clk)

    if(clr)
            dout<= 16'b0;
            
    else if (ld)     
            dout<= din;

endmodule

/************************* Adder module for (A+P) **********************/

module ADD (out,in1,in2);
input [15:0] in1,in2;
output reg [15:0] out;

always@(*)
        out = in1 + in2 ;
        
endmodule

/*********** Comparator module for checking if B = zero or not ***************/

module EQZ (eqz,data);
input [15:0] data;
output eqz;

assign eqz = (data == 0); // eqz is assigned '1' , if data is equal to '0' //

endmodule

/************************* Down-counter module for B **********************/
module CNTR (
    input [15:0] din,
    input ld,
    input dec,
    input clk,
    output reg [15:0] dout
    );

always@(posedge clk)
        
        if(ld)              // if load is active, load data into register of B //
            dout<= din;
                
        else if(dec)       // If decrement signal is active, then decrement value of B //
            dout <= dout-1;
            
endmodule






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Verilog Code | Control Path Module :

`timescale 1ns / 1ps

module controller (LdA, LdB, LdP, clrP, decB, done, clk, eqz, start);

input clk,eqz,start;
output reg LdA, LdB, LdP, clrP, decB, done;

reg [2:0] state;
parameter S0 = 3'b000 , S1 = 3'b001 , S2 = 3'b010 , S3 = 3'b011 , S4 = 3'b100 ;

/************************ State Transistions **********************/

always@(posedge clk)
        begin
                case (state)
                            
                            S0 : if(start) state <= S1;
                            S1 : state <= S2;
                            S2 : state <= S3;
                            S3 : #2 if(eqz) state <= S4;  // delay added so as to get better simulation results //
                            S4 : state <= S4;
                            default : state <= S0;
                        
                endcase
        end                    

/************************ Generation of Control Signals **********************/    
    
    always@(state)
        begin
                    case(state)
                        
                        S0 : begin #1 LdA = 0; LdB = 0; LdP = 0; clrP = 0; decB = 0; end
                        S1 : begin #1 LdA = 1; end
                        S2 : begin #1 LdA = 0; LdB = 1; clrP = 1;  end
                        S3 : begin #1 LdB = 0; LdP = 1; clrP = 0; decB = 1; end
                        S4 : begin #1 done = 1; LdB = 0; LdP = 0; decB = 0; end
                        default : begin #1 LdA = 0; LdB = 0; LdP = 0; clrP = 0; decB = 0; end
                    endcase
        end            
    
endmodule    