// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {LoyaltyGift} from "./LoyaltyGift.sol";
import {ILoyaltyGift} from "./interfaces/ILoyaltyGift.sol";
import {ERC1155} from "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev THIS CONTRACT HAS NOT BEEN AUDITED. WORSE: TESTING IS INCOMPLETE. DO NOT DEPLOY ON ANYTHING ELSE THAN A TEST CHAIN! 
 * 
 * @title Points for Loyalty Gifts
 * @author Seven Cedars
 * @notice A concrete implementation of a loyalty Gift contract. This contract simply exchanges loyalty points for three types of gifts and three types of vouchers.
 * 
 * For a mock version of the LoyalProgram contract these gifts interact with, see the test/mocks/test/mocks/LoyaltyProgram.t.sol. 
 * 
 */

contract PointsForLoyaltyGifts is LoyaltyGift {
    /* Each gift contract is setup with four equal sized arrays providing info on gifts per index: 
    @param isClaimable => can gift directly be claimed by customer?
    @param isVoucher => is the gift a voucher (to be redeemed later) or has to be immediatly redeemed at the till? 
    @param cost =>  What is cost (in points) of voucher? 
    @param hasAdditionalRequirements =>  Are their additional requirements? 
    */
    string version = "alpha.3"; 
    uint256[] isClaimable = [1, 1]; 
    uint256[] isVoucher = [0, 0]; 
    uint256[] cost = [2500, 4500];
    uint256[] hasAdditionalRequirements = [0, 0];   

    /**
     * @notice constructor function: initiating loyalty gift contract. 
     * 
     * @dev the LoyaltyGift constructor takes to params: uri and tokenised (array denoting which gifts are - tokenised - vouchers.)
     *  £todo URI STILL NEEDS TO BE CHANGED! 
     */
    constructor()
        LoyaltyGift(
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmU9Big9eDnjd3i4AHKW96cdqCD1qSDoiEfbA96gsXFeiq/{id}",
            version,
            isClaimable,
            isVoucher,
            cost,
            hasAdditionalRequirements    
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
     * @dev Each gift can have its own bespoke logic.
     * @dev £todo This function should take calldata to make more diverse logics possible. 
     *  
     */
    function requirementsLoyaltyGiftMet(address loyaltyCard, uint256 loyaltyGiftId, uint256 loyaltyPoints)
        public
        override
        returns (bool success)
    {
        // loyalty gift 0: exchange 2500 points for gift. 
        if (loyaltyGiftId == 0) {
            if (loyaltyPoints < cost[0]) {
                revert ("Not enough points.");
            }
        }

        // loyalty gift 1: exchange 4500 points for gift. 
        if (loyaltyGiftId == 1) {
            if (loyaltyPoints <  cost[1]) {
                revert ("Not enough points.");
            }
        }

        bool check = super.requirementsLoyaltyGiftMet(loyaltyCard, loyaltyGiftId, loyaltyPoints);
        return check;
    }
}
