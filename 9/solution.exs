defmodule HeldKarp do
  
  def shortest(dists) do
    subsets = create_subsets(Enum.count(dists)-1)
    # subsets = [ {} | [ {1} | [ {2} | [ .. | [ {1,2,..,n-2,n-1} | [] ]]]]]

    # keys = for s <- subsets,
    #     i <- 1..n,
    #     i not in s,
    #     do: {i, s}
    
    # costs = keys |> Enum.reduce(%{}, determine_cost)
    # costs[{index, {subset}}] = {cost, parent}


    # {0, {1,2,..,n-1,n}} -> determine_cost

    # Create path from parents
    # return {cost, path}
    subsets
  end

  defp create_subsets(num) do
    subsets = 1..num-1 
    |> Enum.map(&(create_combinations_with_size(&1, Enum.to_list(1..num))))
    |> Enum.reduce([], fn (x, acc) -> acc ++ x end)
    [{} | subsets]
  end

  defp create_combinations_with_size(s, l) do
    comb(s, l) |> Enum.map(&List.to_tuple/1)
  end
 
  defp comb(0, _), do: [[]]
  defp comb(_, []), do: []
  defp comb(m, [h|t]) do
    (for l <- comb(m-1, t), do: [h|l]) ++ comb(m, t)
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

subsets = HeldKarp.shortest(distances)

IO.inspect subsets
