defmodule Mesquitte.Decoding do
  require Logger
  use Bitwise, only_operators: true
  use Mesquitte.{Packet, ProtocolVersion}

  def split_packets(bin, acc \\ [])
  def split_packets(<<>>, acc), do: Enum.reverse(acc)
  def split_packets(<<type::4, _flags::4, rest::binary>> = bin, acc) do
    {:ok, packet_type} = Mesquitte.Packet.type_to_atom(type)

    {rem_len, rem_len_size, _rest} = decode_var_int(rest)
    packet_size = 1 + rem_len_size + rem_len # fixed header + remaining (variable header + payload)
    <<packet::size(packet_size)-binary, leftover::binary>> = bin

    # Include remaining length and size so it can be easily parsed/skipped downstream
    opts = %{rem_len: rem_len, rem_len_size: rem_len_size}
    split_packets(leftover, [{packet_type, packet, opts}|acc])
  end

  def decode_var_int(encoded, shift \\ 0, acc \\ 0, size \\ 0)
  def decode_var_int(<<0::1, bits::7, rest::binary>>, shift, acc, size),
    do: {(bits <<< shift) + acc, size + 1, rest}
  def decode_var_int(<<1::1, bits::7, rest::binary>>, shift, acc, size),
    do: decode_var_int(rest, shift + 7, (bits <<< shift) + acc, size + 1)

  def decode_connect_flag_payload(false, _fun, args), do: {<<>>, hd(args)}
  def decode_connect_flag_payload(true, fun, args), do: apply(fun, args)

  def decode_utf8_string(<<len::16, string::size(len)-binary, rest::binary>>) do
    {string, rest}
  end

  def decode_proto_version({:connect, bin, %{rem_len_size: rl_size}}) do
    header_size = 1 + rl_size
    <<_header::size(header_size)-binary, rest::binary>> = bin
    {_proto_name, rest} = decode_utf8_string(rest)
    {version, _} = decode_proto_version(rest)
    {:ok, version}
  end

  def decode_proto_version(<<version, rest::binary>>) do
    case version do
      v when v in @supported_mqtt_versions -> {v, rest}
      _ -> {:error, :unsupported_mqtt_version}
    end
  end

  def put_rem_len({packet, bin, opts}) do
    %{rem_len: rl, rem_len_size: rl_size} = opts
    <<_rem_len::size(rl_size)-binary, rest::binary>> = bin
    {put_in(packet.fixed_header.rem_len, rl), rest, opts}
  end
end
