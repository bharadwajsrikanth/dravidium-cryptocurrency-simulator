defmodule Util do

    def proofOfWork(block_transactions, previous_hash, leading_zero, nonce) do
        hash=getHash(block_transactions, previous_hash, nonce)
        isValid=String.slice(hash,0..leading_zero-1) |> check ;
        {nonce, hash} = if isValid do
            {nonce, hash}
        else
            proofOfWork(block_transactions, previous_hash, leading_zero, nonce+1)
        end
    end

    def getHash(block_transactions, previous_hash, nonce) do
        transaction_string = Enum.reduce(block_transactions, "", fn(transaction, transaction_string) ->
            transaction_string<>to_string(transaction.transaction_id)
        end)
        transaction_string = transaction_string<>to_string(previous_hash)<>to_string(nonce)
        hash=:crypto.hash(:sha256,transaction_string) |> Base.encode16
    end

    def check(leadinghash) do
        Enum.all?(String.graphemes(leadinghash),fn(x) -> x=="0" end);
    end

    def validate_block(block) do
        hash = getHash(block.transaction_list, block.previous_block_hash, block.nonce)
        hash == block.my_hash
    end

    def compute_hash(input_string) do
        :crypto.hash(:sha256,input_string) |> Base.encode16
    end

    def get_epoch_time() do
        :os.system_time(:millisecond)
    end

    def get_valid_transactions(transactions) do
        final_transactions = Enum.reduce(transactions, [], fn(transaction, final_transactions) ->
            isValid = Transaction.validate_transaction(transaction)
            final_transactions = if isValid do
                [transaction | final_transactions]
            else
                final_transactions
            end
        end)
    end

    def update_wallets(transactions) do
        updated_transactions =  Enum.reduce(transactions, [], fn(transaction, updated_transactions)->
            {_, changed_transaction} = Transaction.complete_transaction(transaction)
            [changed_transaction | updated_transactions]
        end)
        Enum.reverse(updated_transactions)
    end

    def display_blockchain_hash(blockchain) do
        reverse_blockchain = Enum.reverse(blockchain)
        len = length(reverse_blockchain)
        reverse_blockchain = List.to_tuple(reverse_blockchain)
        Enum.each((0..len-1), fn(idx) ->
            IO.puts "Block #{idx+1}"
            block = Kernel.elem(reverse_blockchain, idx)
            IO.puts "Previous Block Hash: #{block.previous_block_hash}"
            IO.puts "Current Block Hash : #{block.my_hash}"
            result = validate_block(block)
            msg1 = "Validate Block Hash: #{getHash(block.transaction_list, block.previous_block_hash, block.nonce)}"
            msg2 = "Verified : #{result}"
            if !result do
                IO.puts IO.ANSI.format([:red, msg1])
                IO.puts IO.ANSI.format([:red, msg2])
            else
                IO.puts msg1
                IO.puts msg2
            end
            IO.puts IO.ANSI.underline()
            IO.puts "                                                                                     "
            IO.puts IO.ANSI.no_underline()
            if(idx != len-1) do
                IO.puts "\t\t\t||"
            end
        end)
    end

    def remove_double_spending(blockchain1, blockchain2) do
        chain = if (length(blockchain1) > length(blockchain2)) do
            blockchain1
        else
            blockchain2
        end
    end

end
