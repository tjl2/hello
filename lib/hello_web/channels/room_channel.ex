# For our chat app, we'll allow anyone to join the "room:lobby" topic, but any
# other room will be considered private and special authorization, say from a
# database, will be required. (We won't worry about private chat rooms for this
# exercise, but feel free to explore after we finish.)
defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel
  alias HelloWeb.Presence

  # Create the channel that we'll communicate presence over. After a user joins
  # we can push the list of presences down the channel and then track the
  # connection. We can also provide a map of additional information to track.
  def join("room:lobby", %{"name" => name}, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :name, name)}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.name, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
