defmodule DravidiumSimulatorWeb.Wallet do
  use Ecto.Schema
  use DravidiumSimulatorWeb, :model
  import Ecto.Changeset

  schema "wallets" do
    field :miner_id, :string
    field :amount, :decimal

    timestamps()
  end

  def changeset(wallet, params \\ %{}) do
    wallet
    |> cast(params, [:miner_id, :amount])
  end

end
