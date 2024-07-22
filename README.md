# Ueberauth WorkOS Authkit

Implementation of an Ueberauth Strategy for WorkOS Single Sign-On with managed users.

## Installation

Add `ueberauth_workos_authkit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ueberauth_workos_authkit, "~> 0.1.0"}
  ]
end
```

## Configuration

 This provider uses the WorkOS library, which requires API keys to be
  [configured](https://github.com/workos/workos-elixir?tab=readme-ov-file#configuration) for that libary directly.

### Example

``` elixir
config :ueberauth, Ueberauth,
  providers: [
    workos: {Ueberauth.Strategy.WorkOS.AuthKit, []}
]

config :workos, WorkOS.Client,
  api_key: "sk_example_123456789",
  client_id: "client_123456789"
```
