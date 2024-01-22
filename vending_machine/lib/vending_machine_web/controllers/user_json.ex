defmodule VendingMachineWeb.UserJSON do
  alias VendingMachine.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{users: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  def unauthorized(_msg) do
    %{errors: %{detail: "Unauthorized"}}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      role: user.role,
      deposit: user.deposit,
      email: user.email
    }
  end
end
