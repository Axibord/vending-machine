defmodule VendingMachine.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias VendingMachine.Accounts
  alias VendingMachine.Products
  alias VendingMachine.Repo

  alias VendingMachine.Products.Product
  alias VendingMachine.Products.BuyProduct

  def buy_products(user, products) when is_list(products) do
    changesets = validate_purchase_products(products)

    case Enum.any?(changesets, fn changeset -> changeset.valid? == false end) do
      true ->
        {:error, changesets}

      false ->
        products_details =
          Repo.all(
            from p in Product,
              where: p.id in ^Enum.map(products, fn p -> p["product_id"] end)
          )

        products_with_total_cost_given_amount =
          Enum.reduce(products_details, [], fn product, acc ->
            matching_product = Enum.find(products, fn p -> p["product_id"] == product.id end)

            if matching_product do
              amount = matching_product["amount"]
              amount_valid = product.amount_available >= amount
              total_cost = product.cost * amount

              acc ++
                [
                  %{
                    product_id: product.id,
                    amount_valid?: amount_valid,
                    total_cost: total_cost
                  }
                ]
            else
              acc
            end
          end)

        if Enum.any?(products_with_total_cost_given_amount, fn product ->
             product.amount_valid? == false
           end) do
          product_id =
            Enum.find(products_with_total_cost_given_amount, 0, fn p ->
              p.amount_valid? == false
            end).product_id

          {:error,
           Ecto.Changeset.change(%BuyProduct{}, %{})
           |> Ecto.Changeset.add_error(
             :amount,
             "not enough amount available for product with id #{product_id}"
           )}
        else
          # check if we have enough deposit to buy the products
          total_cost =
            Enum.reduce(products_with_total_cost_given_amount, 0, fn product, acc ->
              acc + product.total_cost
            end)

          if user.deposit >= total_cost do
            Accounts.User.update_deposit_changeset(user, %{deposit: user.deposit - total_cost})
            |> Repo.update()

            # update the amount_available of the products
            Enum.each(products_details, fn product ->
              inc_product_amount =
                Enum.find(products, 0, fn p -> p["product_id"] == product.id end)[
                  "amount"
                ]

              Products.change_product(product, %{
                amount_available: product.amount_available - inc_product_amount
              })
              |> Repo.update()
            end)

            {:ok, products}
          else
            {:error,
             Ecto.Changeset.change(%BuyProduct{}, %{})
             |> Ecto.Changeset.add_error(:deposit, "not enough deposit")}
          end
        end
    end
  end

  def buy_products(_user, invalid_products) do
    changeset = BuyProduct.buy_product_changeset(%BuyProduct{}, invalid_products)
    {:error, changeset}
  end

  defp validate_purchase_products(products) when is_list(products) do
    Enum.map(products, fn product ->
      BuyProduct.buy_product_changeset(%BuyProduct{}, product)
    end)
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id) |> Repo.preload(:user)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    # create the product and preload the user when we return it in the response
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
