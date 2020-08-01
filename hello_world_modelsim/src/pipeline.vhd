---------------------------------------------------------------------
-- pipeline.vhd
-- vhdl pipeline module
-- Willster419
-- 2020-07-31
-- A pipeline module for adding delay to a sample design
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
  generic (
    PIPELINE_LENGTH    : positive
  );
  port (
    clk                : in  std_logic;
    rst                : in  std_logic;
    input_data              : in  std_logic_vector;
    input_valid        : in  std_logic;
    output_data             : out std_logic_vector;
    output_valid       : out std_logic
  );
end entity pipeline;

architecture rtl of pipeline is
  type pipeline_type is record
    valid : std_logic;
    data  : std_logic_vector(input_data'range);
  end record pipeline_type;

  constant PIPELINE_ZERO : pipeline_type := (
    valid => '0',
    data  => (others => '0')
  );

  type pipeline_vector is array (0 to PIPELINE_LENGTH-1) of pipeline_type;

  signal pipeline        : pipeline_vector;

  alias pipeline_out     : pipeline_type is pipeline(0);
  alias pipeline_in      : pipeline_type is pipeline(PIPELINE_LENGTH-1);
begin

  main_proc: process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        pipeline_reset_loop : for i in 0 to PIPELINE_LENGTH-1 loop
          pipeline(i) <= PIPELINE_ZERO;
        end loop pipeline_reset_loop;
        output_data       <= (output_data'range => '0');
        output_valid <= '0';
      else
        -- pipeline input_data
        pipeline_in.data  <= input_data when (input_valid = '1') else (others => '0');
        pipeline_in.valid <= '1' when (input_valid = '1') else '0';

        -- pipeline shifting
        -- if PIPELINE_LENGTH = 3, then indexs 2,1,0.
        -- then we want two loops: 2 -> 1, and 1 -> 0
        pipeline_shift_loop : for i in PIPELINE_LENGTH-1 downto 1 loop
          pipeline(i-1) <= pipeline(i);
        end loop pipeline_shift_loop;

        -- pipeline output_data
        output_data       <= pipeline_out.data;
        output_valid <= pipeline_out.valid;
      end if;
    end if;
  end process main_proc;

  -- assert that the length is at least 2
  assert (PIPELINE_LENGTH > 1) report "Pipeline length must be at least 2" severity failure;

  -- assert that the input_data and output_data lengths are equal
  assert (input_data'length = output_data'length) report "Input and Output port must be same length" severity failure;

end architecture rtl;
