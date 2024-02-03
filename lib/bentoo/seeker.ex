defmodule Bentoo.Seeker do
  alias Bentoo.Seeker.URL

  def change_url(%URL{} = url, attrs \\ %{}) do
    URL.changeset(url, attrs)
  end
end
