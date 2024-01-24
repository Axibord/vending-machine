defmodule VendingMachineWeb.Router do
  use VendingMachineWeb, :router

  import VendingMachineWeb.UserAuth
  import VendingMachineWeb.Middlewares.ProductMiddlewares, only: [restrict_to_product_owner: 2]

  import VendingMachineWeb.Middlewares.UserMiddlewares,
    only: [restrict_to_self: 2, restrict_to_buyer: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VendingMachineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", VendingMachineWeb do
    pipe_through :api

    get "/products", ProductController, :index
    get "/products/:id", ProductController, :show
    post "/users/register", UserController, :create
    post "/users/login", UserController, :login

    pipe_through [:check_token_validity]

    post "/products", ProductController, :create
  end

  scope "/api", VendingMachineWeb do
    pipe_through [:api, :check_token_validity, :restrict_to_product_owner]
    patch "/products/:id", ProductController, :update
    put "/products/:id", ProductController, :update
    delete "/products/:id", ProductController, :delete
  end

  scope "api", VendingMachineWeb do
    pipe_through [:api, :check_token_validity, :restrict_to_self, :restrict_to_buyer]
    post "/users/:id/deposit", UserController, :deposit
  end

  scope "api", VendingMachineWeb do
    pipe_through [:api, :check_token_validity, :restrict_to_self]
    get "/users/:id", UserController, :show
  end

  scope "/", VendingMachineWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vending_machine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VendingMachineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VendingMachineWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{VendingMachineWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", VendingMachineWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VendingMachineWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", VendingMachineWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{VendingMachineWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
