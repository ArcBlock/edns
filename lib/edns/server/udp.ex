defmodule Edns.Server.Udp do
  @moduledoc false

  use GenServer

  require Logger

  @default_udp_recbuf 1024 * 1024

  def start_link(%{id: id} = args) do
    GenServer.start_link(__MODULE__, args, name: id)
  end

  def init(%{address: address, port: port, family: family}) do
    {:ok, socket} = start(address, port, family)
    {:ok, %{address: address, port: port, socket: socket}}
  end

  def handle_info({:udp, socket, host, port, bin}, %{socket: socket} = state) do
    new_state = handle_request(socket, host, port, bin, state)
    :inet.setopts(socket, active: 100)
    {:noreply, new_state}
  end

  @doc false
  defp start(address, port, family) do
    case(
      :gen_udp.open(port, [
        :binary,
        {:active, 100},
        {:reuseaddr, true},
        {:read_packets, 1000},
        {:ip, address},
        {:recbuf, @default_udp_recbuf},
        family
      ])
    ) do
      {:ok, socket} ->
        Logger.info("UDP server started: #{family} - #{inspect(socket)} - #{port}")
        {:ok, socket}

      error ->
        Logger.error("UDP server started error, error: #{inspect(error)}")
        :error
    end
  end

  @doc false
  defp handle_request(socket, host, port, bin, state) do
    case Edns.decode_message(bin) do
      {:trailing_garbage, decoded_message, _} ->
        handle_process(decoded_message, socket, port, {:udp, host})

      {_, _, _} ->
        :ok

      decoded_message ->
        handle_process(decoded_message, socket, port, {:udp, host})
    end

    state
  end

  @doc false
  defp handle_process(decoded_message, socket, port, {:udp, host}) do
    resp = Edns.Handler.handle(decoded_message, {:udp, host})

    case Edns.encode_message(resp, max_size: 4096) do
      {false, encoded_msg} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {true, encoded_msg, %{__struct__: DnsMessage} = _message} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {false, encoded_msg, _} ->
        :gen_udp.send(socket, host, port, encoded_msg)

      {true, encoded_msg, _, _} ->
        :gen_udp.send(socket, host, port, encoded_msg)
    end
  end

  # __end_of_module__
end
