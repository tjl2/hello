defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # If the body of the action needs access to the full map of parameters bound
  # to the params variable, in addition to the bound messenger variable, we
  # could define show/2 like this:
  # def show(conn, %{"messenger" => messenger} = params) do ...
  def show(conn, %{"messenger" => messenger}) do
    # text(conn, "From messenger #{messenger}")
    # json(conn, %{id: messenger})
    # Note that assigns can be added to the conn seperately then we could call
    # render/2 instead of render/3:
    #  conn
    #  |> Plug.Conn.assign(:messenger, messenger)
    #  |> render("show.html")
    render(conn, "show.html", messenger: messenger)
  end
end
