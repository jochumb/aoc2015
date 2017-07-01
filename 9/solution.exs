defmodule HeldKarp do
  
  def shortest(_dists) do
    0
  end

end

defmodule Cities do
  
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    lines = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&List.to_tuple/1)
    File.close(file)
    lines
  end

  def cities(lines) do
    lines
      |> Enum.map(fn ({to, _, from, _, _}) -> {to, from} end)
      |> Enum.reduce(%{}, fn ({to, from}, acc) ->
        key = String.to_atom(to)
        acc = if !Map.has_key?(acc, key), do: Map.put(acc, key, Enum.count(acc)), else: acc
        key = String.to_atom(from)
        if !Map.has_key?(acc, key), do: Map.put(acc, key, Enum.count(acc)), else: acc
      end)
  end

  def distances(lines, cities) do
    start = for id <- Map.values(cities),
            do: {id, Map.put(%{}, id, 0)}
    distances = Enum.into(start, %{})
    lines
      |> Enum.map(&(parse_to_ids(&1, cities)))
      |> Enum.reduce(distances, &add_distance/2)
  end

  defp parse_to_ids({start, _, finish, _, distance}, cities) do
    c1 = Map.get(cities, String.to_atom(start))
    c2 = Map.get(cities, String.to_atom(finish))
    {c1, c2, String.to_integer(distance)}
  end

  defp add_distance({start, finish, distance}, distances) do
    distances = put_in distances[start][finish], distance
    distances = put_in distances[finish][start], distance
    distances
  end
end

lines = Cities.parse("input")
cities = Cities.cities(lines)
distances = Cities.distances(lines, cities)

IO.inspect distances
