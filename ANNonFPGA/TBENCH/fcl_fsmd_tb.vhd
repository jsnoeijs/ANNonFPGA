library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity fcl_fsmd_tb is
	end entity fcl_fsmd_tb;
	
architecture bench of fcl_fsmd_tb is
	
	constant NBITS : natural := 8;
	constant NB_SAMPLES : natural := 10;
	constant INPUT_SIZE : natural := 4;  -- number of features (better if power of 2)
	constant OUTPUT_SIZE : natural := 2;
	constant CLK_PER : time := 10*ns;
	constant CHECK_DELAY : time := 3*CLK_PER/4;
	
	signal clk_tb : std_logic := '0';
	signal rst_tb : std_logic;
	signal start_tb  : std_logic;
	signal ready_tb  : std_logic;
	signal x_tb : std_logic_vector(NB_SAMPLES*INPUT_SIZE*NBITS-1 downto 0);
	signal w_tb : std_logic_vector(INPUT_SIZE*OUTPUT_SIZE*NBITS-1 downto 0);
	signal b_tb : std_logic_vector(OUTPUT_SIZE*NBITS -1 downto 0);
	signal y_tb : std_logic_vector(OUTPUT_SIZE*(2*NBITS + integer(ceil(log2(real(INPUT_SIZE))))+1)-1 downto 0);
	signal stop : boolean := false;
	
	type x_vector is array(0 to INPUT_SIZE-1) of std_logic_vector(NBITS-1 downto 0);
	type x_matrix is array(0 to NB_SAMPLES-1) of x_vector;
	type w_matrix is array(0 to OUTPUT_SIZE-1) of x_vector;
	type b_vector is array (0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS-1 downto 0);
	type x_temp_vector is array(0 to NB_SAMPLES-1) of std_logic_vector(NBITS*INPUT_SIZE-1 downto 0);
	type w_temp_vector is array(0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS*INPUT_SIZE-1 downto 0);
	type res_vector is array(0 to OUTPUT_SIZE-1) of integer;
	type res_matrix is array(0 to NB_SAMPLES-1) of res_vector;
	--type x_prev is array(1 to 5) of std_logic_vector(NB_SAMPLES*INPUT_SIZE*NBITS-1 downto 0);
	--type w_prev is array(1 to 5) of std_logic_vector(INPUT_SIZE*OUTPUT_SIZE*NBITS-1 downto 0);
	--type b_prev is array(1 to 5) of std_logic_vector(OUTPUT_SIZE*NBITS -1 downto 0);
	type x_prev is array (1 to 5) of x_matrix;
	type w_prev is array (1 to 5) of w_matrix;
	type b_prev is array (1 to 5) of b_vector;
	type y_vector is array(0 to OUTPUT_SIZE-1) of std_logic_vector(2*NBITS + integer(ceil(log2(real(INPUT_SIZE)))) downto 0);
	type x_int_vector is array(0 to NB_SAMPLES-1) of integer;
	type w_int_vector is array (0 to OUTPUT_SIZE-1) of integer;
	signal x_temp  : x_temp_vector;
	signal w_temp  : w_temp_vector;
	signal x_verif :  x_matrix;
	signal w_verif : w_matrix;
	signal b_verif : b_vector;
	signal check : std_logic;
	signal x_prev_tb : x_prev;
    signal w_prev_tb : w_prev;
    signal b_prev_tb : b_prev;
    signal y_exp  : res_matrix;
begin 
	
	DUV: entity work.fcl
		generic map(
			NBITS       => NBITS,
			NB_SAMPLES  => NB_SAMPLES,
			INPUT_SIZE  => INPUT_SIZE,
			OUTPUT_SIZE => OUTPUT_SIZE
		)
		port map(
			clk   => clk_tb,
			rst   => rst_tb,
			start => start_tb,
			ready => ready_tb,
			x     => x_tb,
			w     => w_tb,
			b     => b_tb,
			y     => y_tb
		);
	clk_tb <= not clk_tb after CLK_PER*1/2 when not stop;
	rst_tb <= '0', '1' after CLK_PER*1/4, '0' after CLK_PER*3/4;
	
	
	INIT: process(x_tb, w_tb, b_tb)
	begin
			for j in 1 to NB_SAMPLES loop
				x_temp(j-1) <= x_tb(j*INPUT_SIZE*NBITS-1 downto (j-1)*INPUT_SIZE*NBITS);
			end loop;
			for j in 1 to OUTPUT_SIZE loop
				w_temp(j-1) <= w_tb(j*INPUT_SIZE*NBITS-1 downto (j-1)*INPUT_SIZE*NBITS);
				b_verif(j-1) <= b_tb(j*NBITS-1 downto (j-1)*NBITS);
			end loop;
	end process INIT;
	
	INIT_2: process(x_temp, w_temp)
	begin
		for j in 0 to NB_SAMPLES-1 loop
			for i in 1 to INPUT_SIZE loop
			x_verif(j)(i-1) <= x_temp(j)(i*NBITS-1 downto (i-1)*NBITS);
			end loop;
		end loop;
		for j in 0 to OUTPUT_SIZE-1 loop
			for i in 1 to INPUT_SIZE loop
			w_verif(j)(i-1) <= w_temp(j)(i*NBITS-1 downto (i-1)*NBITS);
			end loop;
		end loop;
	end process INIT_2; 
	
	process
	procedure do_test (x: x_int_vector; w, b : w_int_vector; variable ibuf : inout natural) is
      --
      -- a_tb(i) = a, b_tb(i) = b
      --
      begin
      	for i in 0 to NB_SAMPLES-1 loop
      		for j in 1 to INPUT_SIZE loop
      		--x_tb(i*INPUT_SIZE+NBITS-1 downto i*INPUT_SIZE) <= std_logic_vector(to_signed(integer(x*16384.0), NBITS));
      		--w_tb(i*INPUT_SIZE+NBITS-1 downto i*INPUT_SIZE) <= std_logic_vector(to_signed(integer(w*16384.0), NBITS));
      		
      			x_tb(NBITS*(j+INPUT_SIZE*i)-1 downto NBITS*(j-1+INPUT_SIZE*i)) <= std_logic_vector(to_signed(x(i), NBITS));
      		end loop;
      	end loop;
      	for i in 0 to OUTPUT_SIZE-1 loop
      		for j in 1 to INPUT_SIZE loop
      			w_tb(NBITS*(j+INPUT_SIZE*i)-1 downto NBITS*(j-1+INPUT_SIZE*i)) <= std_logic_vector(to_signed(w(i), NBITS));
      		end loop;
		end loop;
      	--b_tb <= std_logic_vector(to_signed(integer(b*16384.0),NBITS));
      	for i in 1 to OUTPUT_SIZE loop
  			b_tb(NBITS*i -1 downto NBITS*(i-1)) <= std_logic_vector(to_signed(b(i-1), NBITS));
  		end loop;
         wait until falling_edge(clk_tb);
         x_prev_tb(ibuf+1) <= x_verif;
         w_prev_tb(ibuf+1) <= w_verif;
         b_prev_tb(ibuf+1) <= b_verif;
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
	start_tb <= '1';
	wait until falling_edge(clk_tb);
	start_tb <= '0';
    do_test((2, 4, 6, 8, 10, 8, 6, 4, 2, 0), (1, 2), (0, 0), ibuf);
	--do_test((5, 6, 7, 8, 9, 10, 11, 12, 13, 14), (2, 1), (1, 2), ibuf);
	--do_test((-10, -8, -6, -8, -10, 8, -6, 4, -2, 0), (-1, -2), (2, 1), ibuf);
	--do_test((-2, 4, -6, 8, -10, 8, -6, 4, -2, 0), (1, -2), (-1, -2), ibuf);
	--do_test((127, 120, -128, 50, -45, -39, 35, -73, 78, 4), (-1, 2), (-1, 1), ibuf);
	
      for i in 1 to 15 loop
         wait until falling_edge(clk_tb);
      end loop;
      stop <= true;
      wait;
  end process;
  
	VERIFY : process is

      function fcl(x_verif: x_matrix; w_verif: w_matrix ; b_verif: b_vector) return res_matrix is
         variable res : res_matrix:= (others => (others => 0));
      --
      -- compute expected result
      --
  begin
      for k in 0 to NB_SAMPLES-1 loop
		 for j in 0 to OUTPUT_SIZE-1 loop
         	for i in 0 to INPUT_SIZE-1 loop
         		res(k)(j) := res(k)(j)+(to_integer(signed(x_verif(k)(i)))*to_integer(signed(w_verif(j)(i))));
      		end loop;
         res(k)(j) := res(k)(j)+to_integer(signed(b_verif(j)));
         end loop;
      end loop;
      return res;
      end function fcl;

      variable first : boolean := true;
      variable i : natural := 0;

   begin
      check <= '0';
      wait until falling_edge(clk_tb);
      wait until falling_edge(clk_tb);
      loop
         if first then
            for i in 1 to 14 loop
               wait until falling_edge(clk_tb);
            end loop;
            wait until rising_edge(clk_tb);
            first := false;
         else
--            report "--- i = " & natural'image(i);
            y_exp <= fcl(x_prev_tb(i+1), w_prev_tb(i+1), b_prev_tb(i+1));
            i := (i + 1) mod 5;
            wait for CHECK_DELAY;
            if stop then
               exit;
            end if;
            check <= '1';
            for i in 0 to NB_SAMPLES-1 loop
            	for j in 1 to OUTPUT_SIZE loop
            		assert to_integer(signed(y_tb(j*(2*NBITS + integer(ceil(log2(real(INPUT_SIZE))))+1)-1 downto (j-1)*(2*NBITS + integer(ceil(log2(real(INPUT_SIZE))))+1)))) = y_exp(i)(j-1);
            	end loop;
            end loop;
            wait for 1 ns;
            check <= '0';
            wait until rising_edge(clk_tb);
         end if;
      end loop;
      wait;
   end process VERIFY;
	
	
	
	
	
	
	end architecture bench;