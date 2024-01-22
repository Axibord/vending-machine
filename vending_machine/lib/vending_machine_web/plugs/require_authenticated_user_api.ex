defmodule VendingMachineWeb.Plugs.RequireAuthenticatedUserApi do
  import Plug.Conn
  alias VendingMachineWeb.UserAuth

  def init(options), do: options

  def call(conn, _opts) do
    # 1 - get the token from the request headers
    # 2 - check if the token is valid and get the user
    # 3 - if the token is valid, continue
    # 4 - if the token is invalid, return 401 unauthorized

    conn
    |> get_req_header("Authorization")
    |> UserAuth.check_token_validity()
    |> case do
      {:ok, user} ->
        assign(conn, :current_user, user)

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> halt()
    end
  end
end
