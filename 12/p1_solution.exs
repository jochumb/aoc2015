{:ok, file} = File.open("input", [:read])
IO.stream(file, :line)
    |> Enum.map(&String.rstrip/1)
    |> List.first
    |> (fn (x) -> Regex.scan(~r/-?\d+/, x) end).()
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(0, &(&1 + &2))
    |> IO.puts