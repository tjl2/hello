# For our chat app, we'll allow anyone to join the "room:lobby" topic, but any
# other room will be considered private and special authorization, say from a
# database, will be required. (We won't worry about private chat rooms for this
# exercise, but feel free to explore after we finish.)
defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
