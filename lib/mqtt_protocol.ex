defmodule Mesquitte.MqttProtocol do
  require Logger

  @behaviour :ranch_protocol

  alias Mesquitte.{Decoding, Packet, PacketDecoder}

  def start_link(ref, socket, transport, opts) do
    :proc_lib.start_link(__MODULE__, :init, [ref, socket, transport, opts])
  end

  def init(ref, socket, transport, _opts) do
    :ok = :proc_lib.init_ack({:ok, self()})

    # State initialization here
    {:ok, peer} = :ranch_tcp.peername(socket)
    Logger.debug "Connection established. #{inspect self()}, #{format_peer(peer)}"

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
    packets = Decoding.split_packets(bin)
    dispatch(packets, state)
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
  Sequentially dispatches one or more packets to the appropriate handler
  A handler may disconnect the client and terminate the process before all packets are dispatched by returning {:stop, reason, state}.
  """
  def dispatch([packet|t], state) do
    case handle(packet, state) do
      {:ok, new_state} ->
        dispatch(t, new_state)
      {:stop, reason, new_state} = stop ->
        disconnect(reason, new_state)
        stop
      end
  end

  @doc """
  Ends the dispatch loop when no more packets are available
  """
  def dispatch([], state), do: {:noreply, state}

  @doc """
  Handler for CONNECT packets
  Pre-decodes the protocol version before delegating to the decoder.
  """
  def handle({:connect, bin, opts} = packet, state) do
    {:ok, version} = Decoding.decode_proto_version(packet)
    new_opts = opts |> Map.put(:version, version)

    {connect, _, _} = Packet.type_to_struct(:connect)
    |> PacketDecoder.decode(bin, new_opts)

    # Create or get session
    # Construct CONNACK
    # Send CONNACK

    Logger.debug "CONNECT: #{inspect connect}"
    new_state = state |> Map.put(:proto_version, version)
    {:ok, new_state}
  end

  @doc """
  Called when no handler is available for this type of message
  """
  def handle(other, state) do
    Logger.debug "Packet type not supported: #{inspect other}"
    {:ok, state}
  end

  @doc """
  Disconnects the client from the server
  """
  def disconnect(_reason, %{transport: transport, socket: socket}) do
    transport.close(socket)
  end

  @doc """
  Called when the client disconnected first
  """
  def disconnect(:tcp_close, _state) do
    Logger.debug "Connection already closed, skipping"
  end

  @doc """
  Called sometimes when the connection process is terminated
  """
  def terminate(reason, state) do
    Logger.debug "Process terminated: #{inspect self()}, reason: #{inspect reason}, state: #{inspect state}"
    :shutdown
  end

  defp format_peer({{o1, o2, o3, o4}, port}) do
    "#{o1}.#{o2}.#{o3}.#{o4}:#{port}"
  end
end
