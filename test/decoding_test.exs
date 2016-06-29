defmodule Mesquitte.DecodingTest do
  use ExUnit.Case, async: true
  import Mesquitte.Decoding

  test "decode variable integers" do
    input = [
      {0, <<0x00>>}, {1, <<0x01>>}, {127, <<0x7F>>},
      {128, <<0x80, 0x01>>}, {16_383, <<0xFF, 0x7F>>},
      {16_384, <<0x80, 0x80, 0x01>>}, {2_097_151, <<0xFF, 0xFF, 0x7F>>},
      {2_097_152, <<0x80, 0x80, 0x80, 0x01>>}, {268_435_455, <<0xFF, 0xFF, 0xFF, 0x7F>>}]

    for {result, bin} <- input,
      do: assert decode_var_int(bin) == {result, <<>>}
  end

end
