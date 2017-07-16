defmodule AnimatedLights do
  
  @on  ?#
  @off ?.

  def run do
    coords = coords_map()
    res = loop(100, 0, coords, :v1)
    IO.inspect total_on(res, :v1)
    res = loop(100, 0, coords, :v2)
    IO.inspect total_on(res, :v2)
  end

  defp coords_map do
    {:ok, file} = File.open("input", [:read])
    map = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&line_to_map/1)
        |> Enum.map(&(Enum.into(&1, %{})))
        |> (fn (ls) -> Enum.zip(0..Enum.count(ls)-1, ls) end).()
        |> Enum.into(%{})
    File.close(file)
    map
  end

  defp line_to_map(line) do
    line
      |> to_charlist
      |> (fn (cs) -> Enum.zip(0..Enum.count(cs)-1, cs) end).()
  end

  defp loop(to, i, coords, v) when i < to do
    next = iterate(coords, coords, 0, 0, v)
    loop(to, i+1, next, v)
  end 
  defp loop(_, _, coords, _), do: coords

  defp iterate(current, next, x, y, v) do
    max = Enum.count(current)-1
    if x > max do
      next
    else
      on = neighbours(current, x, y, v)
        |> Enum.filter(fn s -> s == @on end)
        |> Enum.count
      turn_light_on_of(current, next, current[x][y], on, x, y, next(x, y, max), v)
    end
  end

  defp neighbours(map, x, y, v) do
    max = Enum.count(map)-1
    for a <- x-1..x+1,
        b <- y-1..y+1,
        a >= 0 and a <= max,
        b >= 0 and b <= max,
        !(x == a and y ==b),
        do: get_state(map, a, b, max, v)
  end

  defp turn_light_on_of(current, next, state, on, x, y, {nx, ny}, v) when state == @on do
    next = if on == 2 or on == 3 do
      next
    else
      Map.put(next, x, Map.put(Map.get(next, x), y, @off))
    end
    iterate(current, next, nx, ny, v)
  end
  defp turn_light_on_of(current, next, state, on, x, y, {nx, ny}, v) when state == @off do
    next = if on == 3 do
      Map.put(next, x, Map.put(Map.get(next, x), y, @on))
    else
      next
    end
    iterate(current, next, nx, ny, v)
  end

  defp next(x, y, max) when y < max, do: {x, y+1}
  defp next(x, _y, _max), do: {x+1, 0}

  defp total_on(coords, v) do
    max = Enum.count(coords)-1
    ons = for x <- 0..max,
              y <- 0..max,
              get_state(coords, x, y, max, v) == @on,
              do: @on
    Enum.count ons
  end

  defp get_state(_map, x, y, max, :v2) when (x == 0 or x == max) and (y == 0 or y == max), do: @on
  defp get_state(map, x, y, _max, _v), do: map[x][y]
end

AnimatedLights.run()