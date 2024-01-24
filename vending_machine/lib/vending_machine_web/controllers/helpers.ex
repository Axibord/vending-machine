defmodule VendingMachineWeb.Controllers.Helpers do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Returns a JSON response with the given status and map.
  
  The map is automatically converted to JSON.
  """
  def return_json(conn, status, map) when is_integer(status) and is_map(map) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> json(map)
    |> halt()
  end

  @doc """
  Returns an unauthorized JSON response with the given message.
  """
  def return_unauthorized_json(conn, message) when is_binary(message) do
    conn
    |> return_json(401, %{error: "Unauthorized", message: message})
  end
end
