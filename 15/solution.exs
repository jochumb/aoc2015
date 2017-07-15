defmodule Ingredient do
  
  @properties [:capacity, :durability, :flavor, :texture]

  defstruct [:name, :spoons, :calories] ++ @properties
  
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read])
    lines = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.map(&to_struct/1)
    File.close(file)
    lines
  end

  defp to_struct({name, _, capacity, _, durability, _, flavor, _, texture, _, calories}) do
    name = String.strip(name, ?:)
    capacity = strip_int(capacity)
    durability = strip_int(durability)
    flavor = strip_int(flavor)
    texture = strip_int(texture)
    calories = strip_int(calories)
    %Ingredient{name: name, spoons: 0, capacity: capacity, durability: durability, flavor: flavor, texture: texture, calories: calories} 
  end

  defp strip_int(str), do: String.strip(str, ?,) |> String.to_integer

  def best_distribution(ingredients) do
    distributions = buckets_and_balls(Enum.count(ingredients), 100)
     _best_distribution(distributions, ingredients, 0, 0)
  end

  defp _best_distribution([], _, val, val_500), do: {val, val_500}
  defp _best_distribution([dist|t], ingredients, val, val_500) do
    current = 0..Enum.count(ingredients)-1
      |> Enum.map(&(update_spoons_for_ingredient(&1, ingredients, dist)))
    current_val = calculate current
    val_500 = if has_500_cals?(current) and current_val > val_500, do: current_val, else: val_500
    if current_val > val do
      _best_distribution(t, ingredients, current_val, val_500)
    else
      _best_distribution(t, ingredients, val, val_500)
    end
  end

  defp update_spoons_for_ingredient(index, ingredients, dists) do
    %{Enum.at(ingredients, index) | spoons: Enum.at(dists, index) }
  end
  
  def buckets_and_balls(0, _), do: [[]]
  def buckets_and_balls(buckets, balls) do
    for x <- 0..balls,
        y <- buckets_and_balls(buckets-1, balls-x),
        x + Enum.sum(y) == balls,
        do: [x|y]
  end

  def calculate(ingredients) do
    @properties
      |> Enum.map(&(total_value_for_property(&1,ingredients)))
      |> Enum.reduce(1, fn(x, acc) -> acc*x end)
  end

  defp total_value_for_property(property, ingredients) do
    ingredients
      |> Enum.reduce(0, fn (map, acc) -> accumulate_for_property(map, acc, property) end)
      |> (fn (sum) -> if sum < 0, do: 0, else: sum end).()
  end

  defp accumulate_for_property(map, acc, property) do
    Map.get(map, property) * Map.get(map, :spoons) + acc
  end

  defp has_500_cals?(ingredients) do
    total_value_for_property(:calories,ingredients) == 500
  end
end

{part1, part2} = Ingredient.parse("input") 
  |> Ingredient.best_distribution

IO.puts "Part 1, best distribution score: #{part1}"
IO.puts "Part 2, best 500 cal. score: #{part2}"