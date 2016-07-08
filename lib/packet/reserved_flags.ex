defmodule Mesquitte.Packet.ReservedFlags do
  defstruct flag1: 0, flag2: 0, flag3: 0, flag4: 0

  def new(flag1, flag2, flag3, flag4) do
    %Mesquitte.Packet.ReservedFlags{flag1: flag1, flag2: flag2, flag3: flag3, flag4: flag4}
  end
end
