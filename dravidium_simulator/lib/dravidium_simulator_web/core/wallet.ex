defmodule Wallet do
  defstruct  wallet_id: nil,
             amount: 0,
             private_key: nil,
             public_key: nil

  def ceate_initial_wallet() do
    wallet_id = Util.get_epoch_time()
    Wallet.create_public_private_key_pair(wallet_id)
    {private_key, public_key} = Wallet.parse_keys(wallet_id)
    %Wallet{amount: 1000, wallet_id: wallet_id, private_key: private_key, public_key: public_key}
  end

  def create_public_private_key_pair(pid) do
    System.cmd "openssl", ["ecparam", "-out", "#{pid}_private_key.pem", "-name", "secp521r1", "-genkey"], [stderr_to_stdout: true]
    System.cmd "openssl", ["ec", "-in", "#{pid}_private_key.pem", "-pubout", "-out", "#{pid}_public_key.pem"], [stderr_to_stdout: true]
  end

  def parse_keys(wallet_id) do
    pem_public = File.read! "#{wallet_id}_public_key.pem"
    pem_private = File.read! "#{wallet_id}_private_key.pem"
    pem = Enum.join [pem_public, pem_private]
    private_key = ECC.Crypto.parse_private_key pem
    pem_keys = :public_key.pem_decode(pem)
    ec_params =
      Enum.find(pem_keys, fn(k) -> elem(k,0) == :EcpkParameters end)
      |> put_elem(0, :EcpkParameters)
      |> :public_key.pem_entry_decode
    pem_public =
      Enum.find(pem_keys, fn(k) -> elem(k,0) == :SubjectPublicKeyInfo end)
      |> elem(1)
    ec_point = :public_key.der_decode(:SubjectPublicKeyInfo, pem_public)
      |> elem(2)
    public_key = {{:ECPoint, ec_point}, ec_params}
    {private_key, public_key}
  end

end
