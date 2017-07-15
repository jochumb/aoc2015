defmodule HappySeats do
  
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    lines = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.map(&clean_tuple/1)
    File.close(file)
    lines
  end

  # HeldKarp looks for minimum, so gain is minus and lose is plus.
  # Result should be multiplied by -1
  def clean_tuple({from, _, "gain", num, _, _, _, _, _, _, to}), do: {from, String.strip(to, ?.), String.to_integer(num) * -1} 
  def clean_tuple({from, _, "lose", num, _, _, _, _, _, _, to}), do: {from, String.strip(to, ?.), String.to_integer(num)}

  def people(lines) do
    lines
      |> Enum.reduce(%{}, fn ({to, from, _}, acc) ->
        key = String.to_atom(to)
        acc = if !Map.has_key?(acc, key), do: Map.put(acc, key, Enum.count(acc)), else: acc
        key = String.to_atom(from)
        if !Map.has_key?(acc, key), do: Map.put(acc, key, Enum.count(acc)), else: acc
      end)
  end

  def happiness(lines, people) do
    start = for id <- Map.values(people),
            do: {id, Map.put(%{}, id, 0)}
    happiness = Enum.into(start, %{})
    lines
      |> Enum.map(&(parse_to_ids(&1, people)))
      |> Enum.reduce(happiness, &add_happiness/2)
  end

  defp parse_to_ids({from, to, change}, people) do
    c1 = Map.get(people, String.to_atom(from))
    c2 = Map.get(people, String.to_atom(to))
    {c1, c2, change}
  end

  defp add_happiness({to, from, change}, happiness) do
    current = Map.get(happiness[from], to, 0)
    happiness = put_in happiness[from][to], current + change
    happiness = put_in happiness[to][from], current + change
    happiness
  end

  def add_person(happiness) do
    num = Enum.count(happiness)
    zero_map = 0..num
      |> Enum.to_list
      |> Enum.map(fn x -> {x, 0} end)
      |> Enum.into(%{})
    Map.keys(happiness)
      |> Enum.map(fn key -> {key, Map.put(Map.get(happiness, key), num, 0)} end)
      |> Enum.into(%{})
      |> Map.put(num, zero_map)
  end
end

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

lines = HappySeats.parse("input")
people = HappySeats.people(lines)
happiness = HappySeats.happiness(lines, people)
{shortest, _} = HeldKarp.shortest(happiness)
IO.puts "Part 1: happiness change is #{shortest*-1}"

happiness = HappySeats.add_person(happiness)
{shortest, _} = HeldKarp.shortest(happiness)
IO.puts "Part 2: happiness change is #{shortest*-1}"
