defmodule VendingMachineWeb.ProductJSON do
  alias VendingMachine.Products.Product
  alias VendingMachine.Accounts.User

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{posts: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      amount_available: product.amount_available,
      cost: product.cost,
      product_name: product.product_name,
      seller_id: product.seller_id,
      seller: user_to_json(product.user)
    }
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
