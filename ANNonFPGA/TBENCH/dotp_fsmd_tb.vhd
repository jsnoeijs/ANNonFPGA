

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dotp_fsmd_tb is end;

architecture bench of dotp_fsmd_tb is

	constant CLK_PER : time := 10 ns;
	constant NBITS : natural := 8;
	constant NBELMTS : natural := 8;
	
	component dotp_fsmd is  
	
	port (
   		
   		signal start, clk, rst: in std_logic;
		signal a_in, b_in: in std_logic_vector(NBITS*NBELMTS-1 downto 0);
		signal ready: out std_logic;
		signal z_out: out std_logic_vector(2*NBITS + integer(ceil(log(real(NBELMTS))))-1 downto 0));

	end component dotp_fsmd;
	
	subtype dp_in is std_logic_vector(63 downto 0);

   signal clk_tb    : std_logic := '0';
   signal rst_tb,
          start_tb,
          ready_tb  : std_logic;
   signal a_in_tb,
          b_in_tb   : dp_in;
   signal z_out_tb  : std_logic_vector(18 downto 0);
   signal z_exp     : integer;

   signal done   : boolean := FALSE;

begin

	DUV : component dotp_fsmd
	port map (start => start_tb, clk => clk_tb, rst => rst_tb, a_in => a_in_tb, b_in => b_in_tb, ready => ready_tb, z_out => z_out_tb);

   clk_tb <= not clk_tb after CLK_PER/2 when not done;
   rst_tb <= '0', '1' after CLK_PER/4, '0' after 3*CLK_PER/4;

   STIM : process

      function dotprod (a_tb, b_tb : dp_in) return integer is
         variable res : integer := 0;
      --
      -- compute the expected dot product value
      --
      begin
         for i in 0 to 7 loop
            res := res +
                   to_integer(signed(a_tb(i*8+7 downto i*8)))
                   * to_integer(signed(b_tb(i*8+7 downto i*8)));
         end loop;
         return res;
      end function dotprod;

      procedure compute (a, b : in integer) is
      begin
         wait until falling_edge(clk_tb);
         for i in 0 to 7 loop
      		a_in_tb(i*8+7 downto i*8) <= std_logic_vector(to_signed(a, 8));
      		b_in_tb(i*8+7 downto i*8) <= std_logic_vector(to_signed(b, 8));
         end loop;
         start_tb <= '1';
         wait until falling_edge(clk_tb);
         z_exp <= dotprod(a_in_tb, b_in_tb);
         start_tb <= '0';
         wait until ready_tb = '1';
         assert to_integer(signed(z_out_tb)) = z_exp;
      end procedure compute;

   begin
      start_tb <= '0';
      wait until falling_edge(rst_tb);
      wait until falling_edge(clk_tb);

      compute(2, 4);
      compute(-55, 99);
      compute(127, 127);
      compute(-128, -128);
      compute(-128, 127);

      wait until rising_edge(clk_tb);
      done <= TRUE;
      wait;
   end process STIM;

end architecture bench;
