defmodule Floor do
  @up "("
  @down ")"
  
  def next_floor(@up, {move, floor, b}),    do: {move+1, floor+1, b}
  def next_floor(@down, {move, 0, 0}),      do: {move+1, -1, move}
  def next_floor(@down, {move, floor, b}),  do: {move+1, floor-1, b}
  def next_floor(_, res), do: res
end

{:ok, file} = File.open("input", [:read])
{_, floor, basement} = IO.read(file, :line)
    |> String.split("")
    |> Enum.reduce({1,0,0}, &Floor.next_floor/2)
File.close(file)

IO.puts "Go to floor #{floor}"
IO.puts "First time basement at move #{basement}"