defmodule Miner do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def get_bitcoins(pid) do
    GenServer.call(pid, :get_bitcoins, :infinity)
  end

  def get_public_key(pid) do
    GenServer.call(pid, :get_public_key)
  end

  def deposit_bitcoins_to_wallet(pid, amount) do
    GenServer.call(pid, {:deposit_bitcoins_to_wallet, amount})
  end

  def withdraw_bitcoins_from_wallet(pid, amount) do
    GenServer.call(pid, {:withdraw_bitcoins_from_wallet, amount})
  end

  def get_blockchain(miner) do
    GenServer.call(miner, :get_blockchain)
  end

  def start_mining(miner, unconfirmed_transactions, leading_zeros) do
    GenServer.call(miner, {:start_mining, unconfirmed_transactions, leading_zeros})
  end

  def add_newBlock(miner, block) do
    GenServer.call(miner, {:addBlock, block})
  end

  def initiate_transaction(pid, recepient_pid, amount) do
    GenServer.call(pid, {:initiate_transaction, recepient_pid, amount})
  end

  def init(args) do
    wallet = Wallet.ceate_initial_wallet()
    blockchain = []
    {:ok, [wallet, blockchain]}
  end

  def handle_call(:get_public_key, _from, minerData) do
    [wallet | _ ] = minerData
    {:reply, wallet.public_key, minerData}
  end

  def handle_call({:deposit_bitcoins_to_wallet, deposit_amount}, _from, minerData) do
    [wallet | blokchain ] = minerData
    updated_wallet = %{wallet | amount: wallet.amount + deposit_amount}
    {:reply, updated_wallet, [updated_wallet | blokchain]}
  end

  def handle_call({:withdraw_bitcoins_from_wallet, withdraw_amount}, _from, minerData) do
    [wallet | blokchain ] = minerData
    if wallet.amount < withdraw_amount do
      {:reply, {false, wallet.amount}, minerData}
    else
      updated_wallet = %{wallet | amount: wallet.amount - withdraw_amount}
      {:reply, {true, updated_wallet.amount}, [updated_wallet | blokchain]}
    end
  end

  def handle_call(:get_bitcoins, _from, minerData) do
    [wallet | _] = minerData
    {:reply, wallet.amount, minerData, :infinity}
  end

  def handle_call(:get_blockchain, _from, minerData) do
    [wallet | [blockchain]] = minerData
    {:reply, blockchain, minerData}
  end

  def handle_call({:start_mining, unconfirmed_transactions, leading_zeros}, _from, miner_state) do
    block = %Block{}
    [wallet | [blockchain]] = miner_state
    latestBlock = List.first(blockchain)
    previous_hash = if latestBlock != nil do
      latestBlock.my_hash
    else
      nil
    end
    {nonce, hash} = Util.proofOfWork(unconfirmed_transactions, previous_hash, leading_zeros, 0)
    block = %{block | previous_block_hash: previous_hash, timestamp: Util.get_epoch_time(), my_hash: hash, nonce: nonce, transaction_list: unconfirmed_transactions}
    newAmount = wallet.amount + 10
    wallet = %{wallet | amount: newAmount}
    {:reply, block, [wallet, blockchain], :infinity}
  end

  def handle_call({:addBlock, block}, _from, miner_state) do
    isValid = Util.validate_block(block)
    [wallet | [blockchain]] = miner_state
    blockchain = if isValid do
      [block | blockchain]
    else
      IO.puts IO.ANSI.format([:red, "#{Kernel.inspect(self())} informs Block Validation failed, hashes do not match!"])
      blockchain
    end
    {:reply, :ok, [wallet, blockchain]}
  end

  def handle_call({:initiate_transaction, recepient_pid, withdraw_amount}, _from, minerData) do
    [wallet | blokchain] = minerData
    cond do
      withdraw_amount < 0 ->
        {:reply, nil, minerData}
      wallet.amount < withdraw_amount ->
        {:reply, nil, minerData}
      true ->
        timestamp = Util.get_epoch_time()
        transaction_id = Util.compute_hash([Kernel.inspect(self()), Kernel.inspect(recepient_pid),
                                            Kernel.inspect(withdraw_amount), Kernel.inspect(timestamp)])
        signature = ECC.Crypto.sign(transaction_id, :sha512, wallet.private_key)
        transaction = %Transaction{transaction_id: transaction_id, amount: withdraw_amount, sender: self(),
                                  recepient: recepient_pid, timestamp: timestamp, digital_signature: signature}
        {:reply, transaction, [wallet | blokchain]}
    end
  end

end
