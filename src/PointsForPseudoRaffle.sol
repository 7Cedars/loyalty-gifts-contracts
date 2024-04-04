// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LoyaltyGift} from "./LoyaltyGift.sol";
import {ILoyaltyGift} from "./interfaces/ILoyaltyGift.sol";
import {ERC1155} from "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev THIS CONTRACT HAS NOT BEEN AUDITED. WORSE: TESTING IS INCOMPLETE. DO NOT DEPLOY ON ANYTHING ELSE THAN A TEST CHAIN! 
 * 
 * @title Points for Pseudo Raffle 
 * @author Seven Cedars
 * @notice  This contract exchanges 1250 loyalty points for access to a raflle in which three gifts can be won: a coffee, donought and cupcake.
 * This raffle is not truly randomised and can easily be gamed. As such, it should only be used for raffles where gifts are relatively small and of equal value.  
 * 
 * @notice The contract is build as a single gift within a single contract, but that issues randomised vouchers when called. 
 * 
 * £todo: 
 * The logic of this contract should be as follows: 
 * gift 0 is claimable for 1250 points. 
 * When claimed, it sends a random vouchers of gift 1, 2 or 3. 
 * Meaning: gifts 1, 2, and 3 need to be minted. Their distribution (through the raffle) needs to be linked with how many have been minted of each. 
 * Meaning: gift 0 is not a voucher: it is just a gift type token. 
 * Meaning gifts 1, 2, and 3 are not claimable: customers cannot request these vouchers - they need to win them. 
 */

/////////////////////////////////////////
// EVERYTHIN BELOW IS STILL WIP / OLD! //
/////////////////////////////////////////

contract PointsForPseudoRaffle is LoyaltyGift {
    uint256[] public tokenised = [1]; // 0 == false, 1 == true.
    error LoyaltyGift__InvalidTokenId(address loyaltyGift); 

    /**
     * @notice constructor function: initiating loyalty gift contract. 
     * 
     * @dev the LoyaltyGift constructor takes to params: uri and tokenised (array denoting which gifts are - tokenised - vouchers.)
     * £todo URI STILL NEEDS TO BE CHANGED! 
     */
    constructor()
        LoyaltyGift(
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmXS9s48RkDDDSqsyjBHN9HRSXpUud3FsBDVa1uZjXYMAH/{id}",
            tokenised
        )
    {}

    /**
     * @notice Sets requirement logics of tokens. Overrides function from the standard LoyaltyGift contract.
     * 
     * @param loyaltyCard loyalty card from which request is send. 
     * @param loyaltyGiftId loyalty gift requested
     * @param loyaltyPoints points to be sent. 
     * 
     * @dev This is the actual claim logic / price of the Loyalty Gift / Token
     * @dev £todo This function should take calldata to make more diverse logics possible. 
     *  
     */
    function requirementsLoyaltyGiftMet(address loyaltyCard, uint256 loyaltyGiftId, uint256 loyaltyPoints)
        public
        override
        returns (bool success)
    {
        if (loyaltyGiftId != 0) revert ("Invalid token");
        if (loyaltyPoints < 1250) revert ("Insufficient points") ;
        
        bool check = super.requirementsLoyaltyGiftMet(loyaltyCard, loyaltyGiftId, loyaltyPoints);
        return check;
    }

    /** 
     * @notice issues random voucher, overrides standard function in LoyaltyGift contract. 
     * 
     */
    function issueLoyaltyVoucher(address loyaltyCard, uint256 loyaltyGiftId)
    public 
    override 
    {
        if (loyaltyGiftId != 0) {
            revert LoyaltyGift__InvalidTokenId(address(this));
        }
        
        if (balanceOf(msg.sender, loyaltyGiftId) == 0) {
            revert LoyaltyGift__NoTokensAvailable(address(this));
        }

        uint newLoyaltyGiftId = pseudoRandomNumber(3); 

        // problem is: these also have to be minted! 
        safeTransferFrom(msg.sender, loyaltyCard, newLoyaltyGiftId, 1, "");
    }

    function pseudoRandomNumber(uint256 maxRange) private view returns (uint256) {
        return uint256(
            keccak256(abi.encodePacked(
                block.timestamp, 
                msg.sender, 
                blockhash(block.number)
                ))
            ) % maxRange; 
    }
}
