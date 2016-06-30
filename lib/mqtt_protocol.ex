defmodule Mesquitte.MqttProtocol do
  require Logger

  @behaviour :ranch_protocol
  alias Mesquitte.Decoding

  def start_link(ref, socket, transport, opts) do
    :proc_lib.start_link(__MODULE__, :init, [ref, socket, transport, opts])
  end

  def init(ref, socket, transport, _opts) do
    :ok = :proc_lib.init_ack({:ok, self()})

    # State initialization here

    :ok = :ranch.accept_ack(ref)
    transport.setopts(socket, [active: :once])

    :gen_server.enter_loop(__MODULE__, [], %{
      ref: ref,
      socket: socket,
      transport: transport,
      client_id: nil})
  end

  @doc """
  Called when data is received on the socket.
  """
  def handle_info({:tcp, socket, bin}, state) do
    state.transport.setopts(socket, [active: :once])
    Logger.debug "State: #{inspect state}"
    packets = Decoding.split_packets(bin)
    {:noreply, state}
  end

  @doc """
  Called when the TCP connection is closed unexpectedly.
  """
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  @doc """
  Called when an unrecognized message is received by the process.
  """
  def handle_info(other, state) do
    Logger.debug("Unrecognized message received: #{inspect other}")
    {:noreply, state}
  end

  @doc """
  Called sometimes when the connection process is terminated
  """
  def terminate(reason, state) do
    Logger.debug "Process terminated: #{inspect self()}, reason: #{reason}, state: #{inspect state}"
    :shutdown
  end

end
