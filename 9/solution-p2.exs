defmodule HeldKarpStrategy do
  @zero 0

  def longest(dists) do
    0..Enum.count(dists)-1
        |> Enum.map(&longest_from_node(&1,dists))
        |> Enum.reduce({@zero, []}, &reduce_to_maximum/2)
  end

  defp longest_from_node(start_node, dists) do
    nodes_to_hit = 0..Enum.count(dists)-1 |> Enum.filter(&(&1!=start_node))
    costs = calculate_costs(start_node, nodes_to_hit, dists)
    final_nodes = for n <- nodes_to_hit,
                     !(n==start_node),
                     do: {n, nodes_to_hit |> Enum.to_list |> List.delete(n) |> List.to_tuple }
    {max_cost, end_node} = final_nodes |> Enum.reduce({@zero, {}}, fn (key, acc) -> worse_node(key, acc, costs) end)
    path = path_from(end_node, start_node, costs) |> Enum.reverse
    {max_cost, path}
  end

  defp calculate_costs(start_node, nodes_to_hit, dists) do
    create_subsets(Enum.count(dists)-1, nodes_to_hit)
        |> create_keys(nodes_to_hit)
        |> Enum.reduce(%{}, fn (key, acc) -> calculate_maximum_costs(key, acc, start_node, dists) end)
  end

  defp create_subsets(n, all) do
    1..n-1
        |> Enum.map(&(create_combinations_with_size(&1, all)))
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

  defp create_keys(subsets, nodes) do
    for s <- subsets,
        n <- nodes,
        !(n in Tuple.to_list(s)),
        do: {n, s}
  end

  defp calculate_maximum_costs({i, subset}, costs_map, start_node, dists) do
    cost = 0..Enum.count(Tuple.to_list(subset))-1
      |> Enum.map(&(calculate_costs(&1, {i, subset}, costs_map, start_node, dists)))
      |> Enum.reduce({@zero,-1}, &reduce_to_maximum/2)
    Map.put(costs_map, {i, subset}, cost)
  end

  defp calculate_costs(n, {i, subset}, costs_map, start_node, dists) do
    subset_node = elem(subset, n)
    reduced_subset = Tuple.delete_at(subset, n)
    i2node_cost = dists[i][subset_node]
    node2start_cost = get_costs_from_map({subset_node, reduced_subset}, costs_map, start_node, dists)
    cost = i2node_cost + node2start_cost
    {cost, subset_node}
  end

  defp get_costs_from_map({i, {}}, _acc, start_node, dists), do: dists[start_node][i]
  defp get_costs_from_map(key, costs_map, _start_node, _dists) do
    {cost, _p} = Map.get(costs_map, key)
    cost
  end

  defp reduce_to_maximum({costs, node}, {cur_max, cur_node}) do
    if costs >= cur_max do
      {costs, node}
    else
      {cur_max, cur_node}
    end
  end

  defp worse_node(key, {cur_max, cur_key}, costs) do
    {cost, _p} = Map.get(costs, key)
    if (cost > cur_max) do
      {cost, key}
    else
      {cur_max, cur_key}
    end
  end

  defp path_from({i, s}, start_node, map) do
    val = Map.get(map, {i, s})
    case val do
      nil -> [i | [start_node] ]
      _ -> {_, parent} = val 
           [i | path_from({parent, delete_i_from_subset(parent, s)}, start_node, map)]
    end
  end

  defp delete_i_from_subset(i, subset) do
    subset
      |> Tuple.to_list
      |> List.delete(i)
      |> List.to_tuple
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

IO.inspect HeldKarpStrategy.longest(distances)