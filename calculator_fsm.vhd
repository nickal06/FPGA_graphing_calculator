library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator_fsm is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;

        sw         : in  std_logic_vector(3 downto 0);

        btn_rect   : in  std_logic;
        btn_polar  : in  std_logic;

        packet     : out std_logic_vector(15 downto 0);
        fsm_status : out std_logic_vector(3 downto 0);
        done       : out std_logic
    );
end calculator_fsm;

architecture Behavioral of calculator_fsm is

    type state_type is (
        IDLE,
        WAIT_REL_MODE,
        CAPTURE_A,
        WAIT_REL_A,
        CAPTURE_B,
        WAIT_REL_B,
        CAPTURE_C,
        WAIT_REL_C,
        FINISHED
    );

    signal state : state_type := IDLE;

    signal A_reg : std_logic_vector(3 downto 0) := "0000";
    signal B_reg : std_logic_vector(3 downto 0) := "0000";
    signal C_reg : std_logic_vector(3 downto 0) := "0000";

    signal coordinate_mode : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                state           <= IDLE;
                A_reg           <= "0000";
                B_reg           <= "0000";
                C_reg           <= "0000";
                coordinate_mode <= '0';
            else

                case state is

                    -- Step 1: Wait for mode select press
                    when IDLE =>
                        if btn_rect = '1' then
                            coordinate_mode <= '0';
                            state           <= WAIT_REL_MODE;
                        elsif btn_polar = '1' then
                            coordinate_mode <= '1';
                            state           <= WAIT_REL_MODE;
                        end if;

                    -- Wait until user releases mode button
                    when WAIT_REL_MODE =>
                        if btn_rect = '0' and btn_polar = '0' then
                            state <= CAPTURE_A;
                        end if;

                    -- Step 2: Capture A
                    when CAPTURE_A =>
                        if (coordinate_mode = '0' and btn_rect = '1') or 
                           (coordinate_mode = '1' and btn_polar = '1') then
                            A_reg <= sw;
                            state <= WAIT_REL_A;
                        end if;

                    when WAIT_REL_A =>
                        if btn_rect = '0' and btn_polar = '0' then
                            state <= CAPTURE_B;
                        end if;

                    -- Step 3: Capture B
                    when CAPTURE_B =>
                        if (coordinate_mode = '0' and btn_rect = '1') or 
                           (coordinate_mode = '1' and btn_polar = '1') then
                            B_reg <= sw;
                            state <= WAIT_REL_B;
                        end if;

                    when WAIT_REL_B =>
                        if btn_rect = '0' and btn_polar = '0' then
                            state <= CAPTURE_C;
                        end if;

                    -- Step 4: Capture C
                    when CAPTURE_C =>
                        if (coordinate_mode = '0' and btn_rect = '1') or 
                           (coordinate_mode = '1' and btn_polar = '1') then
                            C_reg <= sw;
                            state <= WAIT_REL_C;
                        end if;

                    -- Wait for release of final button press before pulsing done
                    when WAIT_REL_C =>
                        if btn_rect = '0' and btn_polar = '0' then
                            state <= FINISHED;
                        end if;

                    -- Single-cycle DONE trigger
                    when FINISHED =>
                        state <= IDLE;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    -- Form the 16-bit packet: [000][Mode][A (4-bit)][B (4-bit)][C (4-bit)]
    packet <= "000" & coordinate_mode & A_reg & B_reg & C_reg;
    done   <= '1' when state = FINISHED else '0';

    -- LED feedback: displays active stage/captured register
    with state select
        fsm_status <= "0001" when IDLE | WAIT_REL_MODE,
                      A_reg  when CAPTURE_A | WAIT_REL_A,
                      B_reg  when CAPTURE_B | WAIT_REL_B,
                      C_reg  when others;

end Behavioral;