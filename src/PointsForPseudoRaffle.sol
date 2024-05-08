// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {LoyaltyGift} from "./LoyaltyGift.sol";
import {ILoyaltyGift} from "./interfaces/ILoyaltyGift.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {LoyaltyProgram} from "../test/mocks/LoyaltyProgram.t.sol";

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
 */

contract PointsForPseudoRaffle is LoyaltyGift {

    /* Each gift contract is setup with four equal sized arrays providing info on gifts per index: 
    @param isClaimable => can gift directly be claimed by customer?
    @param isVoucher => is the gift a voucher (to be redeemed later) or has to be immediatly redeemed at the till? 
    @param cost =>  What is cost (in points) of voucher? 
    @param hasAdditionalRequirements =>  Are their additional requirements? 
    */
    string version = "alpha.2"; 
    uint256[] isClaimable = [1, 0, 0, 0]; 
    uint256[] isVoucher = [1, 1, 1, 1]; 
    uint256[] cost = [1250, 0, 0, 0];
    uint256[] hasAdditionalRequirements = [0, 0, 0, 0];
    
    /**
     * @notice constructor function: initiating loyalty gift contract. 
     * 
     * @dev the LoyaltyGift constructor takes to params: uri and tokenised (array denoting which gifts are - tokenised - vouchers.)
     */
    constructor()
        LoyaltyGift(
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmWZmc747QVTPGDZ5c7899NM425Qz6uNvvGQwiTyAY7cwx/{id}",
            version,
            isClaimable,
            isVoucher,
            cost,
            hasAdditionalRequirements 
        )
    {}

    /**
     * @notice when requesting balance of token 0, return the sum of tokens 1, 2 and 3.  
     * 
     * @param account requested account of balance
     * @param id token id. 
     * 
     * @dev Note that this does mean that token 0 cannot be minted. But if minted, it will not show up in balance (nor will it ever be transferred): the tokens / vouchers minted are lost. 
     *  
     */
    function balanceOf(address account, uint256 id) public view virtual override (ERC1155, IERC1155) returns (uint256) {
        if (id == 0) {
            return 
                balanceOf(account, 1) + 
                balanceOf(account, 2) + 
                balanceOf(account, 3);  
        } 
        return super.balanceOf(account, id); 
    }

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
        if (loyaltyPoints < cost[0]) revert ("Not enough points");

        address ownerProgram = LoyaltyProgram(msg.sender).getOwner(); 
        uint256 balanceVoucher1 = balanceOf(ownerProgram, 1); 
        uint256 balanceVoucher2 = balanceOf(ownerProgram, 2); 
        uint256 balanceVoucher3 = balanceOf(ownerProgram, 3); 

        if (balanceVoucher1 + balanceVoucher2 + balanceVoucher3 == 0) { // notice that (balanceOf(ownerProgram, 0) returns sum of vouchers [0, 1, 2] minted. See override function balanceOf below. 
            revert ("No vouchers available");
        }
        
        bool check = super.requirementsLoyaltyGiftMet(loyaltyCard, loyaltyGiftId, loyaltyPoints);
        return check;
    }

    /**
     * @notice A pseudo randomiser that weighs output according to number of raffle gifts that have been minted. 
     * 
     * @dev note that this randomised uses block.number and block.timestamp as pseudo random input. These are easily played / not properly random. 
     * @dev To make this properly random a oracle needs to be used - for instance chainlink vrf. A properly random version is coming soon.   
     *  
     */
    function pseudoRandomVoucherId() private view returns (uint256 selectedId) {
        address ownerProgram = LoyaltyProgram(msg.sender).getOwner(); 
        uint256 balanceVoucher1 = balanceOf(ownerProgram, 1); 
        uint256 balanceVoucher2 = balanceOf(ownerProgram, 2); 
        uint256 balanceVoucher3 = balanceOf(ownerProgram, 3); 

        uint256 totalVouchers = balanceVoucher1 + balanceVoucher2 + balanceVoucher3; 
        if (totalVouchers == 0) {
            revert LoyaltyGift__NoVouchersAvailable(address(this));
        }

        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(
                block.timestamp, 
                msg.sender, 
                blockhash(block.number)
                ))
            ) % totalVouchers; 

        if (randomNumber < balanceVoucher1) return 1;
        if (randomNumber >= balanceVoucher1 && randomNumber < (balanceVoucher1 + balanceVoucher2)) return 2;  
        if (randomNumber >= (balanceVoucher1 + balanceVoucher2) ) return 3;  
    }

    /* internal */
    /**
     * @notice overrides transfer logic of LoyaltyGift so that when user transfers a token zero, what is transferred is actually a token 1, 2 or 3 - pseudo randomly. 
     * 
     * @param from address from which voucher is send. 
     * @param to address at which voucher is received. 
     * @param values array of amiount of vouchers sent per id.
     * 
     * @dev ids and values need to be array of same length.  
     * @dev The check is ignored when vouchers are minted. It means any address can mint vouchers. But if they lack TBAs, addresses cannot do anything with these vouchers. 
     * 
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        virtual
        override
    {
        // when voucher 0 is transferred, a pseudo random voucher (1, 2, or 3) is sent. 
        for (uint256 i; i < ids.length;) {
            if (ids[i] == 0) ids[i] = pseudoRandomVoucherId(); 
            unchecked { ++i; }
        }

        super._update(from, to, ids, values);
    }

}
