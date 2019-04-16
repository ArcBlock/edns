defmodule EdnsResolverTest do
  use ExUnit.Case

  alias Edns.{Resolver, Zone}

  @dns_type_a 1
  @host "127.0.0.1"

  test "resolve dns type is rrsig" do
    message = %DnsMessage{questions: [%DnsQuery{type: 46}]}
    new_message = Resolver.resolve(message, nil, nil)
    assert false == new_message.ra
    assert false == new_message.ad
    assert false == new_message.cd
    assert 5 == new_message.rc
  end

  test "resolve dns, questions is empty" do
    Resolver.resolve(%DnsMessage{}, nil, nil)
  end

  test "resolve best: nxdomain 1" do
    name = "start3sssa.a.a.a.a.start1.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)
    assert authority == Resolver.resolve(message, authority, @host).authority
  end

  test "resolve best: nxdomain 2, but has ns rr list" do
    name = "start3sssa.a.a.a.a.example.com"
    message = build_query_message(@dns_type_a, name)
    {:ok, authority} = Zone.get_authority(name)
    assert authority == Resolver.resolve(message, authority, @host).authority
  end

  defp build_query_message(type, name) do
    %DnsMessage{questions: [%DnsQuery{type: type, name: name}]}
  end

  # __end_of_module__
end
