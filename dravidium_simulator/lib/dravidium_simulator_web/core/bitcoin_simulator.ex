defmodule BitcoinSimulator do

  #@hk_map %{}

  def start_link() do
    #Application.put_env(:elixir, :ansi_enabled, true)
    num_miners = 20
    miners_list = create_miners(num_miners)
    Enum.each(miners_list, fn(miner) ->
      wallet_entry = %DravidiumSimulatorWeb.Wallet{miner_id: Kernel.inspect(miner), amount: Miner.get_bitcoins(miner)}
      alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Wallet}
      found = Repo.get_by(DravidiumSimulatorWeb.Wallet, miner_id: Kernel.inspect(miner))
      unless found do
        Repo.insert(wallet_entry)
      end
    end)
    #hk_tuple = List.to_tuple(miners_list)
    #@hk_map = Enum.reduce((1..num_miners), %{}, fn(i, acc) ->
    #  Map.put(acc, i, Kernel.elem(hk_tuple, i-1))
    #end)
    forever_mine(miners_list)
  end

  def forever_mine(miners_list) do
    transactions = create_transactions(miners_list)
    pending_transactions = Util.get_valid_transactions(transactions)
    Enum.each(miners_list, fn(miner) ->
      spawn(__MODULE__, :parallel_mine, [self(), miner, pending_transactions])
    end)
    receive do
      {_, newBlock, winner_pid, time} ->
        mining_entry = %DravidiumSimulatorWeb.Mining{miner: Kernel.inspect(winner_pid), block_hash_id: newBlock.my_hash, time_taken: time}
        alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Mining}
        found = Repo.get_by(DravidiumSimulatorWeb.Mining, block_hash_id: newBlock.my_hash)
        unless found do
          Repo.insert(mining_entry)
          Util.update_wallets(newBlock.transaction_list)
          Miner.deposit_bitcoins_to_wallet(winner_pid, 10)
        end
    end
    #:timer.sleep(1000);
    Enum.each(pending_transactions, fn(transaction) ->
      transaction_entry = %DravidiumSimulatorWeb.Transactions{transaction_id: Kernel.inspect(transaction.transaction_id), amount: transaction.amount, recepient: Kernel.inspect(transaction.recepient), sender: Kernel.inspect(transaction.sender)}
      alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Transactions}
      found = Repo.get_by(DravidiumSimulatorWeb.Transactions, transaction_id: Kernel.inspect(transaction.transaction_id))
      unless found do
        Repo.insert(transaction_entry)
      end
    end)
    forever_mine(miners_list)
  end

  def parallel_mine(parent, miner, pending_transactions) do
    {time, newBlock} = :timer.tc(Miner, :start_mining, [miner, pending_transactions, 4])
    time = time/1000.0
    #newBlock = Miner.start_mining(miner, pending_transactions, 4)
    send parent, {self(), newBlock, miner, time}
  end

  def create_miners(num_miners) do
    #create_keys_directory()
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

  #def hk_map() do
  #  @hk_map
  #end

end
