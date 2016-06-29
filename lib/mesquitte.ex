defmodule Mesquitte do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(:ranch_sup, [], shutdown: 5000),
      :ranch.child_spec(:tcp_mqtt, 100, :ranch_tcp, [{:port, 1883}], Mesquitte.MqttProtocol, [])
    ]

    opts = [strategy: :one_for_one, name: Mesquitte.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
