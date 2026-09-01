library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================================
-- TOP-LEVEL MODULE: main
-- =========================================================
entity main is
    port (
        clk         : in  std_logic;
        sw          : in  std_logic_vector(3 downto 0);
        btn_rect    : in  std_logic;
        btn_polar   : in  std_logic;
        led         : out std_logic_vector(3 downto 0);
        uart_tx_out : out std_logic
    );
end main;

architecture Behavioral of main is

    -- FSM Signals
    signal packet     : std_logic_vector(15 downto 0);
    signal done       : std_logic;
    signal fsm_status : std_logic_vector(3 downto 0);

    -- UART Driver Signals
    signal uart_start   : std_logic := '0';
    signal uart_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_busy    : std_logic;

    -- Serializer State Machine
    type tx_state_type is (IDLE, SEND_BYTE1, WAIT_BUSY1, WAIT_FREE1, DELAY_GAP, SEND_BYTE2, WAIT_BUSY2, WAIT_FREE2);
    signal tx_state   : tx_state_type := IDLE;
    signal packet_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal gap_timer  : integer range 0 to 2000 := 0;

begin

    -- 1. Calculator FSM Instance
    FSM_INST: entity work.calculator_fsm
        port map (
            clk        => clk,
            reset      => '0',
            sw         => sw,
            btn_rect   => btn_rect,
            btn_polar  => btn_polar,
            packet     => packet,
            fsm_status => fsm_status,
            done       => done
        );

    -- 2. UART Transmitter Instance
    UART_INST: entity work.uart_tx
        port map (
            clk     => clk,
            reset   => '0',
            start   => uart_start,
            data_in => uart_data_in,
            tx      => uart_tx_out,
            busy    => uart_busy
        );

    -- 3. Reliable 2-Byte Sequence Serializer
    process(clk)
    begin
        if rising_edge(clk) then
            uart_start <= '0';

            case tx_state is

                when IDLE =>
                    if done = '1' then
                        packet_reg <= packet;
                        tx_state   <= SEND_BYTE1;
                    end if;

                -- Byte 1: High Byte (Bits 15 downto 8)
                when SEND_BYTE1 =>
                    uart_data_in <= packet_reg(15 downto 8);
                    uart_start   <= '1';
                    tx_state     <= WAIT_BUSY1;

                when WAIT_BUSY1 =>
                    if uart_busy = '1' then
                        tx_state <= WAIT_FREE1;
                    end if;

                when WAIT_FREE1 =>
                    if uart_busy = '0' then
                        gap_timer <= 0;
                        tx_state  <= DELAY_GAP;
                    end if;

                -- Short inter-byte delay (1000 clock cycles = 8 us)
                when DELAY_GAP =>
                    if gap_timer = 1000 then
                        tx_state <= SEND_BYTE2;
                    else
                        gap_timer <= gap_timer + 1;
                    end if;

                -- Byte 2: Low Byte (Bits 7 downto 0)
                when SEND_BYTE2 =>
                    uart_data_in <= packet_reg(7 downto 0);
                    uart_start   <= '1';
                    tx_state     <= WAIT_BUSY2;

                when WAIT_BUSY2 =>
                    if uart_busy = '1' then
                        tx_state <= WAIT_FREE2;
                    end if;

                when WAIT_FREE2 =>
                    if uart_busy = '0' then
                        tx_state <= IDLE;
                    end if;

                when others =>
                    tx_state <= IDLE;

            end case;
        end if;
    end process;

    -- Display FSM stage / captured values on LEDs
    led <= fsm_status;

end Behavioral;