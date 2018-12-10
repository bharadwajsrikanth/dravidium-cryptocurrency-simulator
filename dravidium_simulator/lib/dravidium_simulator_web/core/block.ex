defmodule Block do
  defstruct  previous_block_hash: nil,
             my_hash: nil,
             timestamp: nil,
             nonce: 0,
             transaction_list: []
end
