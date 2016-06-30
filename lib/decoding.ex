defmodule Mesquitte.Decoding do
  require Logger
  use Bitwise, only_operators: true
  import Mesquitte.Conversions
  alias Mesquitte.{Packet, FixedHeader}

  def decode_var_int(encoded, shift \\ 0, acc \\ 0)
  def decode_var_int(<<0::1, bits::7, rem::binary>>, shift, acc),
    do: {(bits <<< shift) + acc, rem}
  def decode_var_int(<<1::1, bits::7, rem::binary>>, shift, acc),
    do: decode_var_int(rem, shift + 7, (bits <<< shift) + acc)

  def split_packets(packets, acc \\ [])
  def split_packets(<<>>, acc), do: Enum.reverse(acc)
  def split_packets(<<type::4, dup::1, qos::2, retain::1, rest::binary>>, acc) do
    {rem_len, rest} = decode_var_int(rest)
    header = FixedHeader.new(type, dup, qos, retain, rem_len)
    packet = binary_part(rest, 0, rem_len)

    leftover_size = byte_size(rest) - rem_len
    leftover = binary_part(rest, rem_len, leftover_size)

    split_packets(leftover, [{header, packet}|acc])
  end


end
