defmodule AdventCoins do

  def find_hash_with_zeros(secret, num_zeros) do
    [{_,index}] = Stream.iterate(1, &(&1 + 1))
      |> Stream.map(&(md5(&1, secret)))
      |> Stream.filter(&(starts_with_zeros?(&1, num_zeros)))
      |> Enum.take(1)
    index
  end

  defp md5(i, secret) do
    hash = secret <> Integer.to_string(i) |> _md5
    {hash, i}
  end
  defp _md5(s), do: :crypto.hash(:md5, s) |> Base.encode16()

  defp starts_with_zeros?({hash,_}, num_zeros) do
    String.starts_with?(hash, String.duplicate("0", num_zeros))
  end
end

secret = "bgvyzdsv"
IO.puts "First hash with 5 zeros: #{AdventCoins.find_hash_with_zeros(secret, 5)}"
IO.puts "First hash with 6 zeros: #{AdventCoins.find_hash_with_zeros(secret, 6)}"