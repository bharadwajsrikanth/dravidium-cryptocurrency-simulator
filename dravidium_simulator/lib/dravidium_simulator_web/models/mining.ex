defmodule DravidiumSimulatorWeb.Mining do
  use Ecto.Schema
  use DravidiumSimulatorWeb, :model
  import Ecto.Changeset

  schema "mining" do
    field :miner, :string
    field :num_of_coins, :integer
    field :time_taken, :float

    timestamps()
  end

  def changeset(minerdata, params \\ %{}) do
    minerdata
    |> cast(params, [:miner, :num_of_coins, :time_taken])
  end

end
