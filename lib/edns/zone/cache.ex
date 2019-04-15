defmodule Edns.Zone.Cache.Exp do
  @moduledoc false

  use Mcc.Model.Table,
    table_opts: [
      type: :ordered_set,
      ram_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ]

  defstruct [:key, :value]
end

defmodule Edns.Zone.Cache do
  @moduledoc false

  alias Edns.Zone.Cache.Exp, as: ZoneExp

  use Mcc.Model.Table,
    table_opts: [
      type: :set,
      disc_copies: [node()],
      storage_properties: [
        ets: [:compressed, read_concurrency: true]
      ]
    ],
    expiration_opts: [
      expiration_table: ZoneExp,
      main_table: __MODULE__,
      size_limit: 100,
      # 300M
      memory_limit: 300,
      waterline_ratio: 0.7,
      check_interval: 1_000
    ]

  defstruct([:name, :zone], true)

  def get_with_ttl(k) do
    case get(k) do
      %{name: ^k, zone: zone} -> zone
      _ -> nil
    end
  end

  def put_with_ttl(_k, v, 0), do: v

  def put_with_ttl(k, v, ttl) do
    put(k, %__MODULE__{name: k, zone: v}, ttl)
    v
  end

  #
end
