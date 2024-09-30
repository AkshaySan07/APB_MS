`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2024 05:17:36 PM
// Design Name: 
// Module Name: APB_slave
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


module APB_slave #(parameter 
    size = 32,
    addr = 8 
)(
    input                clk_APB,
    input                rst, 
    output               PREADY, 
    output [size-1 : 0]  PRDATA,  
    input                PSEL, 
    input                PEN, 
    input                PW, 
    input  [size-1 : 0]  PWDATA, 
    input  [addr-1:0]    PADDR,
    output [size-1:0]    PRESCALAR);

//|Write|  Register  |  address  |
//|-----|------------|-----------|
//|-----|------------|-----------|
//| APB |  prescalar |     0     |
//|  "  |  command   |     1     |
//|  "  |  transmit  |     2     |
//|  "  |  address   |     3     |
//|-----|------------|-----------|
//| I2C |  receive   |     4     |
//|  "  |  status    |     5     |


    reg [size-1:0] device_regs [addr-1:0];
// 000,001,010,011,100,101,110,111

// Write: The registers are written from both the sides
// APB side write 0 to 3 addresses and reads 4 & 5
// I2C side writes 4 & 5 and read 0 to 3.
// Using PW from controlling the writing and reading of APB side
 
    assign PRESCALAR = device_regs[0];
    
    always @ (posedge clk_APB,negedge rst) begin
        if(!rst) begin
            device_regs[0][size-1:0] <= 'd0;
            device_regs[1][size-1:0] <= 'd0;
            device_regs[2][size-1:0] <= 'd0;
            device_regs[3][size-1:0] <= 'd0;
            device_regs[4][size-1:0] <= 'hbababab4;
            device_regs[5][size-1:0] <= 'hcacacac5;
            device_regs[6][size-1:0] <= 'd0;
            device_regs[7][size-1:0] <= 'd0;
        end
        else if (PADDR == 'd0 || PADDR == 'd1 || PADDR == 'd2 || PADDR == 'd3) begin
            device_regs[PADDR] <= (PW && PREADY) ? PWDATA : device_regs[PADDR];
        end
        else begin
            device_regs[PADDR] <= device_regs[PADDR];
        end
    end
    


// Read
    assign PRDATA = (!PW && PREADY) ? device_regs[PADDR] : 'd0;

// Ready: Extra logic can be added.
    assign PREADY = PSEL & PEN;  
     
endmodule
