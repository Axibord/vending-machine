defmodule VendingMachineWeb.ProductJSON do
  alias VendingMachine.Products.Product
  alias VendingMachine.Accounts.User

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{products: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{product: data(product)}
  end

  def buy_products(%{details: details}) do
    %{products: details}
  end

  defp data(%Product{} = product) do
    user_loaded? = Ecto.assoc_loaded?(product.user)

    response = %{
      id: product.id,
      product_name: product.product_name,
      amount_available: product.amount_available,
      cost: product.cost,
      seller_id: product.seller_id
    }

    if user_loaded? do
      Map.put(response, :seller, user_to_json(product.user))
    else
      response
    end
  end

  defp user_to_json(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      role: user.role,
      deposit: user.deposit,
      email: user.email
    }
  end
end
