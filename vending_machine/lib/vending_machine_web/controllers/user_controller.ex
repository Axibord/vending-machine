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

  # TODO: after login, fetch user session, if it is expired, renew it in place (DB and resp cookie level)
  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    user = Accounts.login_user(%{email: email, password: password})

    case user do
      {:ok, user} ->
        conn
        |> put_status(200)
        |> UserAuth.generate_token_and_put_in_session(user)
        |> render(:show, user: user)

      {:error, reason} ->
        conn
        |> UserAuth.remove_token_from_cookies()
        |> put_status(401)
        |> render(:login_error, reason: reason)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> UserAuth.generate_token_and_put_in_session(user)
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
