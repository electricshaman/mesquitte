defmodule Mesquitte.Packet.FixedHeader do
  defstruct type: nil,
            flags: nil,
            rem_len: 0
end
