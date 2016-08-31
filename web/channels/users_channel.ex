defmodule PhoenixWebrtc.UsersChannel do
  use PhoenixWebrtc.Web, :channel

  alias PhoenixWebrtc.Presence

  def join("users:lobby", _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{})

    chat_with = socket
                |> Presence.list()
                |> Enum.find(fn({key, _val}) -> key != socket.assigns.user_id end)

    if chat_with do
      {user_id, _} = chat_with
      broadcast socket, "chat_start", %{room: "call:#{socket.assigns.user_id},#{user_id}",
                                        users: [socket.assigns.user_id, user_id],
                                        initiator: socket.assigns.user_id
                                       }
    end

    {:noreply, socket}
  end
end
