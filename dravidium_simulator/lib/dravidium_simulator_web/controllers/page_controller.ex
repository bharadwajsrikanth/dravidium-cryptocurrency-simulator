defmodule DravidiumSimulatorWeb.PageController do
  use DravidiumSimulatorWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def wallets(conn, _params) do
    render conn, "wallets.html",
      simple_data: Poison.encode!([[175, 60], [190, 80], [180, 75]]),
      timeline_data: "[
                      [\"Washington\", \"1789-04-29\", \"1797-03-03\"],
                      [\"Adams\", \"1797-03-03\", \"1801-03-03\"],
                      [\"Jefferson\", \"1801-03-03\", \"1809-03-03\"]
                    ]"
  end

  def transactions(conn, _params) do
    import Ecto.Query
    query_transactions = from(data in DravidiumSimulatorWeb.Transactions, select: %{sender: type(data.sender, :string), recepient: type(data.recepient, :string), amount: type(data.amount, :integer)})
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Transactions}
    query_result = Repo.all(query_transactions)
    transactions_data = Enum.reduce(query_result, [], fn(line,transactions_data) ->
      transactions_data ++ [[line.sender, line.amount]]
    end)
    render conn, "transactions.html",
      transaction_data: Poison.encode!(transactions_data)
      #data: Poison.encode!([[174.0, 80.0, 1], [176.5, 82.3, 2], [180.3, 73.6, 3], [167.6, 74.1, 6], [188.0, 85.9, 2]])
      # day_data: ElixirCharts.CryptoCompare.get_day_hist(),
      # day_data_120: ElixirCharts.CryptoCompare.get_day_hist120(),
      # day_data_30: ElixirCharts.CryptoCompare.get_day_hist30()
  end

  def mining(conn, _params) do
    import Ecto.Query
    query_coins = from(data in DravidiumSimulatorWeb.Mining, select: %{miner: data.miner, num_of_coins: type(data.num_of_coins, :integer)})
    query_time = from(data in DravidiumSimulatorWeb.Mining, select: %{miner: data.miner, time_taken: type(data.time_taken, :float)})
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Mining}
    query_coins_result = Repo.all(query_coins)
    query_time_result = Repo.all(query_time)
    coins_data = Enum.reduce(query_coins_result, %{}, fn(line,coins_data) ->
      coins_data = Map.update(coins_data, line.miner, 1, &(&1 + 1))
    end)
    # coins_data = Map.to_list(coins_data)
    coins_data = Enum.map(coins_data, fn {a, i} -> [a, i] end)
    time_data = Enum.reduce(query_time_result, [], fn(line,time_data) ->
      time_data ++ [[line.miner, line.time_taken]]
    end)
    render conn, "mining.html",
      # num_coins_data: Poison.encode!([[1, 20], [2, 15], [3, 25], [4, 14], [5, 22], [6, 18]]),
      num_coins_data: Poison.encode!(coins_data),
      time_data: Poison.encode!(time_data)
  end

end
