defmodule VendingMachineWeb.UserControllerTest do
  use VendingMachineWeb.ConnCase, async: true

  import VendingMachine.AccountsFixtures

  # create a user and login with it to setup the cookie
  setup %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> post(~p"/api/users/login", %{
        "user" => %{
          "email" => user.email,
          "password" => valid_user_password()
        }
      })

    %{conn: conn, user: user}
  end

  describe "POST /api/users/deposit" do
    test "deposit valid 100 coins to the user account", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/deposit", %{"deposit" => 100})

      assert json_response(conn, 200) == %{
               "user" => %{
                 "deposit" => 100,
                 "email" => user.email,
                 "id" => user.id,
                 "role" => user.role,
                 "username" => user.username
               }
             }
    end

    test "deposit negative 100 coins to the user account", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/deposit", %{"deposit" => -100})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "deposit" => ["must be 5, 10, 20, 50 or 100"]
               }
             }
    end

    test "deposit valid 5 coins to the user account", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/deposit", %{"deposit" => 5})

      assert json_response(conn, 200) == %{
               "user" => %{
                 "deposit" => user.deposit + 5,
                 "email" => user.email,
                 "id" => user.id,
                 "role" => user.role,
                 "username" => user.username
               }
             }
    end

    test "deposit with each of [5, 10, 20, 50, 100] coins to the user account", %{
      conn: conn,
      user: user
    } do
      [5, 10, 20, 50, 100]
      |> Enum.each(fn deposit ->
        conn =
          post(conn, ~p"/api/users/deposit", %{"deposit" => deposit})

        assert json_response(conn, 200)
      end)
    end
  end
end
