defmodule Vanilla.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE users(
      id              serial       primary key,
      username        varchar(255) not null,
      password        varchar(255) not null,
      nickname        varchar(255) not null,
      community       integer      not null,
      secret_question varchar(255) not null,
      secret_answer   varchar(255) not null,
      rank            integer      not null
    );
    """
  end

  def down do
    """
    DROP TABLE users;
    """
  end
end
