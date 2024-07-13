defmodule MediateWeb.PageControllerTest do
  use MediateWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302) =~ "redirected"
  end
end
