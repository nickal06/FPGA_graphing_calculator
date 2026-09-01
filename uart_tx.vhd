library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        start    : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        tx       : out std_logic;
        busy     : out std_logic
    );
end uart_tx;

architecture Behavioral of uart_tx is

    constant CLK_FREQ    : integer := 125000000;
    constant BAUD_RATE   : integer := 115200;
    constant BAUD_TICKS  : integer := CLK_FREQ / BAUD_RATE; -- 1085

    signal baud_counter  : integer range 0 to BAUD_TICKS := 0;
    signal bit_counter   : integer range 0 to 10 := 0;

    signal shift_reg     : std_logic_vector(9 downto 0) := (others => '1');
    signal active        : std_logic := '0';

begin

    tx   <= shift_reg(0);
    busy <= active or start; -- Immediately signal busy upon start strobe

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                baud_counter <= 0;
                bit_counter  <= 0;
                shift_reg    <= (others => '1');
                active       <= '0';

            elsif active = '0' then

                if start = '1' then
                    -- Frame: Stop bit ('1') & Data (8 bits) & Start bit ('0')
                    shift_reg    <= '1' & data_in & '0';
                    baud_counter <= 0;
                    bit_counter  <= 0;
                    active       <= '1';
                else
                    shift_reg    <= (others => '1'); -- Hold idle HIGH
                end if;

            else

                if baud_counter = BAUD_TICKS - 1 then
                    baud_counter <= 0;

                    if bit_counter = 9 then
                        bit_counter <= 0;
                        active      <= '0';
                        shift_reg   <= (others => '1');
                    else
                        bit_counter <= bit_counter + 1;
                        shift_reg   <= '1' & shift_reg(9 downto 1);
                    end if;
                else
                    baud_counter <= baud_counter + 1;
                end if;

            end if;
        end if;
    end process;

end Behavioral;