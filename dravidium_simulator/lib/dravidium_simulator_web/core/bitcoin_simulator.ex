defmodule BitcoinSimulator do

  def runner() do
    Application.put_env(:elixir, :ansi_enabled, true)
    miners_list = create_miners(10)
    forever_mine(miners_list)
  end

  def forever_mine(miners_list) do
    transactions = create_transactions(miners_list)
    pending_transactions = Util.get_valid_transactions(transactions)
    Enum.each(miners_list, fn(miner) ->
      spawn(__MODULE__, :parallel_mine, [self(), miner, pending_transactions])
    end)
    receive do
      {_, newBlock, winner_pid} ->
        IO.inspect winner_pid
    end
    forever_mine(miners_list)
  end

  def parallel_mine(parent, miner, pending_transactions) do
    newBlock = Miner.start_mining(miner, pending_transactions, 4)
    send parent, {self(), newBlock, miner}
  end

  def create_miners(num_miners) do
    create_keys_directory()
    Enum.reduce((1..num_miners), [], fn(_, network_miners) ->
      {:ok, pid} = Miner.start_link()
      [pid | network_miners]
    end)
  end

  def create_transactions(miners_list) do
    Enum.reduce((1..5), [], fn(_, transactions) ->
      transaction = perform_random_transaction(miners_list)
      [transaction | transactions]
    end)
  end

  def create_keys_directory do
    dir_path = "keys"
    File.rm_rf(dir_path)
    File.mkdir(dir_path)
    File.cd dir_path
  end

  def perform_random_transaction(miners_list) do
    [sender, receiver] = Enum.take_random(miners_list, 2)
    random_amount = :rand.uniform(Kernel.min(10, Miner.get_bitcoins(sender)))
    Miner.initiate_transaction(sender, receiver, random_amount)
  end

  def broadcast_block(network_miners, block) do
    Enum.each(network_miners, fn(miner) -> Miner.add_newBlock(miner, block) end)
  end

end
