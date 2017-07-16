defmodule Aunt do
  @compounds [:children, :cats, :samoyeds, :pomeranians, :akitas, :vizslas, :goldfish, :trees, :cars, :perfumes]
  defstruct [:number | @compounds]

  def parse_tape(filename) do
    {:ok, file} = File.open(filename, [:read])
    map = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&List.to_tuple/1)
        |> Enum.map(&to_compound/1)
    File.close(file)
    struct(Aunt, map)
  end

  defp to_compound({property, amount}) do
    property = String.strip(property, ?:) |> String.to_atom
    amount = String.to_integer(amount)
    {property, amount}
  end

  def parse_aunts(filename) do
    {:ok, file} = File.open(filename, [:read])
    aunts = IO.stream(file, :line)
        |> Stream.map(&String.rstrip/1)
        |> Stream.map(&(String.split(&1, " ")))
        |> Enum.map(&to_aunt/1)
    File.close(file)
    aunts
  end

  defp to_aunt(["Sue" | [num | tail]]) do
    to_aunt(tail, %Aunt{number: String.strip(num, ?:) |> String.to_integer})
  end
  defp to_aunt([], res), do: res
  defp to_aunt([compound | [count | tail]], aunt) do
    compound = String.strip(compound, ?:) |> String.to_atom
    count = String.strip(count, ?,) |> String.to_integer
    to_aunt(tail, Map.put(aunt, compound, count))
  end

  def find_aunt([aunt|tail], reference, version) do
    if is_match(aunt, reference, version) do
      Map.get(aunt, :number)
    else
      find_aunt(tail, reference, version)
    end
  end

  defp is_match(aunt, ref, :v1) do
    @compounds
      |> Enum.map(&same_or_nil(&1, aunt, ref))
      |> Enum.all?
  end

  defp is_match(aunt, ref, :v2) do
    @compounds
      |> Enum.map(&match_compound(&1, aunt, ref))
      |> Enum.all?
  end

  defp match_compound(comp, aunt, ref) when comp == :cats or comp == :trees do
    comp_aunt = Map.get(aunt, comp)
    comp_ref = Map.get(ref, comp)
    comp_aunt == nil or comp_aunt > comp_ref
  end

  defp match_compound(comp, aunt, ref) when comp == :pomeranians or comp == :goldfish do
    comp_aunt = Map.get(aunt, comp)
    comp_ref = Map.get(ref, comp)
    comp_aunt == nil or comp_aunt < comp_ref
  end

  defp match_compound(comp, aunt, ref) do
    same_or_nil(comp, aunt, ref)
  end

  defp same_or_nil(compound, aunt, ref) do
    comp_aunt = Map.get(aunt, compound)
    comp_ref = Map.get(ref, compound)
    comp_aunt == nil or comp_aunt == comp_ref
  end

end

ref = Aunt.parse_tape("tape")
aunts = Aunt.parse_aunts("sues")
IO.puts "Part 1: #{Aunt.find_aunt(aunts, ref, :v1)}"
IO.puts "Part 2: #{Aunt.find_aunt(aunts, ref, :v2)}"

