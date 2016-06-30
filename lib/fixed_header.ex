defmodule Mesquitte.FixedHeader do
  import Mesquitte.Conversions

  defstruct type: nil,
            dup: nil,
            qos: nil,
            retain: nil,
            rem_len: 0

  @doc """
  Creates a new FixedHeader struct.
  """
  def new(type, dup, qos, retain, rem_len) do
    {:ok, type} = Mesquitte.Packet.lookup(type)
    %Mesquitte.FixedHeader{
      type: type,
      dup: to_bool(dup),
      qos: qos,
      retain: to_bool(retain),
      rem_len: rem_len}
  end
end
