# Defining the Compilor and Simulator
IVERILOG = iverilog -g2012
VVP = vvp

# Input Files
SRC = fft.sv tb_fft.sv

# Output Executable Files
OUT = sim.out

# Default Target
all: run

# Compile the Verilog files
$(OUT): $(SRC)
	$(IVERILOG) -o $(OUT) $(SRC)

# Run the simulation
run: $(OUT)
	$(VVP) $(OUT)


# Clean up generated files
clean:
	rm -f $(OUT) *.vcd
