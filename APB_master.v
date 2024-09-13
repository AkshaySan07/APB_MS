'timescale 1ns / 1ps

module APB_master #(parameter
    size = 32,
    ad_size = 8
) (
    input                 clk,
    input                 rst,
    input                 mode,
    input                 PREADY,
    input  [size-1 : 0]   PRDATA,
    output                PSEL,
    output                PEN,
    output                PW,
    output [size-1 : 0]   PWDATA,
    output [ad_size-1: 0] PADDR,
    output [size-1 : 0]   read_data);

reg [1:0] state;
reg [1:0] nxt_state;
wire setup;
wire access;

//reg psel,pen,pw;
//reg [size-1:0] pwdata;
//reg [ad_size-1:0] paddr;

assign setup = (state == 2'd1) ? 1'b1 : 1'b0;
assign access = (state == 2'd2) ? 1'b1 : 1'b0;

assign PSEL = setup | access;
assign PW = mode;
assign PEN = access;
assign PWDATA = {size{mode}} & 'hdeadface;
assign PADDR = {size{access}} & ('d2);
assign read_data = ((!mode) & PREADY) ? PRDATA : 'd0;


always @(posedge clk, negedge rst) begin
    if(!rst) begin
        state = 2'd0;
    end
    else begin
        state = nxt_state;
    end
end

always @(*) begin
    case (state)
        2'd0: begin
            if (mode) begin
                nxt_state = 2'd1;
            end
            else begin
                nxt_state = 2'd0;
            end 
        end

        2'd1: begin
            nxt_state = 2'd2;
        end

        2'd2: begin
            if (PREADY) begin
                nxt_state = 2'd0;
            end
            else begin
                nxt_state = 2'd2;
            end
        end

        2'd3: nxt_state = 2'd0;
    endcase
end

endmodule 