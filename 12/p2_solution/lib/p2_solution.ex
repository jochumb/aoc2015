defmodule P2Solution do
  def run do
    {:ok, file} = File.open("../input", [:read])
    IO.stream(file, :line)
        |> Enum.map(&String.rstrip/1)
        |> List.first
        |> Poison.decode!
        |> delete_red_objects
        |> Poison.encode!
        |> (fn (x) -> Regex.scan(~r/-?\d+/, x) end).()
        |> List.flatten
        |> Enum.map(&String.to_integer/1)
        |> Enum.reduce(0, &(&1 + &2))
        |> IO.puts
  end

  defp delete_red_objects(map) do
    has_red = Map.values(map) |> Enum.any?(fn (v) -> v == "red" end)
    if (has_red), do: %{},
    else: find_next(map)
  end

  defp find_next(map) when is_map(map) do
    Enum.map(map, fn {k, v} -> 
      case v do
        m when is_map(v) -> {k, delete_red_objects(m)}
        l when is_list(v) -> {k, find_next(l)}
        p -> {k, p}
      end
    end)
      |> Enum.into(%{})
  end

  defp find_next(list) when is_list(list) do
    Enum.map(list, fn (v) ->
      case v do
        m when is_map(v) -> delete_red_objects(m)
        l when is_list(v) -> find_next(l)
        p -> p
      end
    end)
  end
end
