defmodule VendingMachineWeb.ProductControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.ProductsFixtures
  import VendingMachine.AccountsFixtures

  alias VendingMachine.Products.Product

  setup %{conn: conn} do
    user = user_fixture()

    products_to_create = [
      %{
        "product" => %{
          "amount_available" => 3,
          "cost" => 10,
          "product_name" => "Coca Cola",
          "seller_id" => user.id
        }
      },
      %{
        "product" => %{
          "amount_available" => 5_000_000,
          "cost" => 20,
          "product_name" => "Pepsi",
          "seller_id" => user.id
        }
      }
    ]

    conn =
      conn
      |> post(~p"/api/users/login", %{
        "user" => %{
          "email" => user.email,
          "password" => valid_user_password()
        }
      })

    # Create products
    created_products =
      Enum.map(products_to_create, fn product_attrs ->
        post(conn, ~p"/api/products", product_attrs)
        |> json_response(201)
        |> Map.get("product")
      end)

    %{conn: conn, user: user, products: created_products}
  end

  describe "POST /api/products/buy" do
    test "buy an amount of a product higher than currently available", %{
      conn: conn,
      user: _user,
      products: products
    } do
      product_id = hd(products)["id"]

      conn =
        post(conn, ~p"/api/products/buy", %{
          "products" => [
            %{
              "product_id" => product_id,
              "amount" => 1_000_000
            }
          ]
        })

      err_msg = "not enough amount available for product with id #{product_id}"

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "amount" => [
                   err_msg
                 ]
               }
             }
    end

    test "buy with a valid amount of products currently available but not enough deposit", %{
      conn: conn,
      user: _user,
      products: products
    } do
      # get the second element of the list of products
      [_, product] = products
      product_id = product["id"]

      conn =
        post(conn, ~p"/api/products/buy", %{
          "products" => [
            %{
              "product_id" => product_id,
              "amount" => 1_000_000
            }
          ]
        })

      err_msg = "not enough deposit"

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "deposit" => [
                   err_msg
                 ]
               }
             }
    end

    test "buy with a valid amount of products currently available and enough deposit", %{
      conn: conn,
      user: _user,
      products: products
    } do
      products_params =
        Enum.map(products, fn product ->
          %{
            "product_id" => product["id"],
            "amount" => 2
          }
        end)

      conn = post(conn, ~p"/api/products/buy", %{"products" => products_params})

      assert json_response(conn, 200) == %{
               "products" => %{
                 "change" => 40,
                 "products" => [
                   %{"amount" => 2, "product_id" => hd(products)["id"]},
                   %{"amount" => 2, "product_id" => hd(tl(products))["id"]}
                 ],
                 "total_cost" => 60
               }
             }
    end
  end

  describe "index" do
    test "lists all products", %{conn: conn, products: products} do
      conn = get(conn, ~p"/api/products")

      assert json_response(conn, 200) == %{
               "products" => [
                 %{
                   "amount_available" => 3,
                   "cost" => 10,
                   "id" => hd(products)["id"],
                   "product_name" => "Coca Cola",
                   "seller_id" => hd(products)["seller_id"]
                 },
                 %{
                   "amount_available" => 5_000_000,
                   "cost" => 20,
                   "id" => hd(tl(products))["id"],
                   "product_name" => "Pepsi",
                   "seller_id" => hd(tl(products))["seller_id"]
                 }
               ]
             }
    end
  end

  describe "POST /api/products" do
    test "create a valid product", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/products", %{
          "product" => %{
            "amount_available" => 42,
            "cost" => 42,
            "product_name" => "some product_name",
            "seller_id" => user.id
          }
        })

      assert json_response(conn, 201)
    end
  end

  describe "PATCH /api/products/:id" do
    test "renders product when data is valid", %{conn: conn, products: products} do
      conn =
        patch(conn, ~p"/api/products/#{hd(products)["id"]}", %{
          "product" => %{
            "amount_available" => 43,
            "cost" => 43,
            "product_name" => "some updated product_name"
          }
        })

      assert json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, products: products} do
      conn =
        patch(conn, ~p"/api/products/#{hd(products)["id"]}", %{
          "product" => %{
            "amount_available" => nil,
            "cost" => nil,
            "product_name" => nil
          }
        })

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "amount_available" => ["can't be blank"],
                 "cost" => ["can't be blank"],
                 "product_name" => ["can't be blank"]
               }
             }
    end
  end

  describe "delete product" do
    test "deletes chosen product", %{conn: conn, products: products} do
      conn =
        delete(conn, ~p"/api/products/#{hd(products)["id"]}")

      assert conn.status == 204
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end
end
