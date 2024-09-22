defmodule Mediate.AdminChecker do
  def call(conn, _opts) do
    check_super_user(conn)
  end

  def init(opts) do
    opts
  end

  def is_super_user?(%Mediate.Accounts.User{
      email: %Ash.CiString{string: "dewetblomerus@gmail.com"},
      email_verified: true
    }) do
    true
  end

  def is_super_user?(_) do
   false
  end

  defp check_super_user(conn) do
    current_user =
      conn.assigns.current_user

    if is_super_user?(current_user) do
      conn
    else
      redirect_and_halt(conn)
    end
  end

  defp redirect_and_halt(conn) do
    conn
    |> Phoenix.Controller.redirect(to: "/")
    |> Plug.Conn.halt()
  end
end
