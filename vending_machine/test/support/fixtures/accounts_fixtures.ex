defmodule VendingMachine.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VendingMachine.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_username, do: "user#{System.unique_integer()}"
  def valid_user_password, do: "hello world!"
  def valid_deposit, do: 100
  def valid_role, do: "buyer"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      username: valid_username(),
      password: valid_user_password(),
      deposit: valid_deposit(),
      role: valid_role()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> VendingMachine.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
