defmodule DravidiumSimulatorWeb.Router do
  use DravidiumSimulatorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DravidiumSimulatorWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/wallets", PageController, :wallets
    get "/transactions", PageController, :transactions
    get "/mining", PageController, :mining
  end

  # Other scopes may use custom stacks.
  # scope "/api", DravidiumSimulatorWeb do
  #   pipe_through :api
  # end
end
