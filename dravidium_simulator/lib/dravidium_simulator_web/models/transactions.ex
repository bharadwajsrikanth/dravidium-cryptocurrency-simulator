defmodule DravidiumSimulatorWeb.Transactions do
  use Ecto.Schema
  use DravidiumSimulatorWeb, :model
  import Ecto.Changeset

  schema "transactions" do
    field :transaction_id, :string
    field :amount, :integer
    field :recepient, :string
    field :sender, :string

    timestamps()
  end

  def changeset(transaction, params \\ %{}) do
    transaction
    |> cast(params, [:transaction_id, :amount, :recepient, :sender])
  end

end
