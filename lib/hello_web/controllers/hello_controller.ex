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
    render(conn, "show.html", messenger: messenger)
  end
end
