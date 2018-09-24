library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity gru_fsmd_tb is
	end entity gru_fsmd_tb;
	
architecture bench of gru_fsmd_tb is
	
	file file_INPUTS: text;
	file file_OUTPUTS: text;
	constant INT_BITS : natural := 3;
	constant NBITS : natural := 16;
	constant OUTPUT_SIZE: natural := 1;
	constant INPUT_SIZE: natural := 8;
	constant NB_SAMPLES: natural := 10;
	constant CLK_PER: time := 10*ns;
	signal clk_tb : std_logic := '0';
	signal rst_tb  : std_logic;
	signal start_tb     : std_logic;
	signal ready_tb     : std_logic;
	signal xn_tb        : std_logic_vector(NB_SAMPLES*NBITS*INPUT_SIZE-1 downto 0);
	--signal sn_1_tb      : std_logic_vector(NB_SAMPLES*NBITS*OUTPUT_SIZE-1 downto 0);
	--signal rn_tb        : std_logic_vector(NB_SAMPLES*NBITS*OUTPUT_SIZE-1 downto 0);
	signal uz_tb        :  std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal ur_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal uh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal wz_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal wr_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal wh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal bz_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal br_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal bh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	
	signal test         : std_logic_vector(NBITS-1 downto 0);
	signal stop 		: boolean := false;
	-- signals for 1 SAMPLE
	signal xn_duv        : std_logic_vector(NBITS*INPUT_SIZE-1 downto 0);
	signal sn_1_duv      : std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
	signal rn_duv        : std_logic_vector(NBITS*OUTPUT_SIZE-1 downto 0);
	signal uz_duv        :  std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal ur_duv        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal uh_duv        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
	signal wz_duv        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal wr_duv        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal wh_duv        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
	signal bz_duv        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal br_duv        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal bh_duv        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
	signal snj_duv       : std_logic_vector(NBITS-1 downto 0);
	signal rnj_duv       : std_logic_vector(NBITS-1 downto 0);
begin 
	process
		variable v_ILINE: line;
		variable v_OLINE: line;
		variable v_SPACE: character;
		variable v_IN_TYPE: string(1 to 7);
	
		variable v_xn_tb        : std_logic_vector(NB_SAMPLES*NBITS*INPUT_SIZE-1 downto 0);
		--variable v_sn_1_tb      : std_logic_vector(NB_SAMPLES*NBITS*OUTPUT_SIZE-1 downto 0);
		--variable v_rn_tb        : std_logic_vector(NB_SAMPLES*NBITS*OUTPUT_SIZE-1 downto 0);
		variable v_uz_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
		variable v_ur_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
		variable v_uh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*INPUT_SIZE-1 downto 0);
		variable v_wz_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
		variable v_wr_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
		variable v_wh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS*OUTPUT_SIZE-1 downto 0);
		variable v_bz_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
		variable v_br_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
		variable v_bh_tb        : std_logic_vector(OUTPUT_SIZE*NBITS-1 downto 0);
		variable v_test           : std_logic_vector(NBITS-1 downto 0);
	begin
		
		
		file_open(file_INPUTS, "/home/edabd54/HSM/vhdl_asic/HDL/ANNonFPGA/TBENCH/data_in.txt", read_mode);
		file_open(file_OUTPUTS, "/home/edabd54/HSM/vhdl_asic/HDL/ANNonFPGA/TBENCH/data_out.txt", write_mode);
		
		while not endfile(file_INPUTS) loop
		
		readline(file_INPUTS, v_ILINE);
	    read(v_ILINE, v_IN_TYPE);
	    
			case v_IN_TYPE is
			when "inputs " => for j in 0 to NB_SAMPLES-1 loop
								report "passed in inputs j = " & integer'image(j);
								readline(file_INPUTS, v_ILINE);
							   	for i in 0 to INPUT_SIZE-1 loop
							   		--read(v_ILINE, v_test);
							  		read(v_ILINE, v_xn_tb(NBITS*(i+1+INPUT_SIZE*j)-1 downto NBITS*(i+INPUT_SIZE*j)));
							  		read(v_ILINE, v_SPACE);
							  	end loop;
							  end loop;
			when "outputs" => for i in 0 to NB_SAMPLES-1 loop
								report "passed in outputs i =" & integer'image(i);
								readline(file_INPUTS, v_ILINE);
								read(v_ILINE, v_SPACE);
								end loop;
			when "uz     " => for j in 0 to INPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_uz_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "ur     " => for j in 0 to INPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_ur_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "uh     " => for j in 0 to INPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_uh_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "wz     " => for j in 0 to OUTPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_wz_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "wr     " => for j in 0 to OUTPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_wr_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "wh     " => for j in 0 to OUTPUT_SIZE-1 loop
								readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_wh_tb(NBITS*(i+1+OUTPUT_SIZE*j)-1 downto NBITS*(i+OUTPUT_SIZE*j)));
									read(v_ILINE, v_SPACE);
								end loop;
							end loop;
			when "bz     " => readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_bz_tb(NBITS*(i+1)-1 downto NBITS*i));
									read(v_ILINE, v_SPACE);
								end loop;
							
			when "br     " => readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_br_tb(NBITS*(i+1)-1 downto NBITS*i));
									read(v_ILINE, v_SPACE);
							  end loop;
			when "bh     " => readline(file_INPUTS, v_ILINE);
								for i in 0 to OUTPUT_SIZE-1 loop
									read(v_ILINE, v_bh_tb(NBITS*(i+1)-1 downto NBITS*i));
									read(v_ILINE, v_SPACE);
								end loop;
		
		when "*      " => exit;
 		when others    => readline(file_INPUTS, v_ILINE);
							  read(v_ILINE, v_IN_TYPE);	
							  report "passed in ""other""";			 	
				end case;
			
			--if v_IN_TYPE = "inputs " then
			--	write(v_OLINE,  string'("hello from testbench"));
			--	writeline(file_OUTPUTS, v_OLINE);
			
		end loop;
		
		file_close(file_INPUTS);
		file_close(file_OUTPUTS);
		
		xn_tb <= v_xn_tb;
		--sn_1_tb <= v_sn_1_tb;
		uz_tb <= v_uz_tb;
		ur_tb <= v_ur_tb;
		uh_tb <= v_uh_tb;
		wz_tb <= v_wz_tb;
		wr_tb <= v_wr_tb;
		wh_tb <= v_wh_tb;
		br_tb <= v_br_tb;
		bz_tb <= v_bz_tb;
		bh_tb <= v_bh_tb;
		test <= v_test;
		wait;
	end process;
		 
		clk_tb <= not clk_tb after CLK_PER/2 when not stop;
		rst_tb <= '0', '1' after CLK_PER*1/4, '0' after CLK_PER*3/4;
		xn_duv <= xn_tb(INPUT_SIZE*NBITS-1 downto 0);
		uz_duv <= uz_tb;
		ur_duv <= ur_tb;
		uh_duv <= uh_tb;
		wz_duv <= wz_tb;
		wr_duv <= wr_tb;
		wh_duv <= wh_tb;
		br_duv <= br_tb;
		bz_duv <= bz_tb;
		bh_duv <= bh_tb;
		
		DUV: entity work.gru
			generic map(
				NBITS       => NBITS,
				INPUT_SIZE  => INPUT_SIZE,
				OUTPUT_SIZE => OUTPUT_SIZE,
				INT_BITS    => INT_BITS
			)
			port map(
				clk   => clk_tb,
				rst   => rst_tb,
				start => start_tb,
				ready => ready_tb,
				xn    => xn_duv,
				sn_1  => sn_1_duv,
				rn    => rn_duv,
				uz    => uz_duv,
				ur    => ur_duv,
				uh    => uh_duv,
				wz    => wz_duv,
				wr    => wr_duv,
				wh    => wh_duv,
				bz    => bz_duv,
				br    => br_duv,
				bh    => bh_duv,
				snj   => snj_duv,
				rnj   => rnj_duv
			);
		sn_1_duv <= (others => '0');
		rn_duv <= rnj_duv;
		process
		begin
			start_tb <= '0';
			wait for 2*CLK_PER;
			start_tb <= '1';
			wait until falling_edge(clk_tb);
			start_tb <= '0';
			wait for 1000*CLK_PER;
			stop <= true;
			wait;
			end process;
end architecture bench;