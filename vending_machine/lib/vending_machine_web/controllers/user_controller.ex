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

  def show(conn, %{"id" => _id}) do
    user = conn.assigns[:current_user]
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns[:current_user]

    case Accounts.update_user(user, user_params) do
      {:ok, %User{} = user} ->
        render(conn, :show, user: user)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def deposit(conn, %{"deposit" => deposit}) do
    user = conn.assigns[:current_user]

    deposit = if is_integer(deposit), do: deposit, else: String.to_integer(deposit)

    with {:ok, %User{} = user} <- Accounts.deposit(user, deposit) do
      render(conn, :show, user: user)
    end
  end

  def deposit(_conn, _invalid_params) do
    changeset = Accounts.User.deposit_changeset(%Accounts.User{}, %{})
    {:error, changeset}
  end

  def reset_deposit(conn, _params) do
    user = conn.assigns[:current_user]

    with {:ok, %User{} = user} <- Accounts.reset_deposit(user) do
      render(conn, :show, user: user)
    end
  end

  def reset_deposit(_conn, _invalid_params) do
    changeset = Accounts.User.reset_deposit_changeset(%Accounts.User{}, %{})
    {:error, changeset}
  end

  def delete(conn, %{"id" => _id}) do
    user = conn.assigns[:current_user]

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
