defmodule VendingMachineWeb.Middlewares.UserMiddlewares do
  alias VendingMachineWeb.Controllers.Helpers

  def restrict_to_self(conn, _opts) do
    user_id = conn.params["id"] |> String.to_integer()
    current_user_id = conn.assigns[:current_user].id

    if user_id == current_user_id do
      conn
    else
      Helpers.return_unauthorized_json(conn, "You can't request information about other users.")
    end

    conn
  end
end
