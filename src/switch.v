`timescale 1ns / 1ps

module switch #(
    // Parameters to make the module reusable
    parameter CLK_FREQ     = 50_000_000,  // System clock frequency (e.g., 50MHz)
    parameter DEBOUNCE_MS  = 20           // Debounce time in milliseconds
)(
    input  wire  clk,          // System clock
    input  wire  rst_n,        // Asynchronous active-low reset
    input  wire  switch_in,    // Raw input from the physical switch
    output reg   switch_out    // Debounced and stable output signal
);

// Calculate the number of clock cycles needed for the debounce delay
localparam DEBOUNCE_COUNT = (CLK_FREQ / 1000) * DEBOUNCE_MS;

// Internal signals
reg switch_sync_r1;  // First stage of synchronizer
reg switch_sync_r2;  // Second stage of synchronizer
reg [31:0] debounce_counter; // Counter for debounce delay

// Stage 1: Synchronize the asynchronous switch input to the system clock domain
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        switch_sync_r1 <= 1'b0;
        switch_sync_r2 <= 1'b0;
    end else begin
        switch_sync_r1 <= switch_in;
        switch_sync_r2 <= switch_sync_r1;
    end
end

// Stage 2: Debounce logic using a counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        switch_out       <= 1'b0;
        debounce_counter <= 32'd0;
    end else begin
        // If the synchronized input is different from the stable output
        if (switch_sync_r2 != switch_out) begin
            // Increment the counter
            debounce_counter <= debounce_counter + 1;
            // If the counter reaches the target value, the signal has been stable long enough
            if (debounce_counter >= DEBOUNCE_COUNT) begin
                switch_out       <= switch_sync_r2; // Update the stable output
                debounce_counter <= 32'd0;           // Reset the counter
            end
        // If the input signal flips back (a glitch), reset the counter
        end else begin
            debounce_counter <= 32'd0;
        end
    end
end

endmodule