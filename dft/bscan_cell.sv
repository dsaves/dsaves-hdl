//MIT License
//
//Copyright (c) 2017  Danny Savory
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


module bscan_cell (input logic data_in, scan_in, shift_DR, capture_DR, update_DR, mode, trst,
                    output logic data_out);
                    
    logic capture_ff_input, capture_ff_output, update_latch_output;
    
    always_comb begin
        if(shift_DR) begin
            capture_ff_input = scan_in;
        end
        else begin
            capture_ff_input = data_in;
        end
    end
    
    
    always_ff @(posedge capture_DR) begin
        if(trst) begin
            capture_ff_output <= 0;
        end
        else begin
            capture_ff_output <= capture_ff_input;
        end
    end
    
    always_latch begin
        if(trst) begin
            update_latch_output <= 0;
        end
        else begin
            update_latch_output <= capture_ff_output;
        end
    end
    
    always_comb begin
        if(mode) begin
            data_out = update_latch_output;
        end
        else begin
            data_out = data_in;
        end
    end
endmodule
    
    