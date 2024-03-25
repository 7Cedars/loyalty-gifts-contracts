# this is copy past from https://github.com/Cyfrin/foundry-erc20-f23/blob/main/Makefile
# Need to adapt this later on. 

-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build
test :; forge test 
snapshot :; forge snapshot
format :; forge fmt
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1



ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

###############################
# 			Sepolia testnet				#
###############################
SEPOLIA_FORKED_TEST_ARGS := --fork-url $(SEPOLIA_RPC_URL) 
SEPOLIA_FORKED_DEPLOY_ARGS := --fork-url $(SEPOLIA_RPC_URL) --broadcast --account dev_2 --sender ${DEV2_ADDRESS} --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

sepoliaForkTest: 
	@forge test $(SEPOLIA_FORKED_TEST_ARGS) -vvvv 

sepoliaForkedDeployTest: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(SEPOLIA_FORKED_TEST_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.s.sol:DeployPointsForLoyaltyVouchers.s $(SEPOLIA_FORKED_TEST_ARGS)
	
sepoliaForkedDeploy: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.s.sol:DeployPointsForLoyaltyVouchers.s $(SEPOLIA_FORKED_DEPLOY_ARGS)


###############################
# 		OPSepolia testnet				#
###############################
OPT_SEPOLIA_FORKED_TEST_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) 
OPT_SEPOLIA_FORKED_DEPLOY_ARGS := --fork-url $(OPT_SEPOLIA_RPC_URL) --broadcast --account dev_2 --sender ${DEV2_ADDRESS} --verify --etherscan-api-key $(OPT_ETHERSCAN_API_KEY)

optSepoliaForkTest: 
	@forge test $(OPT_SEPOLIA_FORKED_TEST_ARGS) -vvvv 

optSepoliaForkedDeployTest: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.s.sol:DeployPointsForLoyaltyVouchers.s $(OPT_SEPOLIA_FORKED_TEST_ARGS)
	
optSepoliaForkedDeploy: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.s.sol:DeployPointsForLoyaltyVouchers.s $(OPT_SEPOLIA_FORKED_DEPLOY_ARGS)

############################################## 
#     Arbitrum Sepolia testnet							 #
##############################################
ARB_SEPOLIA_FORKED_TEST_ARGS := --fork-url $(ARB_SEPOLIA_RPC_URL) 
ARB_SEPOLIA_FORKED_DEPLOY_ARGS := --fork-url $(ARB_SEPOLIA_RPC_URL) --broadcast --account dev_2 --sender ${DEV2_ADDRESS} --verify --etherscan-api-key $(ARBISCAN_API_KEY)

arbSepoliaForkTest: 
	@forge test $(ARB_SEPOLIA_FORKED_TEST_ARGS) 

arbSepoliaForkedDeployTest: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ARB_SEPOLIA_FORKED_TEST_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(ARB_SEPOLIA_FORKED_TEST_ARGS)
	
arbSepoliaForkedDeploy: 
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ARB_SEPOLIA_FORKED_DEPLOY_ARGS)
	@forge script script/DeployPointsForLoyaltyVouchers.s.sol:DeployPointsForLoyaltyVouchers $(ARB_SEPOLIA_FORKED_DEPLOY_ARGS)

##################################
#     Local testnet							 #
##################################
ANVIL_ARGS_0 := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_0) --broadcast

anvilDeployGifts:
	@forge script script/DeployPointsForLoyaltyGifts.s.sol:DeployPointsForLoyaltyGifts $(ANVIL_ARGS_0)
	@forge script script/DeployPointsForLoyaltyVouchers.s.s.sol:DeployPointsForLoyaltyVouchers.s $(ANVIL_ARGS_0)

# verify example 
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000 --etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version v0.8.19+commit.7dd6d404 0x089dc24123e0a27d44282a1ccc2fd815989e3300 src/OurToken.sol:OurToken