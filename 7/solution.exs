defmodule BitwiseGates do
  use Bitwise

  @maxint_16bit 65535
  
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    map = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&parse_line/1)
        |> Enum.reduce(%{}, &add_command_to_map/2)
    File.close(file)
    map
  end

  defp parse_line(line) do
    String.split(line, " ")
      |> List.to_tuple
      |> normalise_command
      |> convert_params
  end

  defp normalise_command(command) do
    case command do
      {"NOT", p, _, g} -> {String.to_atom(g), :not, [p]}
      {p1, "OR", p2, _, g} -> {String.to_atom(g), :or, [p1, p2]}
      {p1, "AND", p2, _, g} -> {String.to_atom(g), :and, [p1, p2]}
      {p1, "LSHIFT", p2, _, g} -> {String.to_atom(g), :lsh, [p1, p2]}
      {p1, "RSHIFT", p2, _, g} -> {String.to_atom(g), :rsh, [p1, p2]}
      {p1, _, g} -> {String.to_atom(g), :assign, [p1]}
    end
  end

  defp convert_params({gate, op, params}) do
    parsed_params = params
      |> Enum.map(&(convert_to_type(&1)))
      |> List.to_tuple
    {gate, op, parsed_params}
  end

  defp convert_to_type(str) do
    case {Integer.parse(str), str} do
      {:error, string} -> String.to_atom(string)
      {{int, _}, _} -> int
    end
  end

  defp add_command_to_map(command, acc) do
    {key, op, params} = command
    value = {op, params}
    Map.put(acc, key, value)
  end

  def until(map, key) do
    {_, actual} = Map.get(map, key)
    case actual do
      {val} when is_integer(val) -> val
      _ -> map |> replace_one_pass |> until(key)
    end
  end

  defp replace_one_pass(map) do
    map |> Enum.filter(&is_assignment?/1) 
        |> Enum.reduce(map, &replace_assignment/2)
        |> Enum.map(&eval_complete/1)
        |> Enum.into(%{})
  end

  defp is_assignment?({_, {:assign, {val}}}) when is_integer(val), do: true
  defp is_assignment?(_), do: false

  defp replace_assignment(assign, map) do
    {key, {_, {val}}} = assign
    map |> Enum.map(fn {k, {o, r}} ->
        params = case r do
          {arg} when arg == key -> {val}
          {left, right} when left == key -> {val, right}
          {left, right} when right == key -> {left, val}
          _ -> r
        end
        {k, {o, params}}
      end)
  end

  defp eval_complete({key, {op, {val}}}) when is_integer(val) do
    new_val = run_command({op, {val}})
    {key, {:assign, {new_val}}}
  end
  defp eval_complete({key, {op, {l, r}}}) when is_integer(l) and is_integer(r) do
    new_val = run_command({op, {l, r}})
    {key, {:assign, {new_val}}}
  end
  defp eval_complete(entry), do: entry

  defp run_command({:assign, {arg}}),      do: arg
  defp run_command({:not, {arg}}),         do: @maxint_16bit - arg
  defp run_command({:lsh, {left, right}}), do: left <<< right
  defp run_command({:rsh, {left, right}}), do: left >>> right
  defp run_command({:and, {left, right}}), do: left &&& right
  defp run_command({:or, {left, right}}),  do: left ||| right
  defp run_command(command), do: command
end

map = BitwiseGates.parse("input-full")
res = BitwiseGates.until(map, :a)
IO.puts "Part one: #{res}"

map = Map.put(map, :b, {:assign, {res}})
IO.puts "Part two: #{BitwiseGates.until(map, :a)}"
