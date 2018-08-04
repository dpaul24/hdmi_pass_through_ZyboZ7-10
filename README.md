# hdmi_pass_through_ZyboZ7-10

This is a simple design example showing how a HDMI signal can be passed through a FPGA without any type of processing on it. The input HDMI source to the FPGA development board can be the HDMI output from a laptop. A HDMI monitor can be connected to the output of the FPGA development board so that one can see the extended laptop display. It bascally shows how the HDMI signal can be broken down within an FPGA and be re-constructed again before sending it out.

The Digilent Zybo Z7-10 development board has been used for implementing this project. HDMI signals can be received on board through the HDMI Rx port and fed to the Digilent dvi2rgb IP core. This IP core then connects to the Digilent rgb2dvi IP core. The output of the rgb2dvi IP core is connected to the HDMI Tx port of the Zybo Z7-10 board.
