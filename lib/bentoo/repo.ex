defmodule Bentoo.Repo do
  use Ecto.Repo,
    otp_app: :bentoo,
    adapter: Ecto.Adapters.Postgres
end
