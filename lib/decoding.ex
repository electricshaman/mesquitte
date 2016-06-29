defmodule Mesquitte.Decoding do
  use Bitwise, only_operators: true

  def decode_var_int(encoded, shift \\ 0, acc \\ 0)
  def decode_var_int(<<0::1, bits::7, rem::binary>>, shift, acc),
    do: {(bits <<< shift) + acc, rem}
  def decode_var_int(<<1::1, bits::7, rem::binary>>, shift, acc),
    do: decode_var_int(rem, shift + 7, (bits <<< shift) + acc)




end
