defmodule Vanilla.Model.UserTest do
  use ExUnit.Case
  alias Vanilla.Model.User

  test "decrypt empty password and empty key" do
    assert User.decrypt("", "") == ""
  end

  test "decrypt" do
    assert User.decrypt("ZW54a81Y", "lsynipxrmpdfseoflkaomkibpziefaxv") == "test"
  end

  test "encrypt" do
    assert User.encrypt("test", "lsynipxrmpdfseoflkaomkibpziefaxv") == "ZW54a81Y"
  end

  test "identity" do
    pass = User.rand_ticket
    key  = User.rand_ticket

    assert (pass |> User.encrypt(key) |> User.decrypt(key)) == pass
  end
end
