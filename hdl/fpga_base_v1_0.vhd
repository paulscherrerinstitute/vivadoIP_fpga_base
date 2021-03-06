--------------------------------------------------------------------------------
--                       Goran Marinkovic
--------------------------------------------------------------------------------
-- Unit    : fpga_base_v1_0.vhd
-- Author  : Goran Marinkovic
-- Version : $Revision: 1.1 $
--------------------------------------------------------------------------------
-- Copyright© Goran Marinkovic
--------------------------------------------------------------------------------
-- Comment : This is the source file for the fpga_base component.
--------------------------------------------------------------------------------
-- Std. library (platform) -----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Work library (platform) -----------------------------------------------------
library unisim;
use unisim.vcomponents.all;

-- Work library (application) --------------------------------------------------
library work;
use work.fpga_base_date_package.all;
use work.psi_common_array_pkg.all;
use work.fpga_base_scripted_info_pkg.all;

entity fpga_base_v1_0 is
   generic
   (
      -- Version parameters
      C_VERSION                   : std_logic_vector := X"FFFFFFFF";
      C_VERSION_MAJOR             : string  := "No Device";
      C_VERSION_MINOR             : string  := "No Project";
      -- Blinking LED
      C_FREQ_AXI_CLK_HZ           : integer := 125_000_000;
      C_FREQ_BLINKING_LED_HZ      : integer := 2;
      C_USE_INFO_FROM_SCRIPT      : boolean := false;
      -- Parameters of Axi Slave Bus Interface
      C_S00_AXI_ID_WIDTH          : integer := 1                             -- Width of ID for for write address, write data, read address and read data
   );
   port
   (
      --------------------------------------------------------------------------
      -- LED interface
      --------------------------------------------------------------------------
      o_led                       : out   std_logic_vector( 7 downto  0);
      --------------------------------------------------------------------------
      -- DIP switch interface
      --------------------------------------------------------------------------
      i_sw                        : in    std_logic_vector( 7 downto  0);
      --------------------------------------------------------------------------
      -- Blinking LED interface
      --------------------------------------------------------------------------
      o_blink                     : out   std_logic;
      --------------------------------------------------------------------------
      -- Axi Slave Bus Interface
      --------------------------------------------------------------------------
      -- System
      s00_axi_aclk                : in    std_logic;                                             -- Global Clock Signal
      s00_axi_aresetn             : in    std_logic;                                             -- Global Reset Signal. This signal is low active.
      -- Read address channel
      s00_axi_arid                : in    std_logic_vector(C_S00_AXI_ID_WIDTH-1   downto 0);     -- Read address ID. This signal is the identification tag for the read address group of signals.
      s00_axi_araddr              : in    std_logic_vector(7 downto 0);                          -- Read address. This signal indicates the initial address of a read burst transaction.
      s00_axi_arlen               : in    std_logic_vector(7 downto 0);                          -- Burst length. The burst length gives the exact number of transfers in a burst
      s00_axi_arsize              : in    std_logic_vector(2 downto 0);                          -- Burst size. This signal indicates the size of each transfer in the burst
      s00_axi_arburst             : in    std_logic_vector(1 downto 0);                          -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
      s00_axi_arlock              : in    std_logic;                                             -- Lock type. Provides additional information about the atomic characteristics of the transfer.
      s00_axi_arcache             : in    std_logic_vector(3 downto 0);                          -- Memory type. This signal indicates how transactions are required to progress through a system.
      s00_axi_arprot              : in    std_logic_vector(2 downto 0);                          -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
      s00_axi_arvalid             : in    std_logic;                                             -- Write address valid. This signal indicates that the channel is signaling valid read address and control information.
      s00_axi_arready             : out   std_logic;                                             -- Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
      -- Read data channel
      s00_axi_rid                 : out   std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);       -- Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
      s00_axi_rdata               : out   std_logic_vector(31 downto 0);                         -- Read Data
      s00_axi_rresp               : out   std_logic_vector(1 downto 0);                          -- Read response. This signal indicates the status of the read transfer.
      s00_axi_rlast               : out   std_logic;                                             -- Read last. This signal indicates the last transfer in a read burst.
      s00_axi_rvalid              : out   std_logic;                                             -- Read valid. This signal indicates that the channel is signaling the required read data.
      s00_axi_rready              : in    std_logic;                                             -- Read ready. This signal indicates that the master can accept the read data and response information.
      -- Write address channel
      s00_axi_awid                : in    std_logic_vector(C_S00_AXI_ID_WIDTH-1   downto 0);     -- Write Address ID
      s00_axi_awaddr              : in    std_logic_vector(7 downto 0);                          -- Write address
      s00_axi_awlen               : in    std_logic_vector(7 downto 0);                          -- Burst length. The burst length gives the exact number of transfers in a burst
      s00_axi_awsize              : in    std_logic_vector(2 downto 0);                          -- Burst size. This signal indicates the size of each transfer in the burst
      s00_axi_awburst             : in    std_logic_vector(1 downto 0);                          -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
      s00_axi_awlock              : in    std_logic;                                             -- Lock type. Provides additional information about the atomic characteristics of the transfer.
      s00_axi_awcache             : in    std_logic_vector(3 downto 0);                          -- Memory type. This signal indicates how transactions are required to progress through a system.
      s00_axi_awprot              : in    std_logic_vector(2 downto 0);                          -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
      s00_axi_awvalid             : in    std_logic;                                             -- Write address valid. This signal indicates that the channel is signaling valid write address and control information.
      s00_axi_awready             : out   std_logic;                                             -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
      -- Write data channel
      s00_axi_wdata               : in    std_logic_vector(31    downto 0);                      -- Write Data
      s00_axi_wstrb               : in    std_logic_vector(3 downto 0);                          -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
      s00_axi_wlast               : in    std_logic;                                             -- Write last. This signal indicates the last transfer in a write burst.
      s00_axi_wvalid              : in    std_logic;                                             -- Write valid. This signal indicates that valid write data and strobes are available.
      s00_axi_wready              : out   std_logic;                                             -- Write ready. This signal indicates that the slave can accept the write data.
      -- Write response channel
      s00_axi_bid                 : out   std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);       -- Response ID tag. This signal is the ID tag of the write response.
      s00_axi_bresp               : out   std_logic_vector(1 downto 0);                          -- Write response. This signal indicates the status of the write transaction.
      s00_axi_bvalid              : out   std_logic;                                             -- Write response valid. This signal indicates that the channel is signaling a valid write response.
      s00_axi_bready              : in    std_logic                                              -- Response ready. This signal indicates that the master can accept a write response.
   );
end fpga_base_v1_0;

architecture arch_imp of fpga_base_v1_0 is

   -----------------------------------------------------------------------------
   -- System
   -----------------------------------------------------------------------------
   constant LOW                   : std_logic := '0';
   constant LOW4                  : std_logic_vector( 3 downto  0) := (others => '0');
   constant LOW8                  : std_logic_vector( 7 downto  0) := (others => '0');
   constant LOW16                 : std_logic_vector(15 downto  0) := (others => '0');
   constant LOW32                 : std_logic_vector(31 downto  0) := (others => '0');
   constant HIGH                  : std_logic := '1';
   constant HIGH4                 : std_logic_vector( 3 downto  0) := (others => '1');
   constant HIGH8                 : std_logic_vector( 7 downto  0) := (others => '1');
   constant HIGH16                : std_logic_vector(15 downto  0) := (others => '1');
   constant HIGH32                : std_logic_vector(31 downto  0) := (others => '1');
   signal   s00_axi_areset        : std_logic;
   -----------------------------------------------------------------------------
   -- Register Interface
   -----------------------------------------------------------------------------
   constant C_NUM_REG             : integer := 64; -- only powers of 2 are allowed
   signal   reg_rdata             : t_aslv32(0 to C_NUM_REG-1) := (others => (others => '0'));
   signal   reg_wr                : std_logic_vector(C_NUM_REG-1 downto  0) := (others => '0');
   signal   reg_wdata             : t_aslv32(0 to C_NUM_REG-1) := (others => (others => '0'));
   -----------------------------------------------------------------------------
   -- Blinking LED
   -----------------------------------------------------------------------------
   constant C_BLINK_RATIO         : integer := C_FREQ_AXI_CLK_HZ/C_FREQ_BLINKING_LED_HZ;
   constant C_BLINK_CNT_MAX       : integer := C_BLINK_RATIO/2-1;
   signal   blink_cnt             : integer range 0 to C_BLINK_CNT_MAX;
   signal   blink_led             : std_logic;

begin

   -----------------------------------------------------------------------------
   -- System
   -----------------------------------------------------------------------------
   s00_axi_areset                 <= not s00_axi_aresetn;

   -----------------------------------------------------------------------------
   -- AXI decode instance
   -----------------------------------------------------------------------------
   axi_slave_reg_inst : entity work.psi_common_axi_slave_ipif
   generic map
   (
      -- Users parameters
      NumReg_g                    => C_NUM_REG,
      UseMem_g                    => false,
      ResetVal_g                  =>
      (
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000",
         X"00000000", X"00000000", X"00000000", X"00000000"
      ),
      -- Parameters of Axi Slave Bus Interface
      AxiIdWidth_g                => C_S00_AXI_ID_WIDTH,
      AxiAddrWidth_g              => 8
   )
   port map
   (
      --------------------------------------------------------------------------
      -- Axi Slave Bus Interface
      --------------------------------------------------------------------------
      -- System
      s_axi_aclk                  => s00_axi_aclk,
      s_axi_aresetn               => s00_axi_aresetn,
      -- Read address channel
      s_axi_arid                  => s00_axi_arid,
      s_axi_araddr                => s00_axi_araddr,
      s_axi_arlen                 => s00_axi_arlen,
      s_axi_arsize                => s00_axi_arsize,
      s_axi_arburst               => s00_axi_arburst,
      s_axi_arlock                => s00_axi_arlock,
      s_axi_arcache               => s00_axi_arcache,
      s_axi_arprot                => s00_axi_arprot,
      s_axi_arvalid               => s00_axi_arvalid,
      s_axi_arready               => s00_axi_arready,
      -- Read data channel
      s_axi_rid                   => s00_axi_rid,
      s_axi_rdata                 => s00_axi_rdata,
      s_axi_rresp                 => s00_axi_rresp,
      s_axi_rlast                 => s00_axi_rlast,
      s_axi_rvalid                => s00_axi_rvalid,
      s_axi_rready                => s00_axi_rready,
      -- Write address channel
      s_axi_awid                  => s00_axi_awid,
      s_axi_awaddr                => s00_axi_awaddr,
      s_axi_awlen                 => s00_axi_awlen,
      s_axi_awsize                => s00_axi_awsize,
      s_axi_awburst               => s00_axi_awburst,
      s_axi_awlock                => s00_axi_awlock,
      s_axi_awcache               => s00_axi_awcache,
      s_axi_awprot                => s00_axi_awprot,
      s_axi_awvalid               => s00_axi_awvalid,
      s_axi_awready               => s00_axi_awready,
      -- Write data channel
      s_axi_wdata                 => s00_axi_wdata,
      s_axi_wstrb                 => s00_axi_wstrb,
      s_axi_wlast                 => s00_axi_wlast,
      s_axi_wvalid                => s00_axi_wvalid,
      s_axi_wready                => s00_axi_wready,
      -- Write response channel
      s_axi_bid                   => s00_axi_bid,
      s_axi_bresp                 => s00_axi_bresp,
      s_axi_bvalid                => s00_axi_bvalid,
      s_axi_bready                => s00_axi_bready,
      --------------------------------------------------------------------------
      -- Register Interface
      --------------------------------------------------------------------------
      i_reg_rdata                 => reg_rdata,
      o_reg_wr                    => reg_wr,
      o_reg_wdata                 => reg_wdata
   );

   -----------------------------------------------------------------------------
   -- Version of the firmware assigned by user.
   -----------------------------------------------------------------------------
   reg_rdata( 0)                  <= C_VERSION when not C_USE_INFO_FROM_SCRIPT else 
                                     BuildGitHash_c;

   -----------------------------------------------------------------------------
   -- Firmware compilation date and time. This values are set during synthesis
   -- by a tcl script run by Vivado after synthesis. Hence it updates every
   -- time the code is compiled.
   -----------------------------------------------------------------------------
   fpga_base_date_inst: entity work.fpga_base_date
   generic map (
      C_DATE_YEAR           => BuildYear_c,
      C_DATE_MONTH          => BuildMonth_c,
      C_DATE_DAY            => BuildDay_c,
      C_DATE_HOUR           => BuildHour_c,
      C_DATE_MINUTE         => BuildMinute_c,
      C_USE_GENERIC_DATE    => C_USE_INFO_FROM_SCRIPT
   )
   port map
   (
      --------------------------------------------------------------------------
      -- System
      --------------------------------------------------------------------------
      i_clk                       => s00_axi_aclk,
      --------------------------------------------------------------------------
      -- Date and time
      --------------------------------------------------------------------------
      o_year                      => reg_rdata( 1),
      o_month                     => reg_rdata( 2),
      o_day                       => reg_rdata( 3),
      o_hour                      => reg_rdata( 4),
      o_minute                    => reg_rdata( 5)
   );

   -----------------------------------------------------------------------------
   -- Software compilation date and time. This values are set during start of
   -- the processor by copying the string generated by C preprocessor macros
   -- __DATE__ and __TIME__
   -----------------------------------------------------------------------------
   reg_rdata( 6)                  <= reg_wdata( 6);
   reg_rdata( 7)                  <= reg_wdata( 7);
   reg_rdata( 8)                  <= reg_wdata( 8);
   reg_rdata( 9)                  <= reg_wdata( 9);
   reg_rdata(10)                  <= reg_wdata(10);

   -----------------------------------------------------------------------------
   -- Add project and facility strings to registers
   -----------------------------------------------------------------------------
   c_version_major_gen_loop: for i in 0 to (C_VERSION_MAJOR'high - 1) generate
      reg_rdata(16 + (i / 4))(((3 - (i rem 4)) * 8 + 7) downto ((3 - (i rem 4)) * 8)) <= std_logic_vector(to_unsigned(character'pos(C_VERSION_MAJOR(i + 1)), 8));
   end generate;

   c_version_minor_gen_loop: for i in 0 to (C_VERSION_MINOR'high - 1) generate
      reg_rdata(20 + (i / 4))(((3 - (i rem 4)) * 8 + 7) downto ((3 - (i rem 4)) * 8)) <= std_logic_vector(to_unsigned(character'pos(C_VERSION_MINOR(i + 1)), 8));
   end generate;

   -----------------------------------------------------------------------------
   -- LED
   -----------------------------------------------------------------------------
   reg_rdata(24)( 7 downto  0)    <= reg_wdata(24)( 7 downto  0);
   o_led                          <= reg_wdata(24)( 7 downto  0);
   
   -----------------------------------------------------------------------------
   -- BLINKING LED
   -----------------------------------------------------------------------------
   p_blink : process(s00_axi_aclk)
   begin
      if rising_edge(s00_axi_aclk) then
         if s00_axi_aresetn = '0' then
            blink_cnt <= 0;
            blink_led <= '0';
         else
            if blink_cnt = C_BLINK_CNT_MAX then
               blink_cnt <= 0;
               blink_led <= not blink_led;
            else
               blink_cnt <= blink_cnt + 1;
            end if;
         end if;
      end if;
   end process;
   o_blink <= blink_led;
   
   -----------------------------------------------------------------------------
   -- DIP switch interface
   -----------------------------------------------------------------------------
   reg_rdata(25)( 7 downto  0)    <= i_sw;

end arch_imp;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
