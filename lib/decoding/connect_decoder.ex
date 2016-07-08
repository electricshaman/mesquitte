defimpl Mesquitte.PacketDecoder, for: Mesquitte.Packet.Connect do
  use Mesquitte.{Packet, ProtocolVersion}
  import Mesquitte.{Decoding, Conversions}

  def decode(%Connect{} = c, bin, %{version: _ver, rem_len: _rl, rem_len_size: _rl_size} = opts) do
    put_fixed_flags({c, bin, opts})
    |> put_rem_len
    |> put_proto_name
    |> put_proto_version
    |> put_connect_flags
    |> put_keep_alive
    |> put_client_id
    |> put_will_topic
    |> put_will_payload
    |> put_username
    |> put_password
  end

  def put_fixed_flags({%Connect{} = c, bin, opts}) do
    {flags, rest} = decode_fixed_flags(bin, opts.version)
    {put_in(c.fixed_header.flags, flags), rest, opts}
  end

  def put_proto_name({%Connect{} = c, bin, opts}) do
    {name, rest} = decode_utf8_string(bin)
    {put_in(c.proto_name, name), rest, opts}
  end

  def put_proto_version({%Connect{} = c, bin, %{version: ver} = opts}) do
    {^ver, rest} = decode_proto_version(bin)
    {put_in(c.proto_version, ver), rest, opts}
  end

  def put_connect_flags({%Connect{} = c, bin, opts}) do
    {flags, rest} = decode_connect_flags(bin, opts.version)
    {put_in(c.flags, flags), rest, opts}
  end

  def put_keep_alive({%Connect{} = c, bin, opts}) do
    {keep_alive, rest} = decode_keep_alive(bin, opts.version)
    {put_in(c.keep_alive, keep_alive), rest, opts}
  end

  def put_client_id({%Connect{} = c, bin, opts}) do
    {client_id, rest} = decode_utf8_string(bin)
    {put_in(c.client_id, client_id), rest, opts}
  end

  def put_will_topic({%Connect{} = c, bin, opts}) do
    {will_topic, rest} = decode_connect_flag_payload(c.flags.will, &decode_utf8_string/1, [bin])
    {put_in(c.will_topic, will_topic), rest, opts}
  end

  def put_will_payload({%Connect{} = c, bin, opts}) do
    # Will payload isn't restricted to string but decoding works the same since strings are binaries in the BEAM
    {will_payload, rest} = decode_connect_flag_payload(c.flags.will, &decode_utf8_string/1, [bin])
    {put_in(c.will_payload, will_payload), rest, opts}
  end

  def put_username({%Connect{} = c, bin, opts}) do
    {username, rest} = decode_connect_flag_payload(c.flags.username, &decode_utf8_string/1, [bin])
    {put_in(c.username, username), rest, opts}
  end

  def put_password({%Connect{} = c, bin, opts}) do
    {password, rest} = decode_connect_flag_payload(c.flags.password, &decode_utf8_string/1, [bin])
    {put_in(c.password, password), rest, opts}
  end

  defp decode_connect_flags(bin, _version) do
    <<username::1, password::1, will_retain::1, will_qos::2, will::1, clean_session::1, _reserved::1, rest::binary>> = bin
    flags = ConnectFlags.new(username, password, will_retain, will_qos, will, clean_session)
    {flags, rest}
  end

  defp decode_keep_alive(<<keep_alive::16, rest::binary>>, _version) do
    {keep_alive, rest}
  end

  defp decode_fixed_flags(<<_type::4, dup::1, qos::2, retain::1, rest::binary>>, @mqtt310) do
    {%PublishFlags{dup: to_bool(dup), qos: to_bool(qos), retain: to_bool(retain)}, rest}
  end

  defp decode_fixed_flags(<<_type::4, 0::4, rest::binary>>, version) when version >= @mqtt311,
    do: {ReservedFlags.new(false, false, false, false), rest}

  defp decode_fixed_flags(_bin, version) when version >= @mqtt311,
    do: {:error, :invalid_flags}

end
