defmodule Mesquitte.Packet.ConnectFlags do
  defstruct username: false,
            password: false,
            will_retain: false,
            will_qos: 0,
            will: false,
            clean_session: true

  import Mesquitte.Conversions

  def new(username, password, will_retain, will_qos, will, clean_session) do
    %Mesquitte.Packet.ConnectFlags{
      username: to_bool(username),
      password: to_bool(password),
      will_retain: to_bool(will_retain),
      will_qos: will_qos,
      will: to_bool(will),
      clean_session: to_bool(clean_session)}
  end
end
