geth --holesky --authrpc.addr localhost --authrpc.port 8551 --authrpc.vhosts localhost --authrpc.jwtsecret "~/.nimbus-jwtsecret" &

~/dev/nimbus-eth2/build/nimbus_beacon_node --config-file="~/dev/nimbus-eth2/config.toml"
