defmodule HelloWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_hello_key",
    signing_salt: "CMJGQKyX"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  socket "/socket", HelloWeb.UserSocket, websocket: true, longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest when deploying
  # your static files in production.
  # Plug.Static - serves static assets. Since this plug comes before the logger,
  # requests for static assets are not logged.
  plug Plug.Static,
    at: "/",
    from: :hello,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the :code_reloader
  # configuration of your endpoint.
  #
  # This block is only executed in development. It enables:
  #
  # - live reloading - if you change a CSS file, they are updated in-browser
  #   without refreshing the page;
  # - code reloading - so we can see changes to our application without
  #   restarting the server;
  # - check repo status - which makes sure our database is up to date, raising a
  #   readable and actionable error otherwise.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :hello
  end

  # Phoenix.LiveDashboard.RequestLogger - sets up the Request Logger for Phoenix
  # LiveDashboard, this will allow you to have the option to either pass a query
  # parameter to stream requests logs or to enable/disable a cookie that streams
  # requests logs from your dashboard.
  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  # Plug.RequestId - generates a unique request ID for each request.
  plug Plug.RequestId

  # Plug.Telemetry - adds instrumentation points so Phoenix can log the request
  # path, status code and request time by default.
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Plug.Parsers - parses the request body when a known parser is available. By
  # default, this plug can handle URL-encoded, multipart and JSON content (with
  # Jason). The request body is left untouched if the request content-type
  # cannot be parsed.
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # Plug.MethodOverride - converts the request method to PUT, PATCH or DELETE
  # for POST requests with a valid _method parameter.
  plug Plug.MethodOverride

  # Plug.Head - converts HEAD requests to GET requests and strips the response
  # body.
  plug Plug.Head

  # Plug.Session - a plug that sets up session management. Note that
  # fetch_session/2 must still be explicitly called before using the session as
  # this plug just sets up how the session is fetched. By default, this is done
  # by the `plug :fetch_session` in router.ex
  plug Plug.Session, @session_options
  plug :introspect
  plug HelloWeb.Router

  def introspect(conn, _opts) do
    IO.puts """
    Verb: #{inspect(conn.method)}
    Host: #{inspect(conn.host)}
    Headers: #{inspect(conn.req_headers)}
    """

    conn
  end
end
