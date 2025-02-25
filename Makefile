-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil install deploy deploy-sepolia verify

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

deploy-anvil:
	@forge script script/DeployFirstToken.s.sol --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy-core-testnet:
	forge script script/DeployFirstToken.s.sol:DeployFirstToken --rpc-url $(CORE_TESTNET_RPC_URL) --account default --broadcast

deploy-arb-sepolia:
	@forge script script/DeployFirstToken.s.sol:DeployFirstToken --rpc-url $(ARB_SEPOLIA_RPC_URL) --account $(ACCOUNT) --sender $(SENDER) --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast --verify

deploy-bnb-testnet:
	forge script script/DeployFirstToken.s.sol:DeployFirstToken --rpc-url $(BNB_TESTNET_RPC_URL) --account $(ACCOUNT) --api-key $(CORESCAN_API_KEY) --broadcast

verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000 --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version v0.8.19+commit.7dd6d404 0x089dc24123e0a27d44282a1ccc2fd815989e3300 src/FirstToken.sol:FirstToken