'timescale 1ns / 1ps

module APB_slave #(parameter 
    size = 32,
    ad_size = 8
)(
    input                clk,
    input                rst, 
    output               PREADY, 
    output [size-1 : 0]  PRDATA,  
    input                PSEL, 
    input                PEN, 
    input                PW, 
    input [size-1 : 0]   PWDATA, 
    input [ad_size-1: 0] PADDR, 
    input [size-1 : 0]   PWDI2C);

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


reg [size-1:0] device_regs [ad_size-1:0];
reg [$clog2(ad-size)-1:0] i;


// Write: The registers are written from both the sides
// APB side write 0 to 3 addresses and reads 4 & 5
// I2C side writes 4 & 5 and read 0 to 3.
// Using PW from controlling the writing and reading of APB side
 

always @ (posedge clk,negedge rst) begin
    if (!rst) begin
        for (i = 0; i < ad_size ; i = i + 1) begin
            device_regs[i] = 'd0;
        end
    end
    else if (PADDR == 'd0 || PADDR == 'd1 || PADDR == 'd2 || PADDR == 'd3) begin
        device_regs[PADDR] = PW ? PWDATA : device_regs[PADDR];
    end
    else begin
        device_regs[PADDR] = PWDI2C;
    end
end


// Read
assign PRDATA = !PW ? device_regs[PADDR] : 'd0;

// Ready
assign PREADY = PSEL & PEN;

endmodule





