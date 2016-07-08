defmodule Mesquitte.ProtocolVersion do
  defmacro __using__(_) do
    quote do
      @mqtt310               3
      @mqtt311               4
      @supported_mqtt_versions  [@mqtt310, @mqtt311]
    end
  end
end
