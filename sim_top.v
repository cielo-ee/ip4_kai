`default_nettype none

`timescale 1us/1us

`define SYSTEM_CLOCK   1000 // 1MHz

module sim_top;

reg        clk = 1'b1;
reg        rst_n;
reg  [7:0] ram [15:0];
reg  [3:0] gpi;
wire [3:0] gpo;
wire [3:0] ip;

always #(`SYSTEM_CLOCK/2) clk <= ~clk;

    td4_core td4_core_inst(
        .clk       (clk),
        .rst_n     (rst_n),
        .op        (ram[ip]),
        .gpi       (gpi),
        .gpo       (gpo),
        .ip        (ip)
      );
    
    
    initial begin
    
        #1000
        //-------------------------------------
        // initial ram
        //-------------------------------------
        ram[ 0] <= 8'b10110111;
        ram[ 1] <= 8'b00000001;
        ram[ 2] <= 8'b11100001;
        ram[ 3] <= 8'b00000001;
        ram[ 4] <= 8'b11100011;
        ram[ 5] <= 8'b10110110;
        ram[ 6] <= 8'b00000001;
        ram[ 7] <= 8'b11100110;
        ram[ 8] <= 8'b00000001;
        ram[ 9] <= 8'b11101000;
        ram[10] <= 8'b10110000;
        ram[11] <= 8'b10110100;
        ram[12] <= 8'b00000001;
        ram[13] <= 8'b11101010;
        ram[14] <= 8'b10111000;
        ram[15] <= 8'b11111111;
        //------------------------------------
        gpi    <= 4'b0000;
        
        rst_n  <= 1'b1; //reset deassert
        #2500
        rst_n  <= 1'b0; //rset assert
        #3000
        rst_n  <= 1'b1;

        fork
            begin
                wait(gpo == 4'b1000)
                #10000
                $finish;
            end
            begin
                #1000000000 //timeout
                $finish;
            end
        join
    end

endmodule
