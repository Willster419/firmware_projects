/////////////////////////////////////////////////////////////////////
// pipeline_tb.sv
// simple device testbench
// Willster419
// 2020/07/31
// A simple testbench for simulating the pipeline module
/////////////////////////////////////////////////////////////////////
//  Module: pipeline_tb
//
module pipeline_tb;

  // params
  parameter    CLOCK_PERIOD = 100ns;

  // logic for inputs
  logic        clk          = 1'b0;
  logic        rst          = 1'b1;
  logic [7:0]  input_data   = 8'h0;
  logic        input_valid  = 1'b0;

  // wires for outputs
  wire  [7:0]  output_data;
  wire         output_valid;

  // instance of pipeline
  pipeline #(
    .PIPELINE_LENGTH    (16)
  )
  my_pipeline(
    .clk                (clk),
    .rst                (rst),
    .input_data         (input_data),
    .input_valid        (input_valid),
    .output_data        (output_data),
    .output_valid       (output_valid)
  );

  // clock generation
  always #(CLOCK_PERIOD) clk = ~clk;

  initial begin
    // reset time
    $display("Waiting reset 20 clocks");
    for (int i = 0; i < 20; i++) begin
      @(posedge clk);
    end

    $display("Setting reset down and sending data");
    rst = 1'b0;
    @(posedge clk);

    // send in a valid input (driver)
    input_data = 8'hDB;
    input_valid = 1'b1;
    @(posedge clk);
    input_data = 8'h0;
    input_valid = 1'b0;
    @(posedge clk);
    $display("Data sent, wait for output valid");

    //wait for the output and finish
    @(posedge output_valid);
    @(posedge clk);
    $display("Done!");
    $finish;
  end

  always @(posedge clk) begin
    if(output_valid) begin
      $display("Recieved valid output of %0h", output_data);
    end
  end

endmodule: pipeline_tb
