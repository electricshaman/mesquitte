defprotocol Mesquitte.PacketDecoder do
  def decode(output, input, opts)
end
