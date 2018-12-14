defmodule DravidiumSimulatorWeb.PageController do
  use DravidiumSimulatorWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def wallets(conn, _params) do
    import Ecto.Query
    query_transactions = from(data in DravidiumSimulatorWeb.Wallet, select: %{amount: type(data.amount, :integer), miner_id: type(data.miner_id, :string)})
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Wallet}
    query_result = Repo.all(query_transactions)
    my_map = %{}
    my_tuple = List.to_tuple(query_result)
    my_len = length(query_result)
    my_map = Enum.reduce((1..my_len), %{}, fn(i,my_map) ->
      Map.put(my_map, Kernel.elem(my_tuple, i-1).miner_id, i)
    end)
    #IO.inspect my_map
    transactions_wallet_data = Enum.reduce(query_result, [], fn(line,transactions_wallet_data) ->
      transactions_wallet_data ++ [[my_map[line.miner_id], line.amount]]
    end)
    render conn, "wallets.html",
      simple_data: Poison.encode!([[175, 60], [190, 80], [180, 75]]),
      transaction_wallet_data: Poison.encode!(transactions_wallet_data)
  end

  def transactions(conn, _params) do
    import Ecto.Query
    query_transactions = from(data in DravidiumSimulatorWeb.Transactions, select: %{sender: type(data.sender, :string), recepient: type(data.recepient, :string), amount: type(data.amount, :integer)})
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Transactions}
    query_result = Repo.all(query_transactions)
    transactions_sender_data = Enum.reduce(query_result, [], fn(line,transactions_sender_data) ->
      transactions_sender_data ++ [[line.sender, line.amount]]
    end)
    transactions_recepient_data = Enum.reduce(query_result, [], fn(line,transactions_recepient_data) ->
      transactions_recepient_data ++ [[line.recepient, line.amount]]
    end)
    render conn, "transactions.html",
      transaction_sender_data: Poison.encode!(transactions_sender_data),
      transaction_recepient_data: Poison.encode!(transactions_recepient_data)

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
