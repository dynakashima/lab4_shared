module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------

   
  wire                            SymbolEdge;
  wire                            Start;
  wire                            TXRunning;

  reg     [9:0]                   TXShift;
  reg     [3:0]                   BitCounter;
  reg     [ClockCounterWidth-1:0] ClockCounter;
  reg                             HasByte;


 //==============================================================
  
   // Goes high at every symbol edge
   assign  SymbolEdge   = (ClockCounter == SymbolEdgeTime - 1);
     
  // Goes high when it is time to start receiving a new character
   assign  Start         = DataInValid && !TXRunning;

  // Currently receiving a character
   assign  TXRunning     = BitCounter != 4'd0;

   assign SOut = TXShift[10-BitCounter];
   
   assign DataInReady = !HasByte && !TXRunning;

   // Counts cycles until a single symbol is done
   always @ (posedge Clock) begin
      ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
   end

     // Counts down from 10 bits for every character
  always @ (posedge Clock) begin
      if (Reset) begin
	 BitCounter <= 0;
      end else if (Start) begin
	BitCounter <= 10;
      end else if (SymbolEdge && TXRunning) begin
	 BitCounter <= BitCounter - 1;
      end
  end

  always @ (posedge Clock) begin
     if (Reset) HasByte <= 1'b1;
     else if (BitCounter == 1 && SymbolEdge) HasByte <= 1'b0;
     else if (DataInValid) HasByte <= 1'b1;
  end

  always @ (posedge Clock) begin
     if (Reset) TXShift <= {1'b1,DataIn, 1'b0};
     else TXShift <= TXShift;
  end

   
endmodule // UATransmit
  //  module shReg(input clk, load, din, output 
  //  endmodule // shiftRegister
