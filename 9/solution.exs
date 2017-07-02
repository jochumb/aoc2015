defmodule HeldKarp do
  
  def shortest(dists) do
    subsets = create_subsets(Enum.count(dists)-1)
    # subsets = [ {} | [ {1} | [ {2} | [ .. | [ {1,2,..,n-2,n-1} | [] ]]]]]
    keys = create_keys(Enum.count(dists)-1, subsets)
    
    costs = keys |> Enum.reduce(%{}, fn (key, acc) -> calculate_minimum_costs(key, acc, dists) end)
    # costs[{index, {subset}}] = {cost, parent}


    # {0, {1,2,..,n-1,n}} -> determine_cost

    # Create path from parents
    # return {cost, path}
    costs
  end

  defp create_subsets(n) do
    1..n-1 
        |> Enum.map(&(create_combinations_with_size(&1, Enum.to_list(1..n))))
        |> Enum.reduce([], fn (x, acc) -> acc ++ x end)
  end

  defp create_combinations_with_size(s, l) do
    comb(s, l) |> Enum.map(&List.to_tuple/1)
  end
 
  defp comb(0, _), do: [[]]
  defp comb(_, []), do: []
  defp comb(m, [h|t]) do
    (for l <- comb(m-1, t), do: [h|l]) ++ comb(m, t)
  end

  defp create_keys(n, subsets) do
    for s <- subsets,
        i <- 1..n,
        !(i in Tuple.to_list(s)),
        do: {i, s}
  end

  @infinite = 2147483647
  defp calculate_minimum_costs({i, subset} = key, acc, dists) do
    cost = 0..Enum.count(subset)
      |> Enum.map(&(calculate_costs(&1, key, acc, dists)))
      |> Enum.map({@infinite,-1}, &reduce_to_minimum/2)
    Map.put(acc, key, cost)
  end

  defp calculate_costs(n, {i, subset}, acc, dists) do
    subset_node = elem(subset, n)
    reduced_subset = Tuple.delete_at(subset, n)
    {dists[i][subset_node] + get_costs_from_map({subset_node, reduced_subset}, acc, dists), subset_node}
  end

  defp get_costs_from_map({i, {}}, _acc, dists), do: dists[0][i]
  defp get_costs_from_map(key, acc, _dists), do: Map.get(acc, key)

  defp reduce_to_minimum({costs, node}, {cur_min, cur_node}) do
    if costs <= current_min do
      {costs, node}
    else
      {cur_min, cur_node}
    end
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
