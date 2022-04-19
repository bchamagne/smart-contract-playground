import Config

config :phoenix, :json_library, Jason

config :archethic_playground, ArchethicPlaygroundWeb.Endpoint,
  secret_key_base: "5mFu4p5cPMY5Ii0HvjkLfhYZYtC0JAJofu70bzmi5x3xzFIJNlXFgIY5g8YdDPMf",
  render_errors: [view: ArchethicPlaygroundWeb.ErrorView, accepts: ~w(json)],
  live_view: [
    signing_salt: "3D6jYvx3",
    layout: {ArchethicPlaygroundWeb.LayoutView, "live.html"}
  ]

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
