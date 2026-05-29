`timescale 1ns/10ps

module UART_TB ();

  // Basys3 Parameters: 100 MHz Clock
  // 100,000,000 / 115,200 = 868 Clocks Per Bit
  parameter c_CLOCK_PERIOD_NS = 10;
  parameter c_CLKS_PER_BIT    = 868;
  
  reg        r_Clock = 0;
  reg        r_Reset = 0;
  reg        r_TX_DV = 0;
  reg  [7:0] r_TX_Byte = 0;
  
  wire       w_TX_Active, w_TX_Serial, w_TX_Done;
  wire       w_RX_DV;
  wire [7:0] w_RX_Byte;

  // 1. Instantiate UART Transmitter
  UART_TX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst (
    .i_Clock(r_Clock),
    .i_Reset(r_Reset),
    .i_TX_DV(r_TX_DV),
    .i_TX_Byte(r_TX_Byte),
    .o_TX_Active(w_TX_Active),
    .o_TX_Serial(w_TX_Serial),
    .o_TX_Done(w_TX_Done)
  );

  // 2. Instantiate UART Receiver
  // Note: We connect the Transmitter Output (w_TX_Serial) 
  // directly to the Receiver Input (i_RX_Serial)
  UART_RX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst (
    .i_Clock(r_Clock),
    .i_Reset(r_Reset),
    .i_RX_Serial(w_TX_Serial),
    .o_RX_DV(w_RX_DV),
    .o_RX_Byte(w_RX_Byte)
  );
    
  // Clock Generation Logic
  always #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
  
  // Main Stimulus
  initial begin
    // Setup waveform dumping for Vivado/GTKWave
    $dumpfile("dump.vcd");
    $dumpvars(0, UART_TB);

    // Initial Conditions
    r_Reset   <= 1'b1;
    r_TX_DV   <= 1'b0;
    r_TX_Byte <= 8'h00;
    
    // Hold Reset for 100ns
    #(c_CLOCK_PERIOD_NS * 10);
    r_Reset <= 1'b0;
    #(c_CLOCK_PERIOD_NS * 10);

    // --- TEST 1: Send 0x3F ---
    @(posedge r_Clock);
    r_TX_DV   <= 1'b1;
    r_TX_Byte <= 8'h3F;
    @(posedge r_Clock);
    r_TX_DV   <= 1'b0;
    $display("[TIME: %0t] TX started sending 0x3F", $time);

    // Wait for Receiver to signal Data Valid
    @(posedge w_RX_DV);
    
    if (w_RX_Byte == 8'h3F)
      $display("[TIME: %0t] TEST PASSED: Received 0x3F correctly", $time);
    else
      $display("[TIME: %0t] TEST FAILED: Expected 0x3F, but got 0x%h", $time, w_RX_Byte);

    // --- TEST 2: Send 0xAB ---
    #(c_CLOCK_PERIOD_NS * 1000); // Small gap between bytes
    @(posedge r_Clock);
    r_TX_DV   <= 1'b1;
    r_TX_Byte <= 8'hAB;
    @(posedge r_Clock);
    r_TX_DV   <= 1'b0;
    
    @(posedge w_RX_DV);
    if (w_RX_Byte == 8'hAB)
      $display("[TIME: %0t] TEST PASSED: Received 0xAB correctly", $time);
    else
      $display("[TIME: %0t] TEST FAILED: Expected 0xAB, but got 0x%h", $time, w_RX_Byte);

    #(c_CLOCK_PERIOD_NS * 1000);
    $display("All tests completed.");
    $finish();
  end

endmodule