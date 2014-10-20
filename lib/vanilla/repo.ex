defmodule Vanilla.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, env: Mix.env

  @doc "Adapter configuration"
  def conf(env), do: parse_url url(env)

  # The URL to reach the database
  defp url(:dev) do
    "ecto://antoine:lel@localhost/vanilla_login_dev"
  end

  defp url(:test) do
    "ecto://antoine:lel@localhost/vanilla_login_test?size=1&max_overflow=0"
  end

  defp url(:prod) do
    "ecto://antoine:lel@localhost/vanilla_login_prod"
  end

  @doc "The priv directory to load migrations and metadata."
  def priv do
    app_dir(:vanilla, "priv/repo")
  end
end
