//==========================================================
// Title: FPGA-Based Morse Code Encoder (Fixed)
// Target: Nexys A7 / Nexys DDR4 FPGA Board
//==========================================================

module morse_code_encoder (
    input clk,                  // 100 MHz clock
    input rst,                  // BTN0 - reset
    input start_single,         // BTN1 - store digit (number mode) or start (digit mode)
    input start_sequence,       // BTN2 - start encoding stored digits
    input [3:0] digit_in,       // Switches 0-3
    input mode_select,          // Switch 4: 0 = digit mode, 1 = number mode
    output reg led              // LED for Morse code
);

    // Clock timing constants
    parameter CLK_FREQ = 100_000_000;
    parameter DOT_DURATION = CLK_FREQ * 1;          // 1 sec
    parameter DASH_DURATION = CLK_FREQ * 3;         // 3 sec
    parameter GAP_DURATION = CLK_FREQ / 2;          // 0.5 sec
    parameter DIGIT_GAP_DURATION = CLK_FREQ * 10;   // 10 sec

    // FSM states
    typedef enum reg [3:0] {
        IDLE,
        STORE,
        LOAD,
        SEND,
        GAP,
        DIGIT_GAP,
        NEXT_DIGIT,
        DONE
    } state_t;

    state_t current_state, next_state;

    // Digit storage
    reg [3:0] digit_buffer[0:5];
    reg [2:0] digit_count;
    reg [2:0] digit_index;

    // Morse info
    reg [4:0] morse_pattern;
    reg [2:0] morse_length;
    reg [2:0] bit_index;

    reg [31:0] timer;
    reg [3:0] current_digit;

    // Button edge detection
    reg prev_start_single, prev_start_sequence;
    wire single_edge = start_single && ~prev_start_single;
    wire sequence_edge = start_sequence && ~prev_start_sequence;

    // Edge register
    always @(posedge clk) begin
        prev_start_single <= start_single;
        prev_start_sequence <= start_sequence;
    end

    // FSM state register
    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= IDLE;
        else     current_state <= next_state;
    end

    // FSM next-state logic
    always @(*) begin
        case (current_state)
            IDLE:
                next_state = (mode_select == 1) ? 
                             (sequence_edge ? LOAD : (single_edge ? STORE : IDLE)) :
                             (single_edge ? LOAD : IDLE);

            STORE:      next_state = IDLE;

            LOAD:       next_state = SEND;

            SEND:       next_state = (timer == 0) ? GAP : SEND;

            GAP: begin
                if (timer == 0) begin
                    if (bit_index == morse_length - 1)
                        next_state = (digit_index < digit_count - 1) ? DIGIT_GAP : DONE;
                    else
                        next_state = SEND;
                end else
                    next_state = GAP;
            end

            DIGIT_GAP:  next_state = (timer == 0) ? NEXT_DIGIT : DIGIT_GAP;

            NEXT_DIGIT: next_state = LOAD;

            DONE:       next_state = IDLE;

            default:    next_state = IDLE;
        endcase
    end

    // FSM output logic
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led <= 0;
            digit_count <= 0;
            digit_index <= 0;
            bit_index <= 0;
            timer <= 0;
            current_digit <= 0;
            for (i = 0; i < 6; i = i + 1)
                digit_buffer[i] <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    led <= 0;
                end

                STORE: begin
                    if (digit_count < 6) begin
                        digit_buffer[digit_count] <= digit_in;
                        digit_count <= digit_count + 1;
                    end
                end

                LOAD: begin
                    current_digit <= (mode_select) ? digit_buffer[digit_index] : digit_in;

                    case ((mode_select) ? digit_buffer[digit_index] : digit_in)
                        4'd0: begin morse_pattern <= 5'b11111; morse_length <= 5; end
                        4'd1: begin morse_pattern <= 5'b01111; morse_length <= 5; end
                        4'd2: begin morse_pattern <= 5'b00111; morse_length <= 5; end
                        4'd3: begin morse_pattern <= 5'b00011; morse_length <= 5; end
                        4'd4: begin morse_pattern <= 5'b00001; morse_length <= 5; end
                        4'd5: begin morse_pattern <= 5'b00000; morse_length <= 5; end
                        4'd6: begin morse_pattern <= 5'b10000; morse_length <= 5; end
                        4'd7: begin morse_pattern <= 5'b11000; morse_length <= 5; end
                        4'd8: begin morse_pattern <= 5'b11100; morse_length <= 5; end
                        4'd9: begin morse_pattern <= 5'b11110; morse_length <= 5; end
                        default: begin morse_pattern <= 5'b00000; morse_length <= 0; end
                    endcase

                    bit_index <= 0;
                    timer <= (morse_pattern[4] == 1) ? DASH_DURATION : DOT_DURATION;
                    led <= 1;
                end

                SEND: begin
                    if (timer > 0) timer <= timer - 1;
                    else begin
                        led <= 0;
                        timer <= GAP_DURATION;
                    end
                end

                GAP: begin
                    if (timer > 0) timer <= timer - 1;
                    else begin
                        bit_index <= bit_index + 1;
                        if (bit_index < morse_length - 1) begin
                            timer <= (morse_pattern[4 - (bit_index + 1)] == 1) ? DASH_DURATION : DOT_DURATION;
                            led <= 1;
                        end
                    end
                end

                DIGIT_GAP: begin
                    led <= 0;
                    if (timer == 0) timer <= DIGIT_GAP_DURATION;
                    else timer <= timer - 1;
                end

                NEXT_DIGIT: begin
                    digit_index <= digit_index + 1;
                end

                DONE: begin
                    led <= 0;
                    digit_index <= 0;
                    digit_count <= 0;
                end
            endcase
        end
    end

endmodule
