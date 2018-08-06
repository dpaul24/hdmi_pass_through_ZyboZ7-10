# hdmi_pass_through_ZyboZ7-10

This is a simple design example showing how a HDMI signal can be passed through a FPGA without any type of processing on it. The input HDMI source to the FPGA development board can be the HDMI output from a laptop. A HDMI monitor can be connected to the output of the FPGA development board so that one can see the extended laptop display. It bascally shows how the HDMI signal can be broken down within an FPGA and be re-constructed again before sending it out.

The Digilent Zybo Z7-10 development board has been used for implementing this project. Xilinx and Digilent free IP cores have been used in this project.

While this project is very trivial, but I think it is a good starting point for beginners aspiring to do complicated video processing work on FPGAs. 
