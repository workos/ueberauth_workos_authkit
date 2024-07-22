defmodule Ueberauth.Strategy.WorkOS.AuthKit do
  @moduledoc """
  Implementation of an Ueberauth Strategy for WorkOS Single Sign-On with managed users.

  ## Configuration

  This provider uses the WorkOS library, which requires API keys to be
  [configured](https://github.com/workos/workos-elixir?tab=readme-ov-file#configuration).

  ### Example configuration:

      config :ueberauth, Ueberauth,
        providers: [
          workos: {Ueberauth.Strategy.WorkOS.AuthKit, []}
      ]

      config :workos, WorkOS.Client,
        api_key: "sk_example_123456789",
        client_id: "client_123456789"
  """

  use Ueberauth.Strategy
  alias Ueberauth.Auth.{Credentials, Extra, Info}

  @impl Ueberauth.Strategy
  def uid(conn), do: conn.private[:workos_user][:id]

  @impl Ueberauth.Strategy
  def credentials(conn) do
    expiration = JOSE.JWT.peek(conn.private[:workos_token].access_token).fields["exp"]

    %Credentials{
      expires: true,
      expires_at: expiration,
      token: conn.private[:workos_token].access_token,
      token_type: "access_token"
    }
  end

  @impl Ueberauth.Strategy
  def extra(conn) do
    %Extra{raw_info: %{user: conn.private[:workos_user], organization_id: conn.private[:workos_org_id]}}
  end

  @impl Ueberauth.Strategy
  def info(conn) do
    first_name = conn.private[:workos_user][:first_name]
    last_name = conn.private[:workos_user][:last_name]

    name = cond do
      is_nil(first_name) -> nil
      is_nil(last_name) -> nil
      true -> "#{first_name} #{last_name}"
    end

    %Info{
      email: conn.private[:workos_user][:email],
      first_name: first_name,
      last_name: last_name,
      name: name,
    }
  end

  @impl Ueberauth.Strategy
  def handle_request!(conn) do
    params = %{
      provider: "authkit",
      redirect_uri: callback_url(conn),
      state: conn.private[:ueberauth_state_param],
    }

    {:ok, url} = WorkOS.UserManagement.get_authorization_url(params)
    redirect!(conn, url)
  end

  @impl Ueberauth.Strategy
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    case WorkOS.UserManagement.authenticate_with_code(%{code: code}) do
      {:ok, auth} ->
        token = OAuth2.AccessToken.new(%{"access_token" => auth.access_token, "refresh_token" => auth.refresh_token})
        conn
        |> put_private(:workos_user, auth.user)
        |> put_private(:workos_org_id, auth.organization_id)
        |> put_private(:workos_token, token)

      {:error, %WorkOS.Error{error: err, message: message}} ->
        set_errors!(conn, [error(err, message)])

      {:error, :client_error} ->
        set_errors!(conn, [error("client_error", "failed to authenticate with code")])
    end
  end

  def handle_callback!(%Plug.Conn{params: %{"error" => error}} = conn) do
    set_errors!(conn, [error("auth_failed", error)])
  end

  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @impl Ueberauth.Strategy
  def handle_cleanup!(conn) do
    conn
    |> put_private(:workos_user, nil)
    |> put_private(:workos_org_id, nil)
    |> put_private(:workos_token, nil)
  end
end
