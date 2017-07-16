defmodule EggnogContainers do

  @eggnog 150
  def run do
    cs = combinations()
    IO.puts "Part 1: #{Enum.count(cs)}"
    reduced = Enum.reduce(cs, [], fn (c, acc) -> filter_minumum(c, acc, minimum(cs)) end)
    IO.puts "Part 2: #{Enum.count(reduced)}"
  end

  defp combinations do
    containers() |> split(@eggnog)
  end

  defp containers do
    {:ok, file} = File.open("input", [:read])
    containers = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Enum.map(&String.to_integer/1)
    File.close(file)
    containers
  end

  defp split(_, total) when total <= 0, do: [[]]
  defp split([], _), do: []
  defp split([c|cs], total) when c > total, do: split(cs, total)
  defp split([c|cs], total) do
    (for l <- split(cs, total-c),
        Enum.sum([c|l]) == total,
        do: [c|l]) ++ split(cs, total)
  end

  defp minimum([c|cs]), do: _minimum(cs, Enum.count(c))
  defp _minimum([], min), do: min
  defp _minimum([c|cs], min) do
    cur = Enum.count(c)
    _minimum(cs, (if cur < min, do: cur, else: min))
  end

  defp filter_minumum(c, acc, min) do
    if Enum.count(c) == min, do: [c|acc], else: acc
  end

end

EggnogContainers.run()
