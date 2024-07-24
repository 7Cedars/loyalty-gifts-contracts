# this is copy past from https://github.com/Cyfrin/foundry-erc20-f23/blob/main/Makefile

# £ack this file was originally copied from https://github.com/Cyfrin/foundry-erc20-f23/blob/main/Makefile
-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install modules
install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit && forge install https://github.com/erc6551/reference --no-commit

# Update Dependencies
update:; forge update

# Build
build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil --steps-tracing --block-time 5

# Verify already deployed contract - example 
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000 --etherscan-api-key $(OPT_ETHERSCAN_API_KEY) --compiler-version v0.8.19+commit.7dd6d404 0x089dc24123e0a27d44282a1ccc2fd815989e3300 src/OurToken.sol:OurToken


###############################
# 		OPSepolia testnet				#
###############################
OPT_SEPOLIA_FORKED_TEST_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) 
OPT_SEPOLIA_FORKED_DEPLOY_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) --broadcast --account dev_2 --sender ${DEV2_ADDRESS} --verify --etherscan-api-key $(OPT_ETHERSCAN_API_KEY)

optSepoliaForkTest: 
	@forge test --no-match-contract ContinueOn  

optSepoliaForkedDeployTest: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(OPT_SEPOLIA_FORKED_TEST_ARGS)	
	@forge script script/DeployFridaysFifteenPercent.s.sol:DeployFridaysFifteenPercent $(OPT_SEPOLIA_FORKED_TEST_ARGS)	
	@forge script script/DeployPointsForPseudoRaffle.s.sol:DeployPointsForPseudoRaffle $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	@forge script script/DeployTieredAccess.s.sol:DeployTieredAccess $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	
optSepoliaForkedDeploy: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployFridaysFifteenPercent.s.sol:DeployFridaysFifteenPercent $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)	
	@forge script script/DeployPointsForPseudoRaffle.s.sol:DeployPointsForPseudoRaffle $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployTieredAccess.s.sol:DeployTieredAccess $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)

###############################
# 			 local testnet				#
###############################
ANVIL_ARGS_0 := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_0) --broadcast

anvilDeployGifts: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ANVIL_ARGS_0)
	@forge script script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(ANVIL_ARGS_0)	
	@forge script script/DeployFridaysFifteenPercent.s.sol:DeployFridaysFifteenPercent $(ANVIL_ARGS_0)	
	@forge script script/DeployPointsForPseudoRaffle.s.sol:DeployPointsForPseudoRaffle $(ANVIL_ARGS_0)
	@forge script script/DeployTieredAccess.s.sol:DeployTieredAccess $(ANVIL_ARGS_0)
	



