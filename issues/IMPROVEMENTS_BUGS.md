## Loyalty Gifts - Solidity contracts 
**Example implementation of Loyalty Gift Contracts**

This repository is meant as initial playground to develop some examples of Loyalty Gift Contracts, following the protocol as outlined in the readme file.  

## Idea and Design
- Each contract is an instance of the LoyaltyGift interface.  
- A requirementsLoyaltyGiftMet function in the contract defines a logic on which gifts can be transferred.   
- Function are either tokenised - giving out vouchers that can be redeemed later - or simply respond with 'true' if requirements are met (and revert when not met).  
- Function can take points, but they can also draw on any other (external) input. 

## Know bugs (in order of priority)
- [ ]  

## Examples to implement (in order of priority)
* **PointsForLoyaltyGifts.sol**: Simple exchange of points for immediate gift. 
* **PointsForLoyaltyVouchers.sol**: Simple exchange of points for gift voucher.
* **TieredAccess.sol**: provides 'gold', 'silver', 'bronze' vouchers for tiered access to gifts. 
* **PointsForPseudoRaffle.sol**: a pseudo random allocation of gifts and vouchers. 
* **PointsForRaffle.sol**: A randomised raffle, using Chainling VRF. 
* **FreeGiftFriday.sol**: Gifts are only available on a certain day. 
* **TransactionsForGifts.sol**: Gifts on the basis of number of transactions over the last 7 and 14 days.
* **AuthorisedAllocation.sol**: Have an external party distribute gifts at will.


