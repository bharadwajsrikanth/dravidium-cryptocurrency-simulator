defmodule DravidiumSimulator.Repo.Migrations.Wallets do
  use Ecto.Migration

  def change do
    create table(:wallets, primary_key: false) do
      add :wallet_id, :text, primary_key: true
      add :amount, :decimal
      add :private_key, :text
      add :public_key, :text

      timestamps
    end
  end
end
