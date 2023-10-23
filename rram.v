module rram (din,clk,rst_n,rx_valid,dout,tx_valid);
//defining the parameters with their default values
parameter MEM_DEPTH=256;
parameter ADDR_SIZE = 8;
//setting the ports types
input [9:0] din;
input clk,rst_n,rx_valid;
output [7:0] dout;
output tx_valid;
reg [7:0] dout_tmp;
reg tx_valid_tmp;
//defining a holder for the address value
reg [ADDR_SIZE-1:0] address_holder;
//defining the ram block
reg [7:0] mem [MEM_DEPTH-1:0];
//setting the functionality
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout_tmp<=0;
        tx_valid_tmp<=0;
    end
    else begin if(rx_valid) begin case (din[9:8])
        2'b00:begin
            address_holder<=din[7:0];
        end
        2'b01:begin
          mem [address_holder]<=din[7:0];  
        end
        2'b10:begin
            address_holder<=din [7:0];
        end
        2'b11:begin
            dout_tmp<=mem[address_holder];
            tx_valid_tmp<=1;
        end
    endcase
    end
end  
end
assign dout=dout_tmp;
assign tx_valid=tx_valid_tmp;
endmodule 