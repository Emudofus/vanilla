defmodule Vanilla.Crypto do
  use Bitwise

  @alphabet "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
  @alphabet_len String.length(@alphabet)

  defp to_alphabet(i), do: String.at(@alphabet, i)

  defp from_alphabet(_, <<>>, _), do: :not_found
  defp from_alphabet(c, << c :: utf8, _rest :: binary >>, i), do: i
  defp from_alphabet(c, << _other :: utf8, rest :: binary >>, i), do: from_alphabet(c, rest, i + 1)
  defp from_alphabet(c), do: from_alphabet(c, @alphabet, 0)

  @doc "Generate a random ticket"
  def rand_ticket(0), do: <<>>

  def rand_ticket(len \\ 32) do
    i = ?a + :random.uniform(26) - 1
    tail = rand_ticket(len - 1)
    << i :: utf8, tail :: binary >>
  end

  @doc "Decrypt a Dofus encrypted password"
  def decrypt(<<>>, _key), do: <<>>

  def decrypt(
      << a :: utf8, b :: utf8, rest :: binary >>,
      << pkey :: utf8, key :: binary >>) do
    ## doesnt work well with other than ?a..?z

    apass = case (from_alphabet(a) - pkey + @alphabet_len) do
      i when i < 0 -> (i + 64)
      i -> i
    end <<< 4

    akey = case (from_alphabet(b) - pkey + @alphabet_len) do
      i when i < 0 -> (i + 64)
      i -> i
    end

    ppass = apass + akey

    tail = decrypt(rest, key)
    << ppass :: utf8, tail :: binary >>
  end

  @doc "Dofus encrypt a password"
  def encrypt(<<>>, _key), do: <<>>

  def encrypt(
    << ppass :: utf8, rest :: binary >>,
    << pkey  :: utf8, key  :: binary >>) do
    
    anb  = ((ppass >>> 4) + pkey) |> rem(@alphabet_len) |> to_alphabet
    anb2 = (rem(ppass, 16)  + pkey) |> rem(@alphabet_len) |> to_alphabet

    anb <> anb2 <> encrypt(rest, key)
  end

  @doc "Compute the hash of a password"
  def hash(password) do
    password
  end

end
