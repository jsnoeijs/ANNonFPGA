library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fcl is
	generic(NBITS : natural := 16;
			NB_SAMPLES : natural := 10;
			INPUT_SIZE : natural := 8;
			OUTPUT_SIZE : natural := 2);
	port(clk, rst: in std_logic;
		 start : in std_logic;
		 ready: out std_logic;
		 x: in std_logic_vector(NB_SAMPLES*INPUT_SIZE*NBITS-1 downto 0);
		 w: in std_logic_vector(OUTPUT_SIZE*INPUT_SIZE*NBITS -1 downto 0);
		 b: in std_logic_vector(OUTPUT_SIZE*NBITS -1 downto 0);
		 y: out std_logic_vector(OUTPUT_SIZE*(2*NBITS + integer(ceil(log2(real(INPUT_SIZE))))+1)-1 downto 0)
	);
	end entity fcl;
	
architecture fsmd of fcl is
	
	--type in_vector is array (0 to INPUT_SIZE -1) of signed(NBITS-1 downto 0);
	--type out_vector is array (0 to OUTPUT_SIZE -1) of signed(NBITS -1 downto 0);
	--type in_matrix is array (0 to NB_SAMPLES -1) of in_vector;
	
	--type w_matrix is array (0 to INPUT_SIZE -1) of out_vector;
	--type out_matrix is array (0 to NB_SAMPLES -1) of out_vector;
	
	type state_type is (IDLE, LOAD, CALC);
	subtype y_bits is std_logic_vector((2*NBITS + integer(ceil(log2(real(INPUT_SIZE))))) downto 0);
	subtype counter_type is  unsigned(integer(ceil(log2(real(NB_SAMPLES)))) downto 0);
	subtype x_type is std_logic_vector(NB_SAMPLES*INPUT_SIZE*NBITS-1 downto 0);
	type w_type is array(0 to OUTPUT_SIZE-1) of std_logic_vector(INPUT_SIZE*NBITS -1 downto 0);
	type b_type is array(0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS -1 downto 0);
	type y_vector is array(0 to OUTPUT_SIZE -1) of y_bits;
	subtype x_ppl_type is std_logic_vector(INPUT_SIZE*NBITS-1 downto 0);
	--subtype b_ppl_type is std_logic_vector(NBITS-1 downto 0);
	constant SAMPLE_CNT_ZERO : counter_type := (others => '0');
	constant X_ZERO : x_type := (others => '0');
	constant W_ZERO : w_type := (others => (others => '0'));
	constant B_ZERO : b_type := (others => (others => '0'));
	
	signal state_reg, state_next : state_type;
	signal sample_cnt_reg, sample_cnt_next, dec_sample_cnt: counter_type;
	signal sample_cnt_is_zero : std_logic;
	signal x_reg, x_next : x_type;
	signal w_reg, w_next : w_type;
	signal b_reg, b_next : b_type;	
	signal x_ppl : x_ppl_type;
	signal w_ppl:  w_type;
	signal b_ppl : b_type;
	signal y_out : y_vector;
begin
	
	REG: process(clk, rst)
	begin
		if rst = '1' then
			state_reg <= IDLE;
			sample_cnt_reg <= SAMPLE_CNT_ZERO;
			x_reg <= X_ZERO;
			w_reg <= W_ZERO;
			b_reg <= B_ZERO;
		elsif rising_edge(clk) then
			state_reg <= state_next;
			sample_cnt_reg <= sample_cnt_next;
			x_reg <= x_next;
			w_reg <= w_next;
			b_reg <= b_next;
		end if;
	end process REG;
	
 
	
	NSL: process(state_reg, start, sample_cnt_is_zero)
	begin
		state_next <= state_reg;
		case state_reg is
		when IDLE => if start = '1' then
						state_next <= LOAD;
					 end if;
		when LOAD => state_next <= CALC;
		when CALC => if sample_cnt_is_zero = '1' then
						state_next <= IDLE;
					 end if;
		end case;
	end process;
	
	
	DPU_RMUX: process(state_reg, x_reg, w_reg, b_reg, dec_sample_cnt, x, w, b, sample_cnt_reg)
	begin
		x_next <= x_reg;
		w_next <= w_reg;
		b_next <= b_reg;
		sample_cnt_next <= sample_cnt_reg;
		case state_reg is
		when IDLE => null;
		when LOAD => x_next <= x;
				     for i in 0 to OUTPUT_SIZE-1 loop
						w_next(i) <= w(INPUT_SIZE*NBITS*(i+1)-1 downto INPUT_SIZE*NBITS*(i));
						b_next(i) <= b(NBITS*(i+1)-1 downto NBITS*(i));
					 end loop;
					 sample_cnt_next <= to_unsigned(NB_SAMPLES, sample_cnt_next'length);
		when CALC => sample_cnt_next <= dec_sample_cnt;
		end case;
			
	end process DPU_RMUX;
	
	 OL: ready <= '1' when state_reg = IDLE else '0';
		
		
	 sample_cnt_is_zero <= '1' when dec_sample_cnt = SAMPLE_CNT_ZERO else '0';
	
	DPU_FCT: process(x_reg, w_reg, b_reg, sample_cnt_reg, sample_cnt_is_zero, state_reg)
	variable i : integer;
    begin	
		i := to_integer(sample_cnt_reg);
	    dec_sample_cnt <= sample_cnt_reg - 1;
	    x_ppl <= (others => ('0')); 
	    w_ppl <= (others => (others => '0'));
	    b_ppl <= (others => (others => '0'));			
		if sample_cnt_is_zero = '0'  and state_reg = CALC then
			for j in 1 to NB_SAMPLES loop
				if j = i then
					x_ppl <= x_reg(INPUT_SIZE*NBITS*(NB_SAMPLES - j+1)-1 downto INPUT_SIZE*NBITS*(NB_SAMPLES - j));
				end if;
			end loop;
			w_ppl <= w_reg;
			b_ppl <= b_reg;
		end if;
		
	end process DPU_FCT;
	GEN_LAYER: for i in 0 to OUTPUT_SIZE-1 generate
		FCUNIT: entity work.fcunit(ppl)
			generic map(NBITS => NBITS, INPUT_SIZE => INPUT_SIZE)
			port map (clk => clk, rst => rst,
					  x => x_ppl, w => w_ppl(i), b => b_ppl(i), y => y_out(i));
	end generate;		
	
	
	OUT_RES : process(y_out, sample_cnt_is_zero, state_reg)
	begin
		y <= (others => '0');
		for i in 1 to OUTPUT_SIZE loop
			if sample_cnt_is_zero = '0' and state_reg = CALC then
				y((2*NBITS+integer(ceil(log2(real(INPUT_SIZE))))+1)*(i)-1 downto (2*NBITS+integer(ceil(log2(real(INPUT_SIZE))))+1)*(i-1)) <= y_out(i-1);
			end if;
		end loop;
	end process OUT_RES;
	end architecture fsmd;	
		
		
		
		