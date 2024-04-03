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
 * @title Tiered Access
 * @author Seven Cedars
 * @notice This contract creates Bronze, Silver and Gold tokens that can be distributed at the discretion of the vendor - they are not exchangable for points.
 * @notice Subsequently, it offers a range of tiered deductions for points and events access.  
 * 
 */

contract TieredAccess is LoyaltyGift {
    uint256[] public tokenised = [1, 1, 1, 0, 0, 1]; // 0 == false, 1 == true.
    uint256[] public bronzeSilverGoldTiers = [0, 1, 2]; // 0 == bronze, 1 == silver, 2 = gold.
    address[] public loyaltyCardAddresses; 

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
        
        // loyalty giftIds 0, 1 and 2 are bronze, silver and gold token respectively. 
        if (loyaltyGiftId == 0 || loyaltyGiftId == 1 || loyaltyGiftId == 2) {  
          revert ("This token can only be transferred by vendor.");
        }

        // check balances of  ronze, silver and gold token 
        loyaltyCardAddresses = [loyaltyCard, loyaltyCard, loyaltyCard];
        uint256[] memory balances = balanceOfBatch(loyaltyCardAddresses, bronzeSilverGoldTiers);

        /////////////////////////////// 
        // Tiered Gifts and Vouchers // 
        ///////////////////////////////

        // loyalty gift 3: at least bronze token + 1500 points => 10% off purchase at the till. 
        if (loyaltyGiftId == 3) {
            if (loyaltyPoints < 1500) {
              revert ("insufficient points");
            }
            if (
              balances[0] == 0 && 
              balances[1] == 0 && 
              balances[2] == 0
              ) {
              revert ("No Bronze, Silver or Gold token on Card");
            }
        }

        // loyalty gift 4: at least silver token + 2500 points => 25% off purchase at the till. 
        if (loyaltyGiftId == 4) {
            if (loyaltyPoints < 2500) {
              revert ("insufficient points");
            }
            if (
              balances[1] == 0 && 
              balances[2] == 0
              ) {
              revert ("No Silver or Gold token on Card");
            }
        }

        // loyalty gift 5: at least golder token + 5000 points => voucher for access to private tour shop.  
        if (loyaltyGiftId == 5) {
            if (loyaltyPoints < 5000) {
              revert ("insufficient points");
            }
            if (
              balances[1] == 0 && 
              balances[2] == 0
              ) {
              revert ("No Gold token on Card");
            }
        }

        bool check = super.requirementsLoyaltyGiftMet(loyaltyCard, loyaltyGiftId, loyaltyPoints);
        return check;
    }
}
