defmodule MediateWeb.Router do
  use MediateWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MediateWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  pipeline :admin do
    plug Mediate.AdminChecker
  end

  scope "/", MediateWeb do
    pipe_through :browser

    sign_in_route(register_path: "/register", reset_path: "/reset")
    sign_out_route AuthController
    auth_routes_for Mediate.Accounts.User, to: AuthController
    reset_route []

    ash_authentication_live_session :authentication_required,
      on_mount: {MediateWeb.LiveUserAuth, :live_user_required} do
      live "/", ThreadLive, :index

      scope "/:thread_id", as: :thread do
        live "/", MessageLive.Index, :index
        live "/translate", MessageLive.Index, :translate
      end

      scope "/admin" do
        pipe_through :admin

        live "/threads", AdminThreadLive.Index, :index
        live "/threads/new", AdminThreadLive.Index, :new
        live "/threads/:id/edit", AdminThreadLive.Index, :edit

        live "/threads/:id", AdminThreadLive.Show, :show
        live "/threads/:id/show/edit", AdminThreadLive.Show, :edit
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MediateWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mediate, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MediateWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
