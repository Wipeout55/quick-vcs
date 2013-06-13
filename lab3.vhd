library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
    port (
        i_clock    : in std_logic;                     -- the system clock
        i_valid    : in std_logic;                     -- if data is available 
        i_input    : in std_logic_vector(7 downto 0);  -- input data
        i_reset    : in std_logic;                     -- reset
        o_output   : out std_logic_vector(7 downto 0)  -- output data
    );
end entity lab3;

architecture main of lab3 is
    signal count     : std_logic_vector(7 downto 0) := "00000000";
    
    signal add_ct    : std_logic_vector(3 downto 0) := "0000";

    signal wren_1    : std_logic := '1';
    signal wren_2    : std_logic := '0';
    signal wren_3    : std_logic := '0';

    signal out_1     : std_logic_vector(7 downto 0) := "00000000";
    signal out_2     : std_logic_vector(7 downto 0) := "00000000";
    signal out_3     : std_logic_vector(7 downto 0) := "00000000";

    signal state     : std_logic_vector(4 downto 0) := "00001";
    
    signal s_compute : std_logic_vector(8 downto 0) := "000000000";
begin

mem1 : entity work.mem(main)
    port map (
        address => add_ct,
        clock   => i_clock,
        data    => i_input,
        wren    => wren_1,
        q       => out_1
    );

mem2 : entity work.mem(main)
    port map (
        address => add_ct,
        clock   => i_clock,
        data    => i_input,
        wren    => wren_2,
        q       => out_2
    );

mem3 : entity work.mem(main)
    port map (
        address => add_ct,
        clock   => i_clock,
        data    => i_input,
        wren    => wren_3,
        q       => out_3
    );

fsm : process
begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
        state <= "00001";
    else
        if add_ct = "1111" and i_valid = '1' then
            if state = "10000" then
                state <= "00100";
            else
                state <= std_logic_vector(unsigned(state) rol 1);
            end if;
        end if;
    end if;
end process;

block_inc : process
begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
        add_ct <= "0000";
    else
    	if i_valid = '1' then
    	    if add_ct = "1111" then
    		    add_ct <= "0000";
    		else
    		    add_ct <= std_logic_vector(unsigned(add_ct)+1);
    		end if;
        end if;
    end if;
end process;

write_en : process
begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
        wren_1 <= '1';
    	wren_2 <= '0';
    	wren_3 <= '0';
    else
    	if add_ct = "1111" and i_valid = '1' then
        	if wren_3 = '1' then
        	    wren_1 <= '1';
        	    wren_2 <= '0';
        	    wren_3 <= '0';
        	elsif wren_1 = '1' then
        	    wren_1 <= '0';
        	    wren_2 <= '1';
        	    wren_3 <= '0';
        	elsif wren_2 = '1' then
        	    wren_1 <= '0';
        	    wren_2 <= '0';
        	    wren_3 <= '1';
        	end if;
        end if;
    end if;
end process;

detect : process
begin
    wait until rising_edge(i_clock);
    if (i_reset = '1') then
        count <= "00000000";
    else
        if i_valid = '1' then
            if state = "00100" then
                s_compute <= std_logic_vector(signed("000000000" + unsigned(out_1) - unsigned(out_2) + unsigned(i_input)));
                if (s_compute and "100000000") = "000000000" then
                    count <= std_logic_vector(unsigned(count)+1);
                end if;
            elsif state = "01000" then
                s_compute <= std_logic_vector(signed("000000000" + unsigned(out_2) - unsigned(out_3) + unsigned(i_input)));
                if (s_compute and "100000000") = "000000000" then
                    count <= std_logic_vector(unsigned(count)+1);
                end if;
            elsif state = "10000" then
                s_compute <= std_logic_vector(signed("000000000" + unsigned(out_3) - unsigned(out_1) + unsigned(i_input)));
                if (s_compute and "100000000") = "000000000" then
                    count <= std_logic_vector(unsigned(count)+1);
                end if;
            end if;
        end if;
    end if;
end process;

outp : process
begin
    wait until rising_edge(i_clock);
    o_output <= count;
end process;

end architecture main;

-- Q1: number of flip flops and lookup tables?
--

-- Q2: maximum clock frequency?
--

-- Q3: source and destination signals of critical path?
-- 

