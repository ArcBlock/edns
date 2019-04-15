defmodule Edns.Resolver.Util do
  @moduledoc false

  @doc """

  """
  def ref_rr_list(rr_list) do
    rr_list_by_type(rr_list, NS)
  end

  @doc """

  """
  def cname_rr_list(rr_list) do
    rr_list_by_type(rr_list, CNAME)
  end

  @doc """

  """
  def soa_rr_list(rr_list) do
    rr_list_by_type(rr_list, SOA)
  end

  @doc """

  """
  def ns_rr_list(rr_list) do
    rr_list_by_type(rr_list, NS)
  end

  @doc """

  """
  def rr_list_by_type(rr_list, type) do
    rr_list
    |> Enum.filter(fn record -> record.type == type end)
  end

  @doc """

  """
  def check_if_parent(possible_parent_name, name) do
    case :lists.subtract(:dns.dname_to_labels(possible_parent_name), :dns.dname_to_labels(name)) do
      [] -> true
      _ -> false
    end
  end

  @doc """

  """
  def restart_delegated(true, context, cname_chain) do
    Edns.Resolver.Zone.resolve(context, cname_chain)
  end

  def restart_delegated(false, %{query_name: name, zone: zone} = context, cname_chain) do
    new_context = %{context | zone: Edns.Zone.find(name, zone.authority)}
    Edns.Resolver.Zone.resolve(new_context, cname_chain)
  end

  @doc """

  """
  def best_match(name, zone) do
    best_match(name, zone, :dns.dname_to_labels(name))
  end

  @doc false
  defp best_match(_name, _, []), do: []

  defp best_match(name, zone, [_ | rest]) do
    wildcard_name = :dns.labels_to_dname(["*" | rest])
    best_match(name, zone, rest, Edns.Zone.get_records_by_name(wildcard_name))
  end

  @doc false
  defp best_match(_name, _zone, [], []), do: []

  defp best_match(name, zone, labels, []) do
    dname = :dns.labels_to_dname(labels)

    case Edns.Zone.get_records_by_name(dname) do
      [] -> best_match(name, zone, labels)
      matches -> matches
    end
  end

  defp best_match(_, _, _, wildcard_matches) do
    wildcard_matches
  end

  # __end_of_module__
end
