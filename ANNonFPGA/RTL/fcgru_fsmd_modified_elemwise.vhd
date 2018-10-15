library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


-- 1 output GRU unit --> Must specify GRU layer output size for recurrent terms matrix size.
-- To be used in parallel with OUTPUT_SIZE-1 same GRU units.
-- Recurrence should be done by routing the output of this block to the S inputs of this block and all other parallel blocks
entity fcgru is
	generic(
			NBITS       : natural := 8;
			INPUT_SIZE  : natural := 4;
			OUTPUT_SIZE : natural := 16;
			INT_BITS    : natural := 3; --integer bits + sign bit
			NB_SAMPLES  : natural := 10

	);
	port(
		 clk, rst  : in std_logic;
		 start     : in std_logic;
		 ready     : out std_logic;
		 xn        : in std_logic_vector(NBITS*INPUT_SIZE-1 downto 0); -- receives only 1 sample at a time
		 sn        : out std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0); -- sends only 1 sample at a time
		 uz        : in std_logic_vector(NBITS*INPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 ur        : in std_logic_vector(NBITS*INPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 uh        : in std_logic_vector(NBITS*INPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 wz        : in std_logic_vector(NBITS*OUTPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 wr        : in std_logic_vector(NBITS*OUTPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 wh        : in std_logic_vector(NBITS*OUTPUT_SIZE*OUTPUT_SIZE-1 downto 0);
		 bz        : in std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 br        : in std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 bh        : in std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 finished_sample : out std_logic;

		 --debug signals
		 DEBUG_rn : out std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 DEBUG_hn : out std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 DEBUG_zn : out std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
		 DEBUG_rdir : out std_logic_vector((NBITS+integer(ceil(log2(real(INPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0);
		 DEBUG_hdir : out std_logic_vector((NBITS+integer(ceil(log2(real(INPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0);
		 DEBUG_zdir : out std_logic_vector((NBITS+integer(ceil(log2(real(INPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0);
		 DEBUG_rrec : out std_logic_vector((NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0);
		 DEBUG_hrec : out std_logic_vector((NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0);
		 DEBUG_zrec : out std_logic_vector((NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))*OUTPUT_SIZE-1 downto 0)

	);
	end entity fcgru;

architecture fsmd of fcgru is

	type biases is array (0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS-1 downto 0);
	type debug_rec is array (0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS + integer(ceil(log2(real(OUTPUT_SIZE))))-1 downto 0);
	type debug_dir is array (0 to OUTPUT_SIZE-1) of std_logic_vector(NBITS + integer(ceil(log2(real(INPUT_SIZE))))-1 downto 0);
	type rec_weights is array (0 to OUTPUT_SIZE-1) of std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	type dir_weights is array (0 to OUTPUT_SIZE-1) of std_logic_vector(INPUT_SIZE*NBITS-1 downto 0);
	type state_type is (IDLE, LOAD, CALC);
	subtype counter_type is  unsigned(integer(ceil(log2(real(NB_SAMPLES))))+1 downto 0);
	constant SAMPLE_CNT_ZERO : counter_type := (others => '0');

	signal state_reg, state_next : state_type;
	signal xn_reg, xn_next : std_logic_vector(INPUT_SIZE*NBITS-1 downto 0);
	signal wr_tab, wz_tab, wh_tab : rec_weights;
	signal ur_tab, uz_tab, uh_tab : dir_weights;
	signal br_tab, bz_tab, bh_tab : biases;
	signal sample_cnt_reg, sample_cnt_next, dec_sample_cnt : counter_type;
	signal sample_cnt_is_zero : std_logic;
	signal start_units : std_logic;
	signal units_ready : std_logic;
	signal rn : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal sn_1_reg, sn_1_next, sn_1_temp : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	-- new internal signals for element wise unit (updated to top level component)
	signal ready_elemwise, elemwise_ready : std_logic;
	signal elemwise_start : std_logic;
	signal start_elemwise : std_logic_vector(OUTPUT_SIZE-1 downto 0);
	signal elemwise_out, elemwise_prod: std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);

	-- debug signals
	signal DEBUG_rn_reg : biases;
	signal DEBUG_hn_reg : biases;
	signal DEBUG_zn_reg : biases;
	signal DEBUG_rn_dir_out : debug_dir;
	signal DEBUG_hn_dir_out : debug_dir;
	signal DEBUG_zn_dir_out : debug_dir;
	signal DEBUG_rn_rec_out : debug_rec;
	signal DEBUG_hn_rec_out : debug_rec;
	signal DEBUG_zn_rec_out : debug_rec;
begin

 DEBUG: process(DEBUG_rn_reg, DEBUG_hn_reg, DEBUG_zn_reg, DEBUG_rn_dir_out, DEBUG_hn_dir_out, DEBUG_zn_dir_out, DEBUG_rn_rec_out, DEBUG_hn_rec_out, DEBUG_zn_rec_out)
 begin
	 for i in 0 to OUTPUT_SIZE-1 loop
		DEBUG_rn((i+1)*NBITS-1 downto i*NBITS) <= DEBUG_rn_reg(i);
		DEBUG_hn((i+1)*NBITS-1 downto i*NBITS) <= DEBUG_hn_reg(i);
		DEBUG_zn((i+1)*NBITS-1 downto i*NBITS) <= DEBUG_zn_reg(i);
		DEBUG_rdir((i+1)*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))) <= DEBUG_rn_dir_out(i);
		DEBUG_hdir((i+1)*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))) <= DEBUG_hn_dir_out(i);
		DEBUG_zdir((i+1)*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(INPUT_SIZE)))))) <= DEBUG_zn_dir_out(i);
		DEBUG_rrec((i+1)*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))) <= DEBUG_rn_rec_out(i);
		DEBUG_hrec((i+1)*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))) <= DEBUG_hn_rec_out(i);
		DEBUG_zrec((i+1)*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))-1 downto i*(NBITS+integer(ceil(log2(real(OUTPUT_SIZE)))))) <= DEBUG_zn_rec_out(i);
	end loop;
 end process;

	REG: process(clk, rst)
		begin
			if rst = '1' then
				state_reg <= IDLE;
				sample_cnt_reg <= SAMPLE_CNT_ZERO;
				xn_reg <= (others => '0');
				sn_1_reg <= (others => '0');
			elsif rising_edge(clk) then
				state_reg <= state_next;
				sample_cnt_reg <= sample_cnt_next;
				xn_reg <= xn_next;
				sn_1_reg <= sn_1_next;
			end if;
		end process REG;



		NSL: process(state_reg, start, sample_cnt_is_zero, units_ready)
		begin
			state_next <= state_reg;

			case state_reg is
			when IDLE => if start = '1' then
							state_next <= LOAD;
						 end if;
			when LOAD =>  state_next <= CALC;

			when CALC => if units_ready = '1' then
							if sample_cnt_is_zero = '1' then
								state_next <= IDLE;
							else
								state_next <= LOAD;
							end if;
						 end if;
			end case;
	end process;

	GEN_LAYER: for i in 0 to OUTPUT_SIZE-1 generate
		GRU_UNIT: entity work.gru(fsmd)
			generic map(NBITS => NBITS,
						INPUT_SIZE => INPUT_SIZE,
						OUTPUT_SIZE => OUTPUT_SIZE,
						INT_BITS => INT_BITS)
			port map (
				clk => clk,
				rst => rst,
				start => start_units,
				ready => units_ready,
				xn => xn_reg,
				sn_1 => sn_1_reg,
				--rn => rn,
				elemwise_prod => elemwise_out,
				elemwise_ready => ready_elemwise,
				elemwise_start => start_elemwise(i),
				uz => uz_tab(i),
				ur => ur_tab(i),
				uh => uh_tab(i),
				wz => wz_tab(i),
				wr => wr_tab(i),
				wh => wh_tab(i),
				bz => bz_tab(i),
				br => br_tab(i),
				bh => bh_tab(i),
				snj => sn_1_temp(NBITS*(i+1)-1 downto NBITS*i),
				rnj => rn(NBITS*(i+1)-1 downto NBITS*i),
				DEBUG_rnj_reg => DEBUG_rn_reg(i),
				DEBUG_rnj_dir_out => DEBUG_rn_dir_out(i),
				DEBUG_rnj_rec_out => DEBUG_rn_rec_out(i),
				DEBUG_znj_reg => DEBUG_zn_reg(i),
				DEBUG_znj_dir_out => DEBUG_zn_dir_out(i),
				DEBUG_znj_rec_out => DEBUG_zn_rec_out(i),
				DEBUG_hnj_reg => DEBUG_hn_reg(i),
				DEBUG_hnj_dir_out => DEBUG_hn_dir_out(i),
				DEBUG_hnj_rec_out => DEBUG_hn_rec_out(i)
			);
	end generate GEN_LAYER;

	ELEMWISE_UNIT: entity work.elemwise_prod(fsmd)
		generic map(
			NBITS => NBITS,
			NBELMTS => OUTPUT_SIZE,
			REG_DELAY => 0,
			INT_BITS => INT_BITS
		)
		port map(
			start => start_elemwise(0),
			clk   => clk,
			rst   => rst,
			a_in  => rn,
			b_in  => sn_1_reg,
			ready => ready_elemwise,
			z_out => elemwise_out
		);
	OL:


	 sample_cnt_is_zero <= '1' when dec_sample_cnt = SAMPLE_CNT_ZERO else '0';
	-- (DPU) routing mux
	DPU_RMUX: process(state_reg, dec_sample_cnt, sample_cnt_reg, wr, xn_reg, xn, br, uh, ur, uz, wh, wz, sn_1_temp, sn_1_reg, units_ready, bh, bz)
	begin
		xn_next <= xn_reg;
		sn_1_next <= sn_1_reg;
		for j in 0 to OUTPUT_SIZE-1 loop
			for i in 0 to INPUT_SIZE-1 loop
				ur_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= ur(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
				uz_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= uz(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
				uh_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= uh(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
			end loop;
		end loop;
		for j in 0 to OUTPUT_SIZE-1 loop
			br_tab(j) <= br(NBITS*(j+1)-1 downto NBITS*j);
			bz_tab(j) <= bz(NBITS*(j+1)-1 downto NBITS*j);
			bh_tab(j) <= bh(NBITS*(j+1)-1 downto NBITS*j);
			for i in 0 to OUTPUT_SIZE-1 loop
				wr_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= wr(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
				wz_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= wz(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
				wh_tab(j)(NBITS*(i+1)-1 downto NBITS*i) <= wh(OUTPUT_SIZE*NBITS*i+(j+1)*NBITS-1 downto OUTPUT_SIZE*NBITS*i+NBITS*j);
			end loop;
		end loop;
		start_units <= '0';
		sample_cnt_next <= sample_cnt_reg;
		finished_sample <= '0';
		case state_reg is
		when IDLE => sample_cnt_next <= to_unsigned(NB_SAMPLES, sample_cnt_next'length);
		when LOAD => xn_next <= xn;
					 start_units <= '1';
					 sample_cnt_next <= dec_sample_cnt;
		when CALC => if units_ready = '1' then
					 	finished_sample <= '1';
					 end if;
					 sn_1_next <= sn_1_temp;
		end case;
	end process DPU_RMUX;

	dec_sample_cnt <= sample_cnt_reg - 1;

	-- out_logic
	ready <= '1' when state_reg = IDLE else '0';
	sn <= sn_1_temp;

end architecture fsmd;
