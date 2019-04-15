defmodule Edns.Type do
  @moduledoc false

  def encode(A), do: 1
  def encode(NS), do: 2
  def encode(CNAME), do: 5
  def encode(SOA), do: 6
  def encode(AAAA), do: 28

  # __end_of_module__
end
