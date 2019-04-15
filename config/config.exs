use Mix.Config

config :mcc,
  mnesia_table_modules: [Edns.Cache]

config :edns,
  servers: [
    [name: :inet_localhost_1, address: "127.0.0.1", port: 8053, family: :inet, processes: 1],
    [name: :inet6_localhost_1, address: "::1", port: 8053, family: :inet6]
  ]

#     import_config "#{Mix.env()}.exs"
