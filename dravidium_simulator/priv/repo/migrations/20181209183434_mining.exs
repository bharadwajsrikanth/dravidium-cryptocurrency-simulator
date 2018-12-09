defmodule DravidiumSimulator.Repo.Migrations.Mining do
  use Ecto.Migration

  def change do
    create table(:mining, primary_key: false) do
      add :miner, :text, primary_key: true
      add :num_of_coins, :decimal
      add :time_taken, :decimal

      timestamps()
    end
  end
end
