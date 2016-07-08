defmodule Mesquitte.Packet.Connect do
  defstruct fixed_header: %Mesquitte.Packet.FixedHeader{type: :connect},
            proto_name: nil,
            proto_version: nil,
            flags: nil,
            keep_alive: nil,
            client_id: nil,
            will_topic: nil,
            will_payload: nil,
            username: nil,
            password: nil
end
