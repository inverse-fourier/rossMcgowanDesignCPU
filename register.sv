module register(
    input logic clk,
    input logic load,
    input logic enable,
    input logic [`DATA_WIDTH-1:0] dataIn,
    output logic [`DATA_WIDTH-1:0] dataOut,
);
    logic [`DATA_WIDTH-1:0] dataReg; // Internal Storage

    always_ff @(posedge clock) begin 
        if(load) begin
            dataReg <= dataIn;
        end   
    end

    aasign dataOut = (enable) ? dataReg : {`DATA_WIDTH{1'bz}};

endmodule