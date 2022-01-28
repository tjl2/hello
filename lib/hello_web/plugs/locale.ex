# Module plugs are another type of plug that let us define a connection
# transformation in a module. The module only needs to implement two functions:
#
# init/1 which initializes any arguments or options to be passed to call/2
# call/2 which carries out the connection transformation. call/2 is just a
# function plug that we saw earlier
#
# To see this in action, let's write a module
# plug that puts the :locale key and value into the connection assign for
# downstream use in other plugs, controller actions, and our views. Remember
# that assigns are avalable in templates as @variables - so we will have access
# to @locale.
defmodule HelloWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "fr", "de"]

  # In the init/1 callback, we pass a default locale to use if none is present
  # in the params.
  def init(default), do: default

  # We also use pattern matching to define multiple call/2
  # function heads to validate the locale in the params, and fall back to "en"
  # if there is no match. The assign/3 is a part of the Plug.Conn module and
  # it's how we store values in the conn data structure.
  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    assign(conn, :locale, default)
  end
end
