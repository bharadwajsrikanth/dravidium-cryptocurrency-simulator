defmodule DravidiumSimulator.Repo.Migrations.AddFieldMining do
  use Ecto.Migration

  def change do
    alter table(:mining, primary_key: false) do
      add :id, :decimal
    end
  end
end
