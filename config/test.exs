import Config

config :ueberauth, Ueberauth,
  providers: [
    workos: {Ueberauth.Strategy.WorkOS.AuthKit, []}
  ]

config :workos, WorkOS.Client,
  api_key: "fake_api_key",
  client_id: "fake_client_id"
