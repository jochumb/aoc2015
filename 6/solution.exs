defmodule LightGrid do
  def parse_command(command) do
    {cmd, rest} = case command do
        "turn on" <> rest -> {:on, rest}
        "turn off" <> rest -> {:off, rest}
        "toggle" <> rest -> {:toggle, rest}
    end
    [from, _, to] = String.split(rest)
    [fx, fy] = String.split(from, ",") |> Enum.map(&String.to_integer/1)
    [tx, ty] = String.split(to, ",") |> Enum.map(&String.to_integer/1)

    { cmd, min(fx, tx), min(fy, ty), max(fx, tx), max(fy, ty) }
  end

  def execute({cmd, fx, fy, tx, ty}, map) do
    coords(fx, fy, tx, ty)
      |> Enum.reduce(map, fn (x, acc) -> switch(cmd, x, acc) end )
  end

  defp coords(fx, fy, tx, ty) do
    for x <- fx..tx,
        y <- fy..ty,
        do: {x, y}
  end

  defp switch(:on, coord, map), do: Map.put(map, coord, true)
  defp switch(:off, coord, map), do: Map.put(map, coord, false)
  defp switch(:toggle, coord, map), do: Map.update(map, coord, true, &(!&1))
end

{:ok, file} = File.open("input", [:read])
final = IO.stream(file, :line)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&LightGrid.parse_command/1)
    |> Enum.reduce(%{}, &LightGrid.execute/2)
    |> Enum.filter(fn {_, v} -> v end)
File.close(file)

IO.puts "Number of lights on: #{Enum.count(final)}"