library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fcunit is
	generic(NBITS      : natural;
			INPUT_SIZE : natural := 16);
	port(clk, rst: in std_logic;		 
		        x: in std_logic_vector(INPUT_SIZE*NBITS-1 downto 0);
		        w: in std_logic_vector(INPUT_SIZE*NBITS-1 downto 0);
		        b: in std_logic_vector(NBITS -1 downto 0);          
		        y: out std_logic_vector(2*NBITS+integer(ceil(log2(real(INPUT_SIZE)))) downto 0)      
	);
end entity fcunit;
	
architecture ppl of fcunit is
	
	type in_vector is array (0 to INPUT_SIZE -1) of signed(NBITS-1 downto 0);
	type add_vector is array (0 to INPUT_SIZE-1) of signed(2*NBITS+integer(ceil(log2(real(INPUT_SIZE))))-1 downto 0);
	type add_matrix is array (0 to integer(ceil(log2(real(INPUT_SIZE))))) of add_vector;
	type b_vector is array (0 to integer(ceil(log2(real(INPUT_SIZE))))+1) of signed(NBITS-1 downto 0);
	constant IN_VECTOR_ZERO : in_vector                := (others => (others => '0'));
	constant B_ZERO         : b_vector                 := (others => (others => '0'));
	constant ADD_ZERO      : add_matrix 			   := (others => (others => (others => '0')));
	constant ADD1_ZERO         : signed(2*NBITS+integer(ceil(log2(real(INPUT_SIZE))))-1 downto 0) := (others => '0');
	constant Y_ZERO         : signed(2*NBITS+integer(ceil(log2(real(INPUT_SIZE)))) downto 0) := (others => '0');
	-- input registers
	signal x_reg, x_next, w_reg, w_next : in_vector;
	signal b_reg, b_next                : b_vector;
	signal y_reg, y_next: signed(2*NBITS+integer(ceil(log2(real(INPUT_SIZE)))) downto 0);
	-- pipeline registers
	signal add_reg, add_next          : add_matrix;
begin
	process(x, w, b)
	begin
		b_next(0) <= signed(b);
		for i in 1 to INPUT_SIZE loop
			x_next(i-1) <= signed(x(NBITS*i-1 downto NBITS*(i-1)));
			w_next(i-1) <=signed(w(NBITS*i-1 downto NBITS*(i-1)));
		end loop;
	end process;
	
	REG: process(clk, rst)
	begin
		if rst = '1' then
			x_reg    <= IN_VECTOR_ZERO;
			w_reg    <= IN_VECTOR_ZERO;
			b_reg    <= B_ZERO;
			add_reg  <= ADD_ZERO;
			y_reg    <= Y_ZERO;
		elsif rising_edge(clk) then
			x_reg    <= x_next;
			w_reg    <= w_next;
			b_reg    <= b_next;
			add_reg <= add_next;
			y_reg    <= y_next;
		end if;
	end process REG;
	
	--generates INPUT_SIZE*NBITS multipliers
	b_next(1) <= b_reg(0);
	MULT_GEN: for i in 0 to INPUT_SIZE-1 generate
		add_next(0)(i) <= x_reg(i) * w_reg(i)+ADD1_ZERO;
	end generate MULT_GEN;
	
			
	-- generates a tree of adders 
	TREE_GEN: for i in 0 to integer(ceil(log2(real(INPUT_SIZE))))-1 generate 
				b_next(i+2) <= b_reg(i+1);
			ACC_GEN: for j in 0 to integer(INPUT_SIZE/(2**(i+1)))-1 generate
						--add_next(j+integer(INPUT_SIZE)+integer(INPUT_SIZE)*(1-1/(2**i))) <=  add_reg(j) 
						add_next(i+1)(j) <= add_reg(i)(j) + add_reg(i)(j+INPUT_SIZE/(2**(i+1)));
					end generate ACC_GEN;
				end generate TREE_GEN;
				
	y_next <= add_reg(integer(ceil(log2(real(INPUT_SIZE)))))(0)+b_reg(integer(ceil(log2(real(INPUT_SIZE))))+1)+Y_ZERO;
	y <= std_logic_vector(y_reg);
	end architecture ppl;
