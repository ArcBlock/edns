defmodule Edns.Zone.Store do
  @moduledoc false

  @doc """

  """
  def put_zone(name, %{records: records} = zone) do
    Edns.Zone.Cache.put_with_ttl(name, zone, get_zone_ttl_from_soa(records))
  end

  @doc """

  """
  def get_zone(name) do
    Edns.Zone.Cache.get_with_ttl(name)
  end

  @doc false
  defp get_zone_ttl_from_soa(records) do
    records
    |> Enum.filter(fn record -> SOA == Map.get(record, :type) end)
    |> Enum.map(fn record -> Map.get(record, :ttl) end)
    |> Enum.min(fn -> 0 end)
  end

  # __end_of_module__
end
