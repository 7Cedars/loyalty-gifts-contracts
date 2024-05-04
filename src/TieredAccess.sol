// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {LoyaltyGift} from "./LoyaltyGift.sol";
import {ILoyaltyGift} from "./interfaces/ILoyaltyGift.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev THIS CONTRACT HAS NOT BEEN AUDITED. WORSE: TESTING IS INCOMPLETE. DO NOT DEPLOY ON ANYTHING ELSE THAN A TEST CHAIN! 
 * 
 * @title Tiered Access
 * @author Seven Cedars
 * @notice This contract creates Bronze, Silver and Gold tokens that can be distributed at the discretion of the vendor - they are not exchangable for points.
 * @notice Subsequently, it offers a range of tiered deductions for points and events access.  
 * 
 */

contract TieredAccess is LoyaltyGift {

    /* Each gift contract is setup with four equal sized arrays providing info on gifts per index: 
    @param isClaimable => can gift directly be claimed by customer?
    @param isVoucher => is the gift a voucher (to be redeemed later) or has to be immediatly redeemed at the till? 
    @param cost =>  What is cost (in points) of voucher? 
    @param hasAdditionalRequirements =>  Are their additional requirements? 
    */
    string version = "alpha.2"; 
    uint256[] isClaimable = [0, 0, 0, 1, 1, 1]; 
    uint256[] isVoucher = [1, 1, 1, 0, 0, 1]; 
    uint256[] cost = [0, 0, 0, 1500, 3000, 5000];
    uint256[] hasAdditionalRequirements = [0, 0, 0, 1, 1, 1];

    address[] public loyaltyCardAddresses; 
    uint256[] public giftIndices; 

    /**
     * @notice constructor function: initiating loyalty gift contract. 
     * 
     * @dev the LoyaltyGift constructor takes to params: uri and tokenised (array denoting which gifts are - tokenised - vouchers.)
     * £todo URI STILL NEEDS TO BE CHANGED! 
     */
    constructor()
        LoyaltyGift(
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmZUFTwBYKckH54ertA8pL3GdTZQqCEdybi1CjbJF7qXyS/{id}",
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
        
        //////////////////////////////// 
        // Bronze, Silver, Gold token // 
        ////////////////////////////////
        
        // check balances of Bronze, silver and gold token 
        loyaltyCardAddresses = [loyaltyCard, loyaltyCard, loyaltyCard];
        giftIndices = [0, 1, 2]; 
        uint256[] memory balanceTokens = balanceOfBatch(loyaltyCardAddresses, giftIndices);

        /////////////////////////////// 
        // Tiered Gifts and Vouchers // 
        ///////////////////////////////

        // loyalty gift 3: at least bronze token + 1500 points => 5% off purchase at the till. 
        if (loyaltyGiftId == 3) {
            if (loyaltyPoints < cost[3]) {
              revert ("Not enough points");
            }
            if (
              balanceTokens[0] == 0 && 
              balanceTokens[1] == 0 && 
              balanceTokens[2] == 0
              ) {
              revert ("No Bronze, Silver or Gold token on Card");
            }
        }

        // loyalty gift 4: at least silver token + 2500 points => 15% off purchase at the till. 
        if (loyaltyGiftId == 4) {
            if (loyaltyPoints < cost[4]) {
              revert ("Not enough points");
            }
            if (
              balanceTokens[1] == 0 && 
              balanceTokens[2] == 0
              ) {
              revert ("No Silver or Gold token on Card");
            }
        }

        // loyalty gift 5: at least golder token + 5000 points => voucher for access to private tour shop.  
        if (loyaltyGiftId == 5) {
            if (loyaltyPoints < cost[5]) {
              revert ("Not enough points");
            }
            if ( balanceTokens[2] == 0 ) {
              revert ("No Gold token on Card");
            }
        }

        bool check = super.requirementsLoyaltyGiftMet(loyaltyCard, loyaltyGiftId, loyaltyPoints);
        return check;
    }
}
