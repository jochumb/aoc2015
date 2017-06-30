{:ok, file} = File.open("input", [:read])
nice = IO.stream(file, :line)
    |> Stream.map(&String.rstrip/1)
    |> Stream.filter(&(!String.contains?(&1, ["ab", "cd", "pq", "xy"])))
    |> Stream.filter(&(String.match?(&1, ~r{(\w)\1+})))
    |> Stream.filter(
        fn s -> 
          vowels = String.replace(s, ~r{[^aeiou]+}, "")
          String.length(vowels) >= 3
        end)
    |> Enum.to_list
File.close(file)

IO.puts "Number of nice strings (1): #{Enum.count(nice)}"

{:ok, file} = File.open("input", [:read])
nice = IO.stream(file, :line)
    |> Stream.map(&String.rstrip/1)
    |> Stream.filter(&(String.match?(&1, ~r{(\w\w).*\1+})))
    |> Stream.filter(&(String.match?(&1, ~r{(\w)(\w)\1+})))
    |> Enum.to_list
File.close(file)

IO.puts "Number of nice strings (2): #{Enum.count(nice)}"