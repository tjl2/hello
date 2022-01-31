defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  # def index(conn, _params) do
  #   conn
  #   |> put_flash(:info, "Welcome to Phoenix, from flash info!")
  #   |> put_flash(:error, "Let's pretend we have an error.")
  #   |> render(:index)
  # end

  # Example to send custom response
  # def index(conn, _params) do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(201, "")
  # end

  # Notice that the redirect function takes conn as well as a string
  # representing a relative path within our application. For security reasons,
  # the :to helper can only redirect for paths within your application. If you
  # want to redirect to a fully-qualified path or an external URL, you should
  # use :external instead:
  # redirect(conn, external: "https://elixir-lang.org/")
  # def index(conn, _params) do
  #   redirect(conn, to: Routes.page_path(conn, :redirect_test))
  # end

  # def redirect_test(conn, _params) do
  #   render(conn, :index)
  # end

  def show(conn, _params) do
    page = %{title: "foo" }
    render(conn, "show.json", page: page)
  end

  def index(conn, _params) do
    pages = [%{title: "foo"}, %{title: "bar"}]
    render(conn, "index.json", pages: pages)
  end
end
