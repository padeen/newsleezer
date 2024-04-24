defmodule Newsleezer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NewsleezerWeb.Telemetry,
      Newsleezer.Repo,
      {DNSCluster, query: Application.get_env(:newsleezer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Newsleezer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Newsleezer.Finch},
      # Start a worker by calling: Newsleezer.Worker.start_link(arg)
      # {Newsleezer.Worker, arg},
      # Start to serve requests, typically the last entry
      NewsleezerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Newsleezer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NewsleezerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
