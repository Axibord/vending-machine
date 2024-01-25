defmodule VendingMachineWeb.ProductController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Products
  alias VendingMachine.Products.Product

  action_fallback VendingMachineWeb.FallbackController

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Products.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def create(_conn, invalid_params) do
    changeset = Products.change_product(%Product{}, invalid_params)

    {:error, changeset}
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end

  # will receive a list a maps with product_id and amount to buy
  def buy_products(conn, %{"products" => products}) do
    user = conn.assigns[:current_user]

    with {:ok, details} <- Products.buy_products(user, products) do
      render(conn, :buy_products, details: details)
    end
  end

  def buy_products(conn, invalid_params) do
    user = conn.assigns[:current_user]

    with {:error, changeset} <- Products.buy_products(user, invalid_params) do
      {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
