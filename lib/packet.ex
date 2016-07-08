defmodule Mesquitte.Packet do
  defmacro __using__(_) do
    quote do
      alias Mesquitte.Packet.{
        FixedHeader,
        Connect,
        ConnectFlags,
        PublishFlags,
        ReservedFlags}
    end
  end

  @types [connect: 1, connack: 2, publish: 3, puback: 4, pubrec: 5,
          pubrel: 6, pubcomp: 7, subscribe: 8, suback: 9, unsubscribe: 10,
          unsuback: 11, pingreq: 12, pingresp: 13, disconnect: 14]

  def type_to_integer(name) when is_atom(name), do: lookup_type(name, 0)
  def type_to_atom(value) when is_integer(value), do: lookup_type(value, 1)

  defp lookup_type(input, position) do
    {name, value} = List.keyfind(@types, input, position)
    case position do
      0 -> {:ok, value}
      1 -> {:ok, name}
      _ -> {:error, :unknown_packet}
    end
  end

  def type_to_struct(name) when is_atom(name) do
    case name do
      :connect -> %Mesquitte.Packet.Connect{}
      _ -> {:error, :unknown_packet}
    end
  end
end
