defmodule LookSay do
  
  def pass(input) do
    res = translate(input, [], [])
      |> Enum.reverse
    res
  end
  
  def translate([], [], acc), do: acc
  def translate([], [prev | rest], acc), do: translate([], [], [prev | [Enum.count(rest)+1 | acc]])
  def translate([head | tail], [], acc), do: translate(tail, [head], acc)
  def translate([head | tail], [prev | rest], acc) do
    case head do
      n when head == prev -> translate(tail, [head | [n | rest]], acc)
      _ -> translate(tail, [head], [prev | [Enum.count(rest)+1 | acc]])
    end
  end

end

input = "1321131112" |> String.codepoints |> Enum.map(&String.to_integer/1)

part1 = 1..40 |>  Enum.reduce(input, fn (_x, current) -> LookSay.pass(current) end)
IO.puts "Part 1: #{Enum.count(part1)}"

part2 = 1..50 |>  Enum.reduce(input, fn (_x, current) -> LookSay.pass(current) end)
IO.puts "Part 2: #{Enum.count(part2)}"