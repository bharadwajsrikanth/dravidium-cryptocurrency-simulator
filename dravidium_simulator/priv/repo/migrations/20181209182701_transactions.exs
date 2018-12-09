defmodule DravidiumSimulator.Repo.Migrations.Transactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :transaction_id, :text, primary_key: true
      add :amount, :decimal
      add :recepient, :text
      add :sender, :text
      add :timestamp, :timestamp
      add :digital_signature, :text
      add :completed, :boolean

      timestamps()
    end
  end
end
