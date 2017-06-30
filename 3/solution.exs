defmodule Grid do
  @north "^"
  @east ">"
  @south "v"
  @west "<"

  # Only santa
  def next_house(direction, {coords, visited}) do
    new_coords = next_coords(direction, coords)
    new_visited = next_visited(new_coords, visited)
    {new_coords, new_visited}
  end

  # Santa and robot
  def next_house(direction, {coords, other, visited}) do
    new_coords = next_coords(direction, coords)
    new_visited = next_visited(new_coords, visited)
    {other, new_coords, new_visited}
  end

  defp next_coords(@north, {x,y}),  do: {x,y+1}
  defp next_coords(@east, {x,y}),   do: {x+1,y}
  defp next_coords(@south, {x,y}),  do: {x,y-1}
  defp next_coords(@west, {x,y}),   do: {x-1,y}
  defp next_coords(_, c), do: c

  defp next_visited(coords, visited) do
    if coords in visited do
      visited
    else
      [coords | visited]
    end
  end
end

{:ok, file} = File.open("input", [:read])
{_,visited} = IO.read(file, :line)
    |> String.split("")
    |> Enum.reduce({{0,0}, []}, &Grid.next_house/2)
File.close(file)

IO.puts "Visited by santa: #{Enum.count(visited)}"

{:ok, file} = File.open("input", [:read])
{_,_,visited} = IO.read(file, :line)
    |> String.split("")
    |> Enum.reduce({{0,0}, {0,0}, []}, &Grid.next_house/2)
File.close(file)

IO.puts "Visited by santa or robot: #{Enum.count(visited)}"