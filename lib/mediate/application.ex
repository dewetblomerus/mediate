defmodule Mediate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MediateWeb.Telemetry,
      Mediate.Repo,
      {DNSCluster,
       query: Application.get_env(:mediate, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mediate.PubSub},
      {AshAuthentication.Supervisor, otp_app: :mediate},

      # Start the Finch HTTP client for sending emails
      {Finch, name: Mediate.Finch},
      # Start a worker by calling: Mediate.Worker.start_link(arg)
      # {Mediate.Worker, arg},
      # Start to serve requests, typically the last entry
      MediateWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mediate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MediateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
