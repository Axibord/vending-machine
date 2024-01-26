defmodule VendingMachine.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VendingMachine.Products` context.
  """

  import VendingMachine.AccountsFixtures

  def create_user_of_type_seller do
    user_fixture(%{role: "seller"})
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    user = create_user_of_type_seller()

    {:ok, product} =
      attrs
      |> Enum.into(%{
        amount_available: 42,
        cost: 5,
        product_name: "some product_name",
        seller_id: user.id
      })
      |> VendingMachine.Products.create_product()

    product
  end
end
