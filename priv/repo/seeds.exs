# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bentoo.Repo.insert!(%Bentoo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Bentoo.Catalog

products = [
  %{
    name: "Iki",
    description: "Become the richest merchant",
    unit_price: 5900,
    sku: 135_247
  },
  %{
    name: "Dune",
    description: "4x strategy",
    unit_price: 5500,
    sku: 353_146
  },
  %{
    name: "Wie is de dader",
    description: "Card game for kids",
    unit_price: 1500,
    sku: 967_891
  }
]

Enum.each(products, fn product ->
  Catalog.create_product(product)
end)
