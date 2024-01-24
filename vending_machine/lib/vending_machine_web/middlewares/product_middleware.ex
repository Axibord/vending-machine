defmodule VendingMachineWeb.Middlewares.ProductMiddleware do
  alias VendingMachine.Products
  alias VendingMachineWeb.Controllers.Helpers

  def restrict_to_owner(conn, _opts) do
    product_id = conn.params["id"] |> String.to_integer()
    user_id = conn.assigns[:current_user].id

    product = Products.get_product!(product_id)

    if product.seller_id == user_id do
      conn
    else
      Helpers.return_unauthorized_json(conn, "You are not the owner of this product.")
    end

    conn
  end
end
