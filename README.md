# FIFO (First In First Out) Module

This repository contains an implementation of a First-In-First-Out (FIFO) buffer, a fundamental hardware module used in digital design for data storage and synchronization. The FIFO module allows data to be written in one clock domain and read in another, preserving the order of data.

## Key Features

- **Fixed Depth and Width:** Supports a configurable data width (8 bits) and depth (16 entries).
- **Asynchronous Reset:** Provides a reset signal to clear all stored data and reinitialize pointers.
- **Status Flags:** Includes `empty` and `full` flags to indicate FIFO status:
  - `empty`: Indicates the FIFO has no data to read.
  - `full`: Indicates the FIFO cannot accept more data.
- **Simple Control Logic:** Separate write (`wr`) and read (`rd`) control signals for ease of integration.

## Module Interface

### Inputs
- `clk`: Clock signal.
- `rst`: Asynchronous reset signal.
- `wr`: Write enable signal.
- `rd`: Read enable signal.
- `din`: 8-bit input data.

### Outputs
- `dout`: 8-bit output data.
- `empty`: Indicates FIFO is empty.
- `full`: Indicates FIFO is full.

## FIFO Operation

1. **Write Operation:**
   - Data is written to the FIFO when `wr` is high, and the FIFO is not full (`full = 0`).
   - The write pointer increments after each successful write.

2. **Read Operation:**
   - Data is read from the FIFO when `rd` is high, and the FIFO is not empty (`empty = 0`).
   - The read pointer increments after each successful read.

3. **Reset Operation:**
   - On asserting `rst`, the FIFO clears its contents, and both write and read pointers reset to 0.

4. **Full and Empty Flags:**
   - The `full` flag is asserted when the number of stored entries equals the FIFO depth.
   - The `empty` flag is asserted when there are no entries in the FIFO.

## Applications

- **Data Buffering:** Temporary storage of data between producer and consumer modules.
- **Clock Domain Crossing:** Safe transfer of data between different clock domains.
- **Pipeline Design:** Efficient data flow in multi-stage processing systems.

## Example Testbench

A testbench (`FIFO_tb`) is included in this repository to verify the functionality of the FIFO module. The testbench covers:
- Write and read operations.
- Handling of `empty` and `full` conditions.
- Boundary cases such as reset and overflow/underflow attempts.

## How to Run the Simulation

1. Clone the repository and navigate to the project directory.
2. Compile the Verilog files using your preferred simulator (e.g., ModelSim, XSIM).
3. Run the testbench and observe the output waveform to validate functionality.

## Contributing

Contributions to enhance the FIFO design or add more features are welcome. Feel free to open issues or submit pull requests.

## References

- Digital Design and Computer Architecture by David Money Harris and Sarah L. Harris.
- Online resources for FIFO implementation and applications in digital systems.



