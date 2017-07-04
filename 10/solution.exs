defmodule LookSay do
  def pass(input) do
    res = translate(input, [], [])
      |> Enum.reverse
    res
  end
  
  defp translate([], [], acc), do: acc
  defp translate([head | tail], [], acc), do: translate(tail, [head], acc)
  defp translate([], [prev | rest], acc) do
    translate([], [], add_to_result(prev, rest, acc))
  end
  defp translate([head | tail], [prev | rest], acc) when head == prev  do
    translate(tail, [head | [prev | rest]], acc)
  end
  defp translate([head | tail], [prev | rest], acc) do
    translate(tail, [head], add_to_result(prev, rest, acc))
  end
  
  defp add_to_result(prev, rest, acc), do: [prev | [Enum.count(rest)+1 | acc]]
end

input = "1321131112" |> String.codepoints |> Enum.map(&String.to_integer/1)

part1 = 1..40 |>  Enum.reduce(input, fn (_x, current) -> LookSay.pass(current) end)
IO.puts "Part 1: #{Enum.count(part1)}"

part2 = 1..50 |>  Enum.reduce(input, fn (_x, current) -> LookSay.pass(current) end)
IO.puts "Part 2: #{Enum.count(part2)}"