defmodule ArchethicPlaygroundWeb.RootController do
  @moduledoc false

  use ArchethicPlaygroundWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
