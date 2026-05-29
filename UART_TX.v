module UART_TX 
  #(parameter CLKS_PER_BIT = 868)
  (
   input       i_Clock,
   input       i_Reset,
   input       i_TX_DV,     // Pulse to trigger transmission
   input [7:0] i_TX_Byte,   // Byte to send
   output      o_TX_Active, // High during transmission
   output reg  o_TX_Serial, // Serial data out
   output      o_TX_Done    // Finished pulse
   );
 
  localparam IDLE         = 3'b000;
  localparam TX_START_BIT = 3'b001;
  localparam TX_DATA_BITS = 3'b010;
  localparam TX_STOP_BIT  = 3'b011;
  localparam CLEANUP      = 3'b100;
  
  reg [2:0]  r_SM_Main     = IDLE;
  reg [15:0] r_Clock_Count = 0;
  reg [2:0]  r_Bit_Index   = 0;
  reg [7:0]  r_TX_Data     = 0;
  reg        r_TX_Active   = 0;
  reg        r_TX_Done     = 0;

  always @(posedge i_Clock) begin
    if (i_Reset) begin
      r_SM_Main <= IDLE;
      r_TX_Active <= 1'b0;
      o_TX_Serial <= 1'b1;
      r_TX_Done   <= 1'b0;
    end else begin
      r_TX_Done <= 1'b0;
      case (r_SM_Main)
        IDLE : begin
          o_TX_Serial   <= 1'b1;         
          r_Clock_Count <= 0;
          r_Bit_Index   <= 0;
          if (i_TX_DV) begin
            r_TX_Active <= 1'b1;
            r_TX_Data   <= i_TX_Byte;
            r_SM_Main   <= TX_START_BIT;
          end
        end 

        TX_START_BIT : begin
          o_TX_Serial <= 1'b0;
          if (r_Clock_Count < CLKS_PER_BIT-1)
            r_Clock_Count <= r_Clock_Count + 1;
          else begin
            r_Clock_Count <= 0;
            r_SM_Main     <= TX_DATA_BITS;
          end
        end 

        TX_DATA_BITS : begin
          o_TX_Serial <= r_TX_Data[r_Bit_Index];
          if (r_Clock_Count < CLKS_PER_BIT-1)
            r_Clock_Count <= r_Clock_Count + 1;
          else begin
            r_Clock_Count <= 0;
            if (r_Bit_Index < 7)
              r_Bit_Index <= r_Bit_Index + 1;
            else begin
              r_Bit_Index <= 0;
              r_SM_Main   <= TX_STOP_BIT;
            end
          end 
        end 

        TX_STOP_BIT : begin
          o_TX_Serial <= 1'b1;
          if (r_Clock_Count < CLKS_PER_BIT-1)
            r_Clock_Count <= r_Clock_Count + 1;
          else begin
            r_TX_Done     <= 1'b1;
            r_Clock_Count <= 0;
            r_SM_Main     <= CLEANUP;
            r_TX_Active   <= 1'b0;
          end 
        end 

        CLEANUP : begin
          r_TX_Done <= 1'b1;
          r_SM_Main <= IDLE;
        end
        
        default : r_SM_Main <= IDLE;
      endcase
    end
  end

  assign o_TX_Active = r_TX_Active;
  assign o_TX_Done   = r_TX_Done;

endmodule