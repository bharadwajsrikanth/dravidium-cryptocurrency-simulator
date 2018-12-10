defmodule DravidiumSimulatorWeb.Mining do
  use DravidiumSimulatorWeb, :model

  schema "mining" do
    field :miner, :string
    field :num_of_coins, :integer
    field :time_taken, :float

    timestamps()
  end

end
