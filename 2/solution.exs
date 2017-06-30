defmodule Package do

  def convert_line_to_tuple(line) do
    line
      |> String.rstrip
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort
      |> List.to_tuple
  end

  def accumulate_surface_and_ribbon(dim, {surface_acc, ribbon_acc}) do
    {surface_acc+surface(dim), ribbon_acc+ribbon(dim)}
  end

  defp surface({l, w, h}), do: 2*l*w + 2*w*h + 2*h*l + l*w
  defp ribbon({l, w, h}), do: 2*l + 2*w + l*w*h

end

{:ok, file} = File.open("input", [:read])
{surface, ribbon} = IO.stream(file, :line)
    |> Stream.map(&Package.convert_line_to_tuple/1)
    |> Enum.reduce({0,0}, &Package.accumulate_surface_and_ribbon/2)
File.close(file)

IO.puts "Total packaging material needed: #{surface} sq ft"
IO.puts "Total ribbon length required: #{ribbon} ft"