defmodule UnliteralChars do
  
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    map = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Enum.to_list
    File.close(file)
    map
  end

  def char_counter(str, {p1, p2}) do
    total = String.length(str)
    reduced_str = str
      |> String.replace(~r/\\x[0-9a-f]{2}/, "*")
      |> String.replace("\\\\", "$")
      |> String.replace("\\\"", "$")
      |> String.replace("\"", "")
    count = total - String.length(reduced_str)
    encode_chars = (length(String.split(reduced_str, "*")) - 1) + (length(String.split(reduced_str, "$")) - 1) * 2 + 4
    {p1+count, p2+encode_chars}
  end
end

{part1, part2} = UnliteralChars.parse("input")
  |> Enum.reduce({0,0}, &UnliteralChars.char_counter/2)

IO.puts "Part one: #{part1}"
IO.puts "Part two: #{part2}"