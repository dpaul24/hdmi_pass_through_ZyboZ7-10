----------------------------------------------------------------------------------
-- Engineer: dpaul24
-- 
-- Create Date: 05/06/2018 12:11:34 AM
-- Design Name: 
-- Module Name: hdmi_pass_top - Behavioral
-- Project Name: hdmi_pass_through_ZyboZ7-10

-- Target Devices: Zybo Z7-10
-- Tool Versions: Vivado 2017.4
-- Description: 
-- Any HDMI source is fed into the HDMI Rx port of the Zybo Z7-10,  
-- passed through the dvi2rgb and rgb2dvi IP cores and is sent out 
-- un-altered through the HDMI Tx port.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity hdmi_pass_top is
    Port ( 
	    sysclk_i         : in  std_logic; -- 125MH System Clock Input
		async_reset_i    : in  std_logic; -- Reset switch on board
		-- HDMI In/Rx
		tmds_rx_clk_p_i  : in  std_logic;
        tmds_rx_clk_n_i  : in  std_logic;
        tmds_rx_data_p_i : in  std_logic_vector(2 downto 0);
        tmds_rx_data_n_i : in  std_logic_vector(2 downto 0);
		hdmi_rx_hpd_o    : out std_logic := '1'; -- HPD must be driven
		-- I2C
		sda_io           : inout std_logic;
		scl_io           : inout std_logic;
		-- HDMI Out/Tx
        tmds_tx_clk_p_o  : out std_logic;
        tmds_tx_clk_n_o  : out std_logic;
        tmds_tx_data_p_o : out std_logic_vector(2 downto 0);
        tmds_tx_data_n_o : out std_logic_vector(2 downto 0)	
         );
end hdmi_pass_top;


architecture hdmi_pass_top_arc of hdmi_pass_top is

component dvi2rgb_1
  port (
    TMDS_Clk_p    : in std_logic;
    TMDS_Clk_n    : in std_logic;
    TMDS_Data_p   : in std_logic_vector(2 downto 0);
    TMDS_Data_n   : in std_logic_vector(2 downto 0);
    RefClk        : in std_logic;
    aRst          : in std_logic;
    vid_pData     : out std_logic_vector(23 downto 0);
    vid_pVDE      : out std_logic;   
    vid_pHSync    : out std_logic;
    vid_pVSync    : out std_logic;
    PixelClk      : out std_logic;
    aPixelClkLckd : out std_logic;
    SDA_I         : in std_logic;
    SDA_O         : out std_logic;
    SDA_T         : out std_logic;
    SCL_I         : in std_logic;
    SCL_O         : out std_logic;
    SCL_T         : out std_logic;
    pRst          : in std_logic
  );
end component;

component rgb2dvi_0
  PORT (
    TMDS_Clk_p  : out std_logic;
    TMDS_Clk_n  : out std_logic;
    TMDS_Data_p : out std_logic_vector(2 downto 0);
    TMDS_Data_n : out std_logic_vector(2 downto 0);
    aRst        : in std_logic;
    vid_pData   : in std_logic_vector(23 downto 0);
    vid_pVDE    : in std_logic;
    vid_pHSync  : in std_logic;
    vid_pVSync  : in std_logic;
    PixelClk    : in std_logic
  );
end component;

component clk_wiz_125M_200M
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

signal vid_pData          : std_logic_vector(23 downto 0);
signal vid_pVDE           : std_logic;
signal vid_pHSync         : std_logic;
signal vid_pVSync         : std_logic;
signal pixelclk           : std_logic;
signal locked             : std_logic;
signal clk_200M           : std_logic;
signal pixel_clk_sync_rst : std_logic;

signal sda_i              : std_logic;
signal sda_o              : std_logic;
signal sda_t              : std_logic;
signal scl_i              : std_logic;
signal scl_o              : std_logic;
signal scl_t              : std_logic;

begin

clkwiz_inst : clk_wiz_125M_200M
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_200M,
  -- Status and control signals                
   reset   => async_reset_i,
   locked  => locked,
   -- Clock in ports
   clk_in1 => sysclk_i
 );

dvi2rgb_inst : dvi2rgb_1
  port map (
    TMDS_Clk_p    => tmds_rx_clk_p_i,
    TMDS_Clk_n    => tmds_rx_clk_n_i,
    TMDS_Data_p   => tmds_rx_data_p_i,
    TMDS_Data_n   => tmds_rx_data_n_i,
    RefClk        => clk_200M,
    aRst          => async_reset_i, --Active high asynchronous RefClk reset
    vid_pData     => vid_pData,
    vid_pVDE      => vid_pVDE,
    vid_pHSync    => vid_pHSync,
    vid_pVSync    => vid_pVSync,
    PixelClk      => pixelclk,
    aPixelClkLckd => open, -- 
    SDA_I         => sda_i,
    SDA_O         => sda_o,
    SDA_T         => sda_t,
    SCL_I         => scl_i,
    SCL_O         => scl_o,
    SCL_T         => scl_t,
    pRst          => '0'   -- Active high PixelClk synchronous reset
  );
  
SDA_IOBUF_inst: IOBUF
    generic map(
    DRIVE      => 12,
    IOSTANDARD => "DEFAULT",
    SLEW       => "SLOW"
	)
    port map(
    O  => sda_i,  -- Buffer output
    IO => sda_io, -- Buffer inout port(connect directly to top-level port)
    I  => sda_o,  -- Bufferinput
    T  => sda_t   -- 3-state enable input,high=input,low=output
    ); 

SCL_IOBUF_inst: IOBUF
    generic map(
    DRIVE      => 12,
    IOSTANDARD => "DEFAULT",
    SLEW       => "SLOW"
	)
    port map(
    O  => scl_i,  -- Buffer output
    IO => scl_io, -- Buffer inout port(connect directly to top-level port)
    I  => scl_o,  -- Buffer input
    T  => scl_t   -- 3-state enable input,high=input,low=output
    ); 
    
rgb2dvi_inst : rgb2dvi_0
  port map (
    TMDS_Clk_p  => tmds_tx_clk_p_o,
    TMDS_Clk_n  => tmds_tx_clk_n_o,
    TMDS_Data_p => tmds_tx_data_p_o,
    TMDS_Data_n => tmds_tx_data_n_o,
    aRst        => async_reset_i,
    vid_pData   => vid_pData,
    vid_pVDE    => vid_pVDE,
    vid_pHSync  => vid_pHSync,
    vid_pVSync  => vid_pVSync,
    PixelClk    => pixelclk
  );

end hdmi_pass_top_arc;
