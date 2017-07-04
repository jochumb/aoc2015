defmodule HeldKarp do
  
  def shortest(dists) do
    {key, circle} = calculate_costs(dists) |> calculate_full_circle(dists)
    {total_cost, _} = Map.get(circle, key)
    path = path_from(key, circle) |> Enum.reverse
    {total_cost, path}
  end

  defp calculate_costs(dists) do
    v_count = Enum.count(dists)
    create_subsets(v_count-1)
        |> create_keys(v_count-1)
        |> Enum.reduce(%{}, fn (key, acc) -> calculate_minimum_costs(key, acc, dists) end)
  end

  defp calculate_full_circle(costs, dists) do
    full_subset = 1..Enum.count(dists)-1 |> Enum.to_list |> List.to_tuple
    key = {0, full_subset}
    circle = calculate_minimum_costs(key, costs, dists)
    {key, circle}
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

  defp create_keys(subsets, n) do
    for s <- subsets,
        i <- 1..n,
        !(i in Tuple.to_list(s)),
        do: {i, s}
  end

  @infinite 2147483647
  defp calculate_minimum_costs({i, subset}, costs_map, dists) do
    cost = 0..Enum.count(Tuple.to_list(subset))-1
      |> Enum.map(&(calculate_costs(&1, {i, subset}, costs_map, dists)))
      |> Enum.reduce({@infinite,-1}, &reduce_to_minimum/2)
    Map.put(costs_map, {i, subset}, cost)
  end

  defp calculate_costs(n, {i, subset}, costs_map, dists) do
    subset_node = elem(subset, n)
    reduced_subset = Tuple.delete_at(subset, n)
    i2node_cost = dists[i][subset_node]
    node2start_cost = get_costs_from_map({subset_node, reduced_subset}, costs_map, dists)
    cost = i2node_cost + node2start_cost
    {cost, subset_node}
  end

  defp get_costs_from_map({i, {}}, _acc, dists), do: dists[0][i]
  defp get_costs_from_map(key, costs_map, _dists) do
    {cost, _p} = Map.get(costs_map, key)
    cost
  end

  defp reduce_to_minimum({costs, node}, {cur_min, cur_node}) do
    if costs <= cur_min do
      {costs, node}
    else
      {cur_min, cur_node}
    end
  end

  defp path_from({i, s}, map) do
    val = Map.get(map, {i, s})
    case val do
      nil -> [i | [0] ]
      _ -> {_, parent} = val 
           [i | path_from({parent, delete_i_from_subset(parent, s)}, map)]
    end
  end

  defp delete_i_from_subset(i, subset) do
    subset
      |> Tuple.to_list
      |> List.delete(i)
      |> List.to_tuple
  end
end