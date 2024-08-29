# Ueberauth WorkOS Authkit

> **Note:** this an experimental SDK and breaking changes may occur. We don't recommend using this in production since we can't guarantee its stability.

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

## SDK Versioning

For our SDKs WorkOS follows a Semantic Versioning process where all releases will have a version X.Y.Z (like 1.0.0) pattern wherein Z would be a bug fix (I.e. 1.0.1), Y would be a minor release (1.1.0) and X would be a major release (2.0.0). We permit any breaking changes to only be released in major versions and strongly recommend reading changelogs before making any major version upgrades.

## More Information

- [User Management Guide](https://workos.com/docs/user-management)
- [Single Sign-On Guide](https://workos.com/docs/sso/guide)
- [Directory Sync Guide](https://workos.com/docs/directory-sync/guide)
- [Admin Portal Guide](https://workos.com/docs/admin-portal/guide)
- [Magic Link Guide](https://workos.com/docs/magic-link/guide)
- [Domain Verification Guide](https://workos.com/docs/domain-verification/guide)
