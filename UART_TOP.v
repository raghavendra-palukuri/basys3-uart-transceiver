module Basys3_UART_Top (
    input  wire       clk,   btnC,   btnU,   RsRx,
    input  wire [7:0] sw,
    output wire       RsTx,
    output wire [6:0] seg,
    output wire [3:0] an,
    output wire [7:0] led
);
    wire [7:0] w_RX_Byte;
    wire w_RX_DV, w_TX_Active, w_TX_Done;
    reg r_btn_sync, r_btn_prev;
    wire w_TX_Trigger;
    reg [3:0] r_Hex_Value;
    reg [19:0] r_Refresh_Counter = 0;
    wire [1:0] w_Digit_Select;

    UART_RX #(.CLKS_PER_BIT(868)) RX_Inst (
        .i_Clock(clk), .i_Reset(btnC), .i_RX_Serial(RsRx), .o_RX_DV(w_RX_DV), .o_RX_Byte(w_RX_Byte)
    );

    UART_TX #(.CLKS_PER_BIT(868)) TX_Inst (
        .i_Clock(clk), .i_Reset(btnC), .i_TX_DV(w_TX_Trigger), .i_TX_Byte(sw), 
        .o_TX_Active(w_TX_Active), .o_TX_Serial(RsTx), .o_TX_Done(w_TX_Done)
    );

    assign led = w_RX_Byte;

    always @(posedge clk) begin
        r_btn_sync <= btnU; r_btn_prev <= r_btn_sync;
        r_Refresh_Counter <= r_Refresh_Counter + 1;
    end
    assign w_TX_Trigger = r_btn_sync & ~r_btn_prev;
    assign w_Digit_Select = r_Refresh_Counter[19:18];

    always @(*) begin
        case(w_Digit_Select)
            2'b00: r_Hex_Value = w_RX_Byte[3:0];
            2'b01: r_Hex_Value = w_RX_Byte[7:4];
            default: r_Hex_Value = 4'h0;
        endcase
    end

    assign an = (w_Digit_Select == 2'b00) ? 4'b1110 : (w_Digit_Select == 2'b01) ? 4'b1101 : 4'b1111;

    reg [6:0] r_Seg_Temp;
    always @(*) begin
        case(r_Hex_Value)
            4'h0: r_Seg_Temp = 7'b1000000; 4'h1: r_Seg_Temp = 7'b1111001;
            4'h2: r_Seg_Temp = 7'b0100100; 4'h3: r_Seg_Temp = 7'b0110000;
            4'h4: r_Seg_Temp = 7'b0011001; 4'h5: r_Seg_Temp = 7'b0010010;
            4'h6: r_Seg_Temp = 7'b0000010; 4'h7: r_Seg_Temp = 7'b1111000;
            4'h8: r_Seg_Temp = 7'b0000000; 4'h9: r_Seg_Temp = 7'b0010000;
            4'hA: r_Seg_Temp = 7'b0001000; 4'hB: r_Seg_Temp = 7'b0000011;
            4'hC: r_Seg_Temp = 7'b1000110; 4'hD: r_Seg_Temp = 7'b0100001;
            4'hE: r_Seg_Temp = 7'b0000110; 4'hF: r_Seg_Temp = 7'b0001110;
            default: r_Seg_Temp = 7'b1111111;
        endcase
    end
    assign seg = r_Seg_Temp;
endmodule