defmodule Reindeer do
  defstruct name: "", speed: 0, fly_time: 0, rest_time: 0, distance: 0, points: 0, mode: :fly, remaining: 0

  def run(filename, seconds) do
    parse(filename)
        |> loop_for_seconds(seconds)
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

  defp clean_tuple({name, _, _, speed, _, _, fly_time, _, _, _, _, _, _, rest_time, _}) do
    speed = String.to_integer(speed)
    fly_time = String.to_integer(fly_time)
    rest_time = String.to_integer(rest_time)
    %Reindeer{name: name, speed: speed, fly_time: fly_time, rest_time: rest_time, remaining: fly_time} 
  end

  defp loop_for_seconds(reindeers, 0) do
    reindeers
      |> max_distance
      |> (fn (x) -> IO.puts("Part 1: #{x}") end).()
    reindeers
      |> max_points
      |> (fn (x) -> IO.puts("Part 2: #{x}") end).()
  end

  defp loop_for_seconds(reindeers, secs) do
    reindeers
        |> Enum.map(&tick_one_second/1)
        |> assign_point_to_leader
        |> loop_for_seconds(secs-1)
  end

  defp tick_one_second(%Reindeer{mode: :fly, distance: d, speed: s, remaining: t, rest_time: new_t} = r) when t == 1 do
    %Reindeer{r | mode: :rest, distance: d+s, remaining: new_t}
  end
  defp tick_one_second(%Reindeer{mode: :fly, distance: d, speed: s, remaining: t} = r)do
    %Reindeer{r | distance: d+s, remaining: t-1}
  end
  defp tick_one_second(%Reindeer{mode: :rest, remaining: t, fly_time: new_t} = r) when t == 1 do
    %Reindeer{r | mode: :fly, remaining: new_t}
  end
  defp tick_one_second(%Reindeer{mode: :rest, remaining: t} = r) do
    %Reindeer{r | remaining: t-1}
  end

  defp max_distance(reindeers) do
    reindeers
      |> Enum.reduce(0, fn (%Reindeer{distance: d}, acc) -> 
        if d > acc, do: d,
        else: acc  
      end)
  end

  defp max_points(reindeers) do
    reindeers
      |> Enum.reduce(0, fn (%Reindeer{points: p}, acc) -> 
        if p > acc, do: p,
        else: acc  
      end)
  end
  
  defp assign_point_to_leader(reindeers) do
    leader_distance = reindeers |> max_distance
    reindeers
      |> Enum.map(fn (%Reindeer{distance: d, points: p} = r) ->
            if d == leader_distance, do: %Reindeer{r | points: p+1},
            else: r
         end)
  end

end

Reindeer.run("input", 2503)