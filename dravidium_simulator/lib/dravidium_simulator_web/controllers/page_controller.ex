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
    render conn, "transactions.html",
      day_data: ElixirCharts.CryptoCompare.get_day_hist(),
      day_data_120: ElixirCharts.CryptoCompare.get_day_hist120(),
      day_data_30: ElixirCharts.CryptoCompare.get_day_hist30()
  end

  def mining(conn, _params) do
    import Ecto.Query
    query = from(data in DravidiumSimulatorWeb.Mining, select: %{miner: data.miner, num_of_coins: type(data.num_of_coins, :integer), time_taken: type(data.time_taken, :float)})
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Mining}
    IO.inspect query
    query_result = Repo.all(query)
    IO.inspect query_result
    render conn, "mining.html",
      num_coins_data: Poison.encode!([[1, 20], [2, 15], [3, 25], [4, 14], [5, 22], [6, 18]]),
      time_data: Poison.encode!([[1, 2], [2, 1], [3, 5], [4, 3], [5, 8], [6, 4]])
  end

end
