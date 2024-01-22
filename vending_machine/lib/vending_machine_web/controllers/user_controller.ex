defmodule VendingMachineWeb.UserController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Accounts
  alias VendingMachine.Accounts.User
  alias VendingMachineWeb.UserAuth

  action_fallback VendingMachineWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def login(_conn, %{"user" => user_params}) do
    user = Accounts.get_user_by_email(user_params["email"])
    UserAuth.log_in_user(user, user_params)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def create(_conn, invalid_params) do
    changeset = Accounts.create_user(invalid_params)

    {:error, changeset}
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
