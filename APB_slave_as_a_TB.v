'timescale 1ns / 1ps 

module APB_slave_tb ();

    reg           clk;
    reg           rst;
    reg           mode;
    reg           PREADY;
    reg  [31 : 0] PRDATA;
    wire          PSEL;
    wire          PEN;
    wire          PW;
    wire [31 : 0] PWDATA;
    wire [7: 0]   PADDR;
    wire [31 : 0] read_data;

    wire [31:0] mem [7:0];

    assign mem[2] = 32'hcafecafe;

    APB_master #(32, 8) Abd1(clk,rst,mode,PREADY,PRDATA,PSEL,PEN,PW,PWDATA,PADDR,read_data);

    initial begin
        clk <= 1'b0; 
        rst <= 1'b0;
        mode <= 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        #10 rst = 1'b1;
        #20 mode = 1'b1;
        #100 mode = 1'b0;
    end

    assign PREADY = (PSEL && PEN) ? 1'b1 : 1'b0;
    assign PRDATA = mem[PADDR]; 


endmodule 