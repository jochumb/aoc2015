defmodule Reindeer do

  def run(filename, seconds) do
    parse(filename)
      |> Enum.map(&(distance_after_seconds(&1, seconds)))
      |> Enum.max
      |> IO.inspect
  end
  
  defp parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    lines = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.map(&clean_tuple/1)
    File.close(file)
    lines
  end

  defp clean_tuple({reindeer, _, _, speed, _, _, time, _, _, _, _, _, _, rest, _}), 
    do: {reindeer, String.to_integer(speed), String.to_integer(time), String.to_integer(rest)} 

  defp distance_after_seconds({_, _, fly_time, _} = reindeer, seconds) do
    pass_one_second(:fly, 0, seconds, fly_time, reindeer)
  end

  defp pass_one_second(_, distance, 0, _, {name, _, _, _}), do: distance
  defp pass_one_second(:fly, distance, seconds, fly_time, {_, speed, _, _} = reindeer) when fly_time > 1 do
    pass_one_second(:fly, distance+speed, seconds-1, fly_time-1, reindeer)
  end
  defp pass_one_second(:fly, distance, seconds, _, {_, speed, _, rest_time} = reindeer) do
    pass_one_second(:rest, distance+speed, seconds-1, rest_time, reindeer)
  end
  defp pass_one_second(:rest, d, seconds, rest_time, reindeer) when rest_time > 1 do
    pass_one_second(:rest, d, seconds-1, rest_time-1, reindeer)
  end
  defp pass_one_second(:rest, d, seconds, _, {_, _, fly_time, _} = reindeer) do
    pass_one_second(:fly, d, seconds-1, fly_time, reindeer)
  end

end

Reindeer.run("input", 2503)