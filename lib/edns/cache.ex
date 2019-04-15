defmodule Edns.Cache do
  @moduledoc """
  Definition for edns cache test.
  """

  use Mcc.Model

  import_table(Edns.Zone.Cache.Exp)
  import_table(Edns.Zone.Cache)

  # __end_of_module__
end
