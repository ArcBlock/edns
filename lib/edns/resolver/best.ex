defmodule Edns.Resolver.Best do
  @moduledoc """

  """

  @dns_type_any 255
  @dns_rcode_nxdomain 3

  alias Edns.Resolver.Util

  @doc """

  """
  def resolve(%{query_name: name, zone: zone} = context, cname_chain) do
    best_rr = Util.best_match(name, zone)

    case Util.ref_rr_list(best_rr) do
      [] -> resolve_best(context, best_rr, cname_chain)
      ref_rr_list -> resolve_best_ref(context, best_rr, ref_rr_list, cname_chain)
    end
  end

  #
  @doc false
  defp resolve_best(%{message: msg, query_name: query_name, zone: zone}, _, _) do
    case msg.questions do
      [%{name: ^query_name} | _] ->
        %{msg | aa: true, rc: @dns_rcode_nxdomain, authority: zone.authority}

      _ ->
        msg
    end
  end

  #
  @doc false
  defp resolve_best_ref(context, best_rr, ref_rr, cname_chain) do
    resolve_best_ref_do(context, ref_rr, Util.soa_rr_list(best_rr), cname_chain)
  end

  @doc false
  defp resolve_best_ref_do(%{message: msg}, ref_rr, [], _cname_chain) do
    %{msg | aa: false, authority: msg.authority ++ ref_rr}
  end

  defp resolve_best_ref_do(%{message: msg}, _ref_rr, soa_rr, [] = _cname_chain) do
    %{msg | aa: true, rc: @dns_rcode_nxdomain, authority: soa_rr}
  end

  defp resolve_best_ref_do(%{message: msg, query_type: @dns_type_any}, _ref_rr, _soa_rr, _) do
    msg
  end

  defp resolve_best_ref_do(%{message: msg}, _ref_rr, soa_rr, _cname_chain) do
    %{msg | authority: soa_rr}
  end

  # __end_of_module__
end
