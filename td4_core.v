`default_nettype none

module td4_core(
    input  wire       clk,   //clock
    input  wire       rst_n, //asynchronous reset
    input  wire [7:0] op,    //instructions
    input  wire [3:0] gpi,   //general purpose input
    output reg  [3:0] gpo,   //general purpose output
    output reg  [3:0] ip     //instruction pointer
                );

    parameter mov_ai = 4'b0011;
    parameter mov_bi = 4'b0111;
    parameter mov_ab = 4'b0001;
    parameter mov_ba = 4'b0100;
    parameter add_ai = 4'b0000;
    parameter add_bi = 4'b0101;
    parameter in_a   = 4'b0010;
    parameter in_b   = 4'b0110;
    parameter out_i  = 4'b1011;
    parameter out_b  = 4'b1001;
    parameter jmp_i  = 4'b1111;
    parameter jmc_i  = 4'b1110;


    reg  [3:0]  regA;
    reg  [3:0]  regB;
    reg         cflag;
    wire [3:0]  opc; //operation code
    wire [3:0]  im;  //immediate data
    wire [4:0] adda_nxt;
    wire [4:0] addb_nxt;

    assign {opc, im} = op;
    assign adda_nxt  = regA + im;
    assign addb_nxt  = regB + im;
    //-------------------------------- 
    //    instruction pointer
    //--------------------------------

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ip <= 4'h0;
        end
        else begin
            case(opc)
                jmp_i    : ip <= im;
                jmc_i    :
                  if(cflag == 0) begin
                      ip <= im;
                  end
                  else begin
                      ip <= ip + 1'b1;
                  end
                default : ip <= ip + 1'b1;
            endcase
        end
    end

    //--------------------------------
    // instruction decorder
    //--------------------------------

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            regA <= 4'h0;
            regB <= 4'h0;
            gpo  <= 4'h0;
        end
        else begin
            case(opc)
                mov_ai : regA <= im;
                mov_bi : regB <= im;
                mov_ab : regA <= regB;
                mov_ba : regB <= regA;
                add_ai : regA <= adda_nxt[3:0];
                add_bi : regB <= addb_nxt[3:0];
                in_a   : regA <= gpi;
                in_b   : regB <= gpi;
                out_i  : gpo  <= im;
                out_b  : gpo  <= regB;
                default:;
           endcase
        end
    end

    //--------------------------------
    // generate cflag
    //--------------------------------

    always @(posedge clk or negedge rst_n) begin
         if(!rst_n) begin
             cflag <= 1'b0;
         end
         else begin
             case(opc)
                add_ai : cflag <= adda_nxt[4];
                add_bi : cflag <= addb_nxt[4];
                default: cflag <= 1'b0;
             endcase
         end
    end
      
endmodule



`default_nettype wire