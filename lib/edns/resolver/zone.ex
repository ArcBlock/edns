defmodule Edns.Resolver.Zone do
  @moduledoc """

  """

  @dns_rcode_noerror 0

  alias Edns.Resolver.{Best, Exact, Util}
  alias Edns.Zone

  @doc """

  """
  def resolve(%{message: msg, zone: {:error, :not_authoritative}}, _) do
    %{msg | aa: true, rc: @dns_rcode_noerror}
  end

  def resolve(%{query_name: name, zone: zone, message: msg} = context, cname_chain) do
    result =
      case Zone.get_records_by_name(name) do
        [] -> Best.resolve(context, cname_chain)
        matched_rr -> Exact.resolve(context, matched_rr, cname_chain)
      end

    case detect_zonecut(zone, name) do
      [] ->
        result

      records ->
        filtered_cname_answers =
          result.answers
          |> Util.cname_rr_list()
          |> Enum.filter(fn cname_answer ->
            case detect_zonecut(zone, cname_answer.data.dname) do
              [] -> false
              _ -> true
            end
          end)

        %{
          msg
          | aa: false,
            rc: @dns_rcode_noerror,
            authority: records,
            answers: filtered_cname_answers
        }
    end
  end

  @doc false
  defp detect_zonecut(zone, name) when is_bitstring(name) do
    detect_zonecut(zone, :dns.dname_to_labels(name))
  end

  defp detect_zonecut(_, []), do: []
  defp detect_zonecut(_, [_]), do: []

  defp detect_zonecut(zone, [_ | parent_labels] = labels) do
    name = :dns.labels_to_dname(labels)

    case :dns.compare_dname(zone_authority_name(zone.authority), name) do
      true ->
        []

      false ->
        case Util.ns_rr_list(Zone.get_records_by_name(name)) do
          [] -> detect_zonecut(zone, parent_labels)
          zone_cut_ns_rr -> zone_cut_ns_rr
        end
    end
  end

  @doc false
  defp zone_authority_name([record | _]) do
    record.name
  end

  # __end_of_module__
end
