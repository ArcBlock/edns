defmodule Edns.Handler do
  @moduledoc false

  @dns_rcode_refused 5

  @doc """

  """
  def handle(%{__struct__: DnsMessage} = message, {_, host}) do
    handle_message(message, host)
  end

  def handle(bad_message, _) do
    bad_message
  end

  @doc false
  defp handle_message(message, host) do
    # {message.questions, message.additional} as key
    handle_cache_miss(message, get_authority(message), host)
  end

  @doc false
  defp handle_cache_miss(message, [], _) do
    %{message | aa: false, rc: @dns_rcode_refused}
  end

  defp handle_cache_miss(message, authority, host) do
    res = Edns.Resolver.resolve(message, authority, host)
    maybe_cache(res, res.aa)
  end

  @doc false
  defp maybe_cache(res, true) do
    res
  end

  defp maybe_cache(res, false) do
    res
  end

  @doc false
  defp get_authority(message) do
    case Edns.Zone.get_authority(message) do
      {:ok, authority} -> authority
      _ -> []
    end
  end

  # __end_of_module__
end
