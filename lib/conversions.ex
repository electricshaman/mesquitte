defmodule Mesquitte.Conversions do
  def to_int(true), do: 1
  def to_int(false), do: 0
  def to_int(value) when is_integer(value),
    do: value

  def to_bool(1), do: true
  def to_bool(0), do: false
  def to_bool(value) when is_boolean(value),
    do: value
end
