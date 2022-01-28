defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def index(conn, _params) do
    conn
    |> put_root_layout("admin.html")
    |> render("index.html")
  end
end
