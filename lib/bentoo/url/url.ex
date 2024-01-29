defmodule Bentoo.Seeker.URL do
  defstruct [:url]
  @types %{url: :string}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = url, attrs) do
    {url, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required(:url)
    |> validate_format(:url, ~r/https?:\/\//)
  end
end
