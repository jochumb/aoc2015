defmodule PasswordWrap do

  def increment_password(password) do
    new_pass = password 
      |> String.to_charlist 
      |> Enum.reverse 
      |> increment_charlist 
      |> Enum.reverse
      |> to_string
    if (is_valid_password?(new_pass)) do
      new_pass
    else
      increment_password(new_pass)
    end
  end

  defp increment_charlist([ ch | tail ]) when ch != ?z, do: [ ch+1 | tail ]
  defp increment_charlist([ _ch | tail ]), do: [ ?a | increment_charlist(tail) ]
  
  def is_valid_password?(password) do
    !has_invalid_chars?(password) 
        && has_three_in_a_row?(String.to_charlist(password))
        && has_two_doubles?(password)
  end

  defp has_three_in_a_row?([_c1 | [ _c2 | []]]), do: false
  defp has_three_in_a_row?([c1 | [c2 | [c3 | tail]]]) do
    if c2 == c1 + 1 && c3 == c2 + 1, do: true,
    else: has_three_in_a_row?([c2 | [c3 | tail]])
  end

  defp has_invalid_chars?(password) do
    String.contains?(password, ["i", "o", "l"])
  end

  defp has_two_doubles?(password) do
    String.match?(password, ~r/.*(\w)\1+.*(\w)\2+.*/)
  end

end

input = "vzbxkghb"

incr1 = PasswordWrap.increment_password input
incr2 = PasswordWrap.increment_password incr1

IO.puts "Part 1: #{incr1}"
IO.puts "Part 2: #{incr2}"

