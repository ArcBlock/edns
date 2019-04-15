defmodule Edns.Zone.Loader do
  @moduledoc false

  alias Edns.Zone

  def load_zones(file_name) do
    case File.read(file_name) do
      {:ok, file_data} -> load_zones_from_file(file_data)
      error -> error
    end
  end

  @doc false
  defp load_zones_from_file(file_data) do
    file_data
    |> Jason.decode!(keys: :atoms)
    |> Enum.each(fn json_zone ->
      json_zone
      |> Zone.parse()
      |> Zone.put()
    end)
  end

  # __end_of_module__
end
