

module tap_controller ( input logic tclk, trst, tdi, tms,
                        output logic tdo );


    typedef enum logic[4:0] { RESET, IDLE,
    SELECT_DR_SCAN, CAPTURE_DR, SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR, UPDATE_DR,
    SELECT_IR_SCAN, CAPTURE_IR, SHIFT_IR, EXIT1_IR, PAUSE_IR, EXIT2_IR, UPDATE_IR } state_t;

    state_t current_state, next_state;

    //current_state assignment
    always_ff @(posedge tclk or trst) begin
        if(trst) begin
            current_state <= RESET;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    //next state logic
    always_ff @(posedge tclk or trst or tms) begin
        if(trst) begin
            next_state <= RESET;
        end
        else begin
            case (current_state)
                RESET :
                    if (tms)
                        next_state <= RESET;
                    else
                        next_state <= IDLE;
                IDLE :
                    if (tms)
                        next_state <= SELECT_DR_SCAN;
                    else
                        next_state <= IDLE;
                SELECT_DR_SCAN :
                    if (tms)
                        next_state <= SELECT_IR_SCAN;
                    else
                        next_state <= CAPTURE_DR;
                CAPTURE_DR :
                    if (tms)
                        next_state <= EXIT1_DR;
                    else
                        next_state <= SHIFT_DR;
                SHIFT_DR :
                    if (tms)
                        next_state <= EXIT1_DR;
                    else
                        next_state <= SHIFT_DR;
                EXIT1_DR :
                    if (tms)
                        next_state <= UPDATE_DR;
                    else
                        next_state <= PAUSE_DR;
                PAUSE_DR :
                    if (tms)
                        next_state <= EXIT2_DR;
                    else
                        next_state <= PAUSE_DR;
                EXIT2_DR :
                    if (tms)
                        next_state <= UPDATE_DR;
                    else
                        next_state <= SHIFT_DR;
                UPDATE_DR :
                    if (tms)
                        next_state <= SELECT_DR_SCAN;
                    else
                        next_state <= IDLE;
                SELECT_IR_SCAN :
                    if (tms)
                        next_state <= RESET;
                    else
                        next_state <= CAPTURE_IR;
                CAPTURE_IR :
                    if (tms)
                        next_state <= EXIT1_IR;
                    else
                        next_state <= SHIFT_IR;
                SHIFT_IR :
                    if (tms)
                        next_state <= EXIT1_IR;
                    else
                        next_state <= SHIFT_IR;
                EXIT1_IR :
                    if (tms)
                        next_state <= UPDATE_IR;
                    else
                        next_state <= PAUSE_IR;
                PAUSE_IR :
                    if (tms)
                        next_state <= EXIT2_IR;
                    else
                        next_state <= PAUSE_IR;
                EXIT2_IR :
                    if (tms)
                        next_state <= UPDATE_IR;
                    else
                        next_state <= SHIFT_IR;
                UPDATE_IR :
                    if (tms)
                        next_state <= SELECT_DR_SCAN;
                    else
                        next_state <= IDLE;
            endcase
            
        end
    end
    
endmodule
