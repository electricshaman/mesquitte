defmodule Mesquitte.Packet do
  defmacro __using__(_) do
    quote do
    end
  end

  @types [connect: 1, connack: 2, publish: 3, puback: 4, pubrec: 5,
          pubrel: 6, pubcomp: 7, subscribe: 8, suback: 9, unsubscribe: 10,
          unsuback: 11, pingreq: 12, pingresp: 13, disconnect: 14]

  def lookup(name) when is_atom(name), do: lookup(name, 0)
  def lookup(value) when is_integer(value), do: lookup(value, 1)
  def lookup(_other), do: result(nil, nil)

  defp lookup(input, position) do
    List.keyfind(@types, input, position) |> result(position)
  end

  defp result({_name, value}, 0), do: {:ok, value}
  defp result({name, _value}, 1), do: {:ok, name}
  defp result(nil, _position), do: {:error, :unknown_packet}
end
