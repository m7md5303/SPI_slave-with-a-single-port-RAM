module topmod (rst_n,clk,SS_n,MISO,MOSI);
//defining the ports types
input  MOSI,SS_n,rst_n,clk ;
output MISO;
wire rx_valid,tx_valid;
wire [9:0] rx_data,tx_data;
rram RAM_INTERFACE(.din(rx_data),.clk(clk),.rst_n(rst_n),.rx_valid(rx_valid),.dout(tx_data),.tx_valid(tx_valid));
SPI SPI_INTERFACE(.tx_valid(tx_valid),.tx_data(tx_data),.rx_valid(rx_valid),.rx_data(rx_data),.rst_n(rst_n),.clk(clk),.SS_n(SS_n),.MISO(MISO),.MOSI(MOSI));
endmodule 