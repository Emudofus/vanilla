defmodule Vanilla.Model.User do
  use Ecto.Model
  alias Vanilla.Repo
  alias Vanilla.Crypto
  import Ecto.Query, only: [from: 2]
  use Bitwise

  schema "users" do
    field :username,        :string
    field :password,        :string
    field :nickname,        :string
    field :community,       :integer
    field :secret_question, :string
    field :secret_answer,   :string
    field :rank,            :integer
  end

  def authenticate_query(username, password, key) do
    password = password |> Crypto.decrypt(key) |> Crypto.hash

    from u in __MODULE__,
      where: u.username == ^username and u.password == ^password,
      select: u
  end

  def authenticate(username, password, key) do
    [user] = authenticate_query(username, password, key) |> Repo.all
    {:ok, user}
  end
    
end
