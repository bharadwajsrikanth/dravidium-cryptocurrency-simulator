defmodule DravidiumSimulatorWeb.PageController do
  use DravidiumSimulatorWeb, :controller

  def index(conn, _params) do
    book = %DravidiumSimulatorWeb.Mining{miner: "Ender's Game"}
    #IO.inspect book
    alias DravidiumSimulator.{Repo, DravidiumSimulatorWeb.Mining}
    Repo.insert(book)
    render conn, "index.html"
  end
end
