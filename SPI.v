module SPI (tx_valid,tx_data,rx_valid,rx_data,rst_n,clk,SS_n,MISO,MOSI);
//Encoding the FSM States
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter READ_ADD = 3'b010;
parameter READ_DATA = 3'b011;
parameter WRITE = 3'b100;
//defining the ports types
input MOSI,SS_n,rst_n,clk,tx_valid;
input [7:0] tx_data;
output rx_valid,MISO;
output [9:0] rx_data;
reg rx_valid_tmp,MISO_tmp;
reg [9:0] rx_data_tmp;
//the state carrying regs
reg [2:0] cs,ns;
//a signal holding whether the state is reading address or reading data
reg state;
//implementing the state memory
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cs<=IDLE;
    end
    else begin
        cs<=ns;
    end
end 
//implementing the state transitions
always @(cs or MOSI or SS_n or tx_valid or tx_data or state or read_state) begin
    case (cs)
    IDLE:begin
        if(!SS_n) begin
            ns=CHK_CMD;
        end
        else begin
            ns=IDLE;
        end
    end
     CHK_CMD:begin
        if(SS_n) begin
            ns=IDLE;
        end
        else begin
            if(!({SS_n,MOSI}))begin
                ns=WRITE;
            end
            else if((!(SS_n))&&(MOSI)&&(!(state))) begin
                ns=READ_ADD;
            end
            else if((!(SS_n))&&(MOSI)&&(state)) begin
                ns=READ_DATA;
            end
        end
     end
     READ_ADD:begin
        if(~SS_n) begin
            ns=READ_ADD;
        end
        else begin
            ns=IDLE;
        end
     end   
     READ_DATA:begin
           if(~SS_n) begin
            ns=READ_DATA;
        end
        else begin
            ns=IDLE;
        end
     end
     WRITE:begin
           if(~SS_n) begin
            ns=WRITE;
        end
        else begin
            ns=IDLE;
        end
     end
     default:begin
        ns=IDLE;
     end
    endcase
end
//Output logic
//a counter for the conversion process from serial to parallel
reg [3:0] shift_counter;
//a signal to determine the state in case of reading data from the ram block
reg read_state=0;
always @(posedge clk ) begin
case(cs)
IDLE:begin
    shift_counter<=10;  
    MISO_tmp<=0;
    rx_data_tmp<=0;
    rx_valid_tmp<=0;
    end
READ_ADD:begin
      if(shift_counter==0) begin
        rx_valid_tmp<=1;
        shift_counter<=10;
    end
    else begin
        rx_data_tmp<={MOSI,rx_data_tmp[9:1]};
        shift_counter<=shift_counter-1;
    end
end
READ_DATA:begin
    if((shift_counter==0)&&(!(read_state))) begin
        rx_data_tmp<=1;
        shift_counter<=8;
        rx_valid_tmp<=1;
    end
    else if ((shift_counter>0)&&(!(read_state))) begin
        rx_data_tmp<={MOSI,rx_data_tmp[9:1]};
         shift_counter<=shift_counter-1; 
    end
    else if ((shift_counter==0)&&(read_state)) begin
        shift_counter<=10;
    end
    else if (tx_valid) begin
        MISO_tmp<=tx_data[shift_counter-1];
        shift_counter<=shift_counter-1;
    end
    end
WRITE:begin
    if(shift_counter==0) begin
        rx_valid_tmp<=1;
    end
    else begin
        rx_data_tmp<={MOSI,rx_data_tmp[9:1]};
        shift_counter<=shift_counter-1;
    end
end
endcase    
end
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
        state<=0;
        read_state<=0;
    end
    else begin
        case (cs)
        IDLE:begin
            read_state<=0;
        end
            READ_ADD:begin
                if(shift_counter==0) begin
                    state<=1;
                end
            end
           READ_DATA:begin
             if((shift_counter==0)&&(!(read_state))) begin
                read_state<=1;
             end
             else if ((shift_counter==0)&&(read_state)) begin
                read_state<=0;
             end
           end
        endcase
    end   
end
assign MISO=MISO_tmp;
assign rx_data=rx_data_tmp;
assign rx_valid=rx_valid_tmp;
endmodule 