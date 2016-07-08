defmodule Mesquitte.DecodingTest do
  use ExUnit.Case, async: true
  import Mesquitte.Decoding

  test "decode variable integers" do
    input = [
      {0, 1, <<0x00>>}, {1, 1, <<0x01>>}, {127, 1, <<0x7F>>},
      {128, 2, <<0x80, 0x01>>}, {16_383, 2, <<0xFF, 0x7F>>},
      {16_384, 3, <<0x80, 0x80, 0x01>>}, {2_097_151, 3, <<0xFF, 0xFF, 0x7F>>},
      {2_097_152, 4, <<0x80, 0x80, 0x80, 0x01>>}, {268_435_455, 4, <<0xFF, 0xFF, 0xFF, 0x7F>>}]

    for {result, size, bin} <- input,
      do: assert decode_var_int(bin) == {result, size, <<>>}
  end

end
