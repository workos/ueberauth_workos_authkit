defmodule Ueberauth.Strategy.WorkOS.AuthKitTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import Ueberauth.Strategy.Helpers

  setup_with_mocks([
    {WorkOS.UserManagement, [:passthrough],
     [
       authenticate_with_code: &workos_authenticate_with_code/1,
     ]}
  ]) do
    # Create a connection with Ueberauth's CSRF cookies so they can be recycled during tests
    routes = Ueberauth.init([])
    csrf_conn = conn(:get, "/auth/workos", %{}) |> Ueberauth.call(routes)
    csrf_state = with_state_param([], csrf_conn) |> Keyword.get(:state)

    {:ok, csrf_conn: csrf_conn, csrf_state: csrf_state}
  end

  def workos_authenticate_with_code(%{code: "oauth2_error"}) do
    {:error, %WorkOS.Error{error: "invalid_code", message: "Code has expired"}}
  end

  def workos_authenticate_with_code(_opts) do
    jwk = %{"kty" => "oct", "k" => :jose_base64url.encode("symmetric key")}
    now = DateTime.utc_now() |> DateTime.to_unix()
    jwt = %{
      "exp" => now + 300,
      "iat" => now,
      "iss" => "https://api.workos.com",
      "org_id" => "org_ORGID",
      "permissions" => ["read:data", "write:otherdata"],
      "role" => "member",
      "sid" => "session_SESSIONID",
      "sub" => "user_USERID"
    }
    {_alg, token} = JOSE.JWT.sign(jwk, jwt) |> JOSE.JWS.compact()

    auth = %WorkOS.UserManagement.Authentication{
      user: %{
        id: "user_01H5JQDV7R7ATEYZDEG0W5PRYS",
        email_verified: true,
        email: "test@example.com",
        first_name: "Test 01",
        last_name: "User",
        created_at: "2023-07-18T02:07:19.911Z",
        updated_at: "2023-07-18T02:07:19.911Z",
      },
      organization_id: "org_myfakeorg",
      access_token: token,
      refresh_token: "refreshme",
      authentication_method: "SSO",
    }
    {:ok, auth}
  end

  defp set_csrf_cookies(conn, csrf_conn) do
    conn
    |> init_test_session(%{})
    |> recycle_cookies(csrf_conn)
    |> fetch_cookies()
  end

  test "handle_request! redirects to appropriate auth uri" do
    conn = conn(:get, "/auth/workos")
    routes = Ueberauth.init()
    resp = Ueberauth.call(conn, routes)

    WorkOS.UserManagement.ClientMock
    assert resp.status == 302
    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)
    assert redirect_uri.host == "api.workos.com"
    assert redirect_uri.path == "/sso/authorize"

    assert %{
      "client_id" => "fake_client_id",
      "redirect_uri" => "http://www.example.com/auth/workos/callback",
      "response_type" => "code",
      "provider" => "authkit",
      "state" => _,
    } = Plug.Conn.Query.decode(redirect_uri.query)
  end

  test "handle_callback! assigns required fields on successful auth", %{csrf_state: csrf_state, csrf_conn: csrf_conn} do
    conn =
      conn(:get, "/auth/workos/callback", %{code: "success_code", state: csrf_state}) |> set_csrf_cookies(csrf_conn)

    routes = Ueberauth.init([])
    assert %Plug.Conn{assigns: %{ueberauth_auth: auth}} = Ueberauth.call(conn, routes)
    refute is_nil(auth.credentials.token)
    assert auth.extra.raw_info.organization_id == "org_myfakeorg"
    assert auth.info.name == "Test 01 User"
    assert auth.info.email == "test@example.com"
    assert auth.uid == "user_01H5JQDV7R7ATEYZDEG0W5PRYS"
  end

  describe "error handling" do
    test "handle_callback! handles Oauth2.Error", %{csrf_state: csrf_state, csrf_conn: csrf_conn} do
      conn =
        conn(:get, "/auth/workos/callback", %{code: "oauth2_error", state: csrf_state}) |> set_csrf_cookies(csrf_conn)

      routes = Ueberauth.init([])
      assert %Plug.Conn{assigns: %{ueberauth_failure: failure}} = Ueberauth.call(conn, routes)
      assert %Ueberauth.Failure{errors: [%Ueberauth.Failure.Error{message: "Code has expired", message_key: "invalid_code"}]} = failure
    end

    test "handle_callback! handles missing code", %{
      csrf_state: csrf_state,
      csrf_conn: csrf_conn
    } do
      conn =
        conn(:get, "/auth/workos/callback", %{state: csrf_state})
        |> set_csrf_cookies(csrf_conn)

      routes = Ueberauth.init([])
      assert %Plug.Conn{assigns: %{ueberauth_failure: failure}} = Ueberauth.call(conn, routes)

      assert %Ueberauth.Failure{
        errors: [%Ueberauth.Failure.Error{message: "No code received", message_key: "missing_code"}]
      } = failure
    end
  end
end
