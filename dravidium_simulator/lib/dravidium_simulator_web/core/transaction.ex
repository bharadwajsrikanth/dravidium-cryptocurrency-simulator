defmodule Transaction do
  defstruct  transaction_id: 0,
             amount: 0,
             recepient: nil,
             sender: nil,
             timestamp: nil,
             digital_signature: nil,
             completed: false

  def validate_transaction(transaction) when is_nil(transaction) do
    false
  end

  def validate_transaction(transaction) when not is_nil(transaction) do
    transaction_hash = Util.compute_hash([Kernel.inspect(transaction.sender),
                                          Kernel.inspect(transaction.recepient),
                                          Kernel.inspect(transaction.amount),
                                          Kernel.inspect(transaction.timestamp)])
    result = ECC.Crypto.verify_signature(transaction_hash, transaction.digital_signature, :sha512, Miner.get_public_key(transaction.sender))
    (Miner.get_bitcoins(transaction.sender) >= transaction.amount) and result and transaction.completed == false
  end

  def complete_transaction(transaction) do
    import Ecto.Query
    if(!transaction.completed) do
      Miner.withdraw_bitcoins_from_wallet(transaction.sender, transaction.amount)
      Miner.deposit_bitcoins_to_wallet(transaction.recepient, transaction.amount)
      new_sender_entry = %DravidiumSimulatorWeb.Wallet{miner_id: Kernel.inspect(transaction.sender), amount: Miner.get_bitcoins(transaction.sender)}
      new_recepient_entry = %DravidiumSimulatorWeb.Wallet{miner_id: Kernel.inspect(transaction.recepient), amount: Miner.get_bitcoins(transaction.recepient)}
      alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Wallet}
      sender_hk = Kernel.inspect(transaction.sender)
      recepient_hk = Kernel.inspect(transaction.recepient)
      from(p in DravidiumSimulatorWeb.Wallet, where: p.miner_id == ^sender_hk)
      |> Repo.delete_all()
      Repo.insert(new_sender_entry)

      from(p in DravidiumSimulatorWeb.Wallet, where: p.miner_id == ^recepient_hk)
      |> Repo.delete_all()
      Repo.insert(new_recepient_entry)


      #old_sender_entry = Repo.get_by(DravidiumSimulatorWeb.Wallet, miner_id: Kernel.inspect(transaction.sender))
      #from(p in DravidiumSimulatorWeb.Wallet, where: p.miner_id == Map.get(%{}, :a))
      #|> Repo.delete_all()
      # Repo.delete(miner_id: Kernel.inspect(transaction.sender)
      #book = %{ old_sender_entry | amount: Miner.get_bitcoins(transaction.sender) }
      #Repo.update(book)
      #############
      #changeset = DravidiumSimulatorWeb.Wallet.changeset(old_sender_entry, %{amount: Miner.get_bitcoins(transaction.sender)})
      #Repo.update(new_sender_entry)
      #%DravidiumSimulatorWeb.Wallet{miner_id: Kernel.inspect(transaction.sender)} |> Repo.delete
      #############
      transaction = %{transaction | completed: true}
      {true, transaction}
    else
      {false, transaction}
    end
  end

  def form_merkle_tree(transactions) do
    transactions = if(Integer.mod(length(transactions), 2) != 0) do
      [first | _] = transactions
      [first | transactions]
    else
      transactions
    end
    merkle_nodes = Enum.reduce(transactions, [], fn(trnx, merkle_nodes) ->
      [%MerkleTree{value: Util.compute_hash(trnx.transaction_id)} | merkle_nodes]
    end)
    [merkle_root] = reduce_merkle_tree_level(merkle_nodes)
    merkle_root
  end

  def reduce_merkle_tree_level(merkle_nodes) do
    len = length(merkle_nodes)
    merkle_tuple = List.to_tuple(merkle_nodes)
    if(length(merkle_nodes) > 1) do
      result_merkle_nodes = Enum.reduce((0..Kernel.trunc(len/2)-1), [], fn(idx, result_merkle_nodes) ->
        left = Kernel.elem(merkle_tuple, 2*idx)
        right = Kernel.elem(merkle_tuple, (2*idx)+1)
        concat_hash = left.value <> right.value
        Util.compute_hash(concat_hash)
        [%MerkleTree{value: Util.compute_hash(concat_hash), left: left, right: right} | result_merkle_nodes]
      end)
      result_merkle_nodes = Enum.reverse(result_merkle_nodes)
      reduce_merkle_tree_level(result_merkle_nodes)
    else
      merkle_nodes
    end
  end

end
