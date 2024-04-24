defmodule Newsleezer.Repo do
  use Ecto.Repo,
    otp_app: :newsleezer,
    adapter: Ecto.Adapters.Postgres
end
