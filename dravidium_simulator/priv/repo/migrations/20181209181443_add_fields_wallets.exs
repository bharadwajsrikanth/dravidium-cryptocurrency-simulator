defmodule DravidiumSimulator.Repo.Migrations.AddFieldsWallets do
  use Ecto.Migration

  def change do
    alter table(:wallets, primary_key: false) do
      add :user, :text
    end
  end
end
