library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- 1 instance of Fully connected layer
-- takes N inputs and produces 1 output
-- pipelined architecture

entity fcunit_ppl_tb is
	end entity fcunit_ppl_tb;


architecture bench of fcunit_ppl_tb is

   constant CLK_PER     : time := 10 ns;
   constant CHECK_DELAY : time := 3*CLK_PER/4;
   constant NBITS : natural := 8;
   constant INPUT_SIZE : natural := 16;
   

   subtype x_type is std_logic_vector(NBITS*INPUT_SIZE-1 downto 0);
   subtype b_type is std_logic_vector(NBITS-1 downto 0);
   subtype y_type is std_logic_vector(2*NBITS+integer(ceil(log2(real(INPUT_SIZE)))) downto 0);
   type x_prev is array (1 to 5) of x_type;
   type b_prev is array(1 to 5) of b_type;
   
   signal clk_tb : std_logic := '0';
   signal rst_tb : std_logic;
   signal x_tb   : x_type;
   signal w_tb   : x_type;
   signal b_tb   : b_type;
   signal y_tb   : y_type;
   signal stop   : boolean := false;
   signal x_prev_tb : x_prev;
   signal w_prev_tb : x_prev;
   signal b_prev_tb : b_prev;
   signal check  : std_logic;
   signal y_exp  : integer;
begin

	DUV : entity work.fcunit(ppl)
		generic map(NBITS => NBITS, INPUT_SIZE => INPUT_SIZE)
		port map (clk => clk_tb, rst => rst_tb, x => x_tb, w => w_tb, b => b_tb,y => y_tb);

   clk_tb <= not clk_tb after CLK_PER/2 when not stop;
   rst_tb <= '0', '1' after CLK_PER/4, '0' after 3*CLK_PER/4;
   process

      procedure do_test (x, w, b : integer; variable ibuf : inout natural) is
      --
      -- a_tb(i) = a, b_tb(i) = b
      --
      begin
        for i in 1 to INPUT_SIZE loop
      		--x_tb(i*INPUT_SIZE+NBITS-1 downto i*INPUT_SIZE) <= std_logic_vector(to_signed(integer(x*16384.0), NBITS));
      		--w_tb(i*INPUT_SIZE+NBITS-1 downto i*INPUT_SIZE) <= std_logic_vector(to_signed(integer(w*16384.0), NBITS));
      		
      		x_tb(i*NBITS-1 downto (i-1)*NBITS) <= std_logic_vector(to_signed(x, NBITS));
      		w_tb(i*NBITS-1 downto (i-1)*NBITS) <= std_logic_vector(to_signed(w, NBITS));
      	end loop;
      	--b_tb <= std_logic_vector(to_signed(integer(b*16384.0),NBITS));
      	b_tb <= std_logic_vector(to_signed(b, NBITS));
         wait until falling_edge(clk_tb);
         x_prev_tb(ibuf+1) <= x_tb;
         w_prev_tb(ibuf+1) <= w_tb;
         b_prev_tb(ibuf+1) <= b_tb;
         ibuf := (ibuf + 1) mod 5;
      end procedure do_test;

      variable ibuf : natural := 0;

   begin
      wait until falling_edge(clk_tb);
      wait until falling_edge(clk_tb);

--  do_test(0.5, 0.9, 0.1, ibuf);
--	do_test(0.5, -0.9, 0.7, ibuf);
--	do_test(-0.4, -0.2, -0.5, ibuf);
--	do_test(-0.1, -0.15,0.45, ibuf);
--	do_test(-0.78, 0.23, 0.7, ibuf);

    do_test(2, 4, 0, ibuf);
	do_test(-55, 99, 1, ibuf);
	do_test(127, 127, 120, ibuf);
	do_test(-128, -128, 100, ibuf);
	do_test(-128, 127, -30, ibuf);

      for i in 1 to 6 loop
         wait until falling_edge(clk_tb);
      end loop;
      stop <= true;
      wait;
   end process;

   VERIFY : process is

      function fcunit(x_tb, w_tb: x_type; b_tb: b_type) return integer is
         variable res : integer := 0;
      --
      -- compute the expected dot product value
      --
      begin
         for i in 1 to INPUT_SIZE loop
            res := res +
                   (to_integer(signed(x_tb(i*NBITS-1 downto (i-1)*NBITS)))
                  * to_integer(signed(w_tb(i*NBITS-1 downto (i-1)*NBITS))));
            
         end loop;
         res := res+to_integer(signed(b_tb));
         return res;
      end function fcunit;

      variable first : boolean := true;
      variable i : natural := 0;

   begin
      check <= '0';
      wait until falling_edge(clk_tb);
      wait until falling_edge(clk_tb);
      loop
         if first then
            for i in 1 to 5 loop
               wait until falling_edge(clk_tb);
            end loop;
            wait until rising_edge(clk_tb);
            first := false;
         else
--            report "--- i = " & natural'image(i);
            y_exp <= fcunit(x_prev_tb(i+1), w_prev_tb(i+1), b_prev_tb(i+1));
            i := (i + 1) mod 5;
            wait for CHECK_DELAY;
            if stop then
               exit;
            end if;
            check <= '1';
            assert to_integer(signed(y_tb)) = y_exp;
            wait for 1 ns;
            check <= '0';
            wait until rising_edge(clk_tb);
         end if;
      end loop;
      wait;
   end process VERIFY;

end architecture bench;