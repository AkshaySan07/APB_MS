`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2024 12:43:13 PM
// Design Name: 
// Module Name: APB_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Code your design here
module APB_master #(parameter
    size = 32,
    addr = 8
) (
    input                 clk_APB,
    input                 rst,
    input                 MIW,
    input                 MISEL,
    input  [size-1 : 0]   MIDATA,
    input  [addr-1 : 0] MIADDR,                
    input                 PREADY,
    input  [size-1 : 0]   PRDATA,
    output                PSEL,
    output                PEN,
    output                PW,
    output [size-1 : 0]   PWDATA,
    output [addr-1 : 0] PADDR,
    output [size-1 : 0]   MODATA,
    output  reg [1:0] state, nxt_state);

//reg [1:0] state;
//reg [1:0] nxt_state;
wire setup;
wire access;

reg pw_r;
reg [size-1:0] pwdat;
reg [addr-1:0] padd;
reg flg, flg_r;

assign setup = (state == 2'd1) ? 1'b1 : 1'b0;
assign access = (state == 2'd2) ? 1'b1 : 1'b0;

assign PSEL = setup | access;
assign PEN = access;
assign MODATA = ((!MIW) & PREADY & access) ? PRDATA : 'd0;

//assign PWDATA = {size{access & MIW}} & MIDATA;
//assign PADDR = {addr{access}} & (MIADDR);
//assign PW = MIW;
assign PWDATA = pwdat;
assign PADDR = padd;
assign PW = pw_r;



//pass the MIDATA to PWDATA when access goes high and hold it.
always @(posedge clk_APB,negedge rst) begin
    if(!rst) begin
        pwdat <= 'd0;
        padd <= 'd0;
        pw_r <= 'd0;
    end
    else if((access) && (!flg)) begin
        pwdat <= MIDATA;  
        padd <= MIADDR;
        pw_r <= MIW;
    end
    else begin
        pwdat <= pwdat;
        padd <= padd;
        pw_r <= pw_r;
    end
end

always @(posedge clk_APB, negedge rst) begin
    if(!rst) begin
        //flg_r <= 'd0;
        flg <= 'd0;
    end
    else begin
        //flg_r <= access;
        flg <= access;
    end
end


always @(posedge clk_APB, negedge rst) begin
    if(!rst) begin
        state <= 2'd0;
    end
    else begin
        state <= nxt_state;
    end
end

always @(*) begin
    case (state)
        2'd0: begin
            nxt_state = MISEL ? 2'd1 : 2'd0;
        end
        
        2'd1: begin
            nxt_state = 2'd2;
        end
        
        2'd2: begin
            if (PREADY) begin
                nxt_state = MISEL ? 2'd1 : 2'd0;
            end
            else begin
                nxt_state = 2'd2;
            end
        end
        
        2'd3: nxt_state = 2'd0;
    endcase
end

endmodule 
