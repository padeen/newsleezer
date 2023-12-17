defmodule Bentoo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BentooWeb.Telemetry,
      Bentoo.Repo,
      {DNSCluster, query: Application.get_env(:bentoo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bentoo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bentoo.Finch},
      # Start a worker by calling: Bentoo.Worker.start_link(arg)
      # {Bentoo.Worker, arg},
      # Start to serve requests, typically the last entry
      BentooWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bentoo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BentooWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
