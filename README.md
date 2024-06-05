<!--
*** NB: This template was taken from: https://github.com/othneildrew/Best-README-Template/blob/master/README.md?plain=1 
*** For shields, see: https://shields.io/
*** It was rafactored along examples in the Cyfrin updraft course to follow some standard practices in solidity projects. 
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/7Cedars/loyalty-program-contracts"> 
    <img src="public/iconLoyaltyProgram.svg" alt="Logo" width="200" height="200">
  </a>

<h3 align="center">Loyal: A Solidity Protocol for Web3 Customer Engagement Programs</h3>

  <p align="center">
    Example Gift Contracts 
    <br />
    <a href="https://github.com/7Cedars/loyalty-program-contracts"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!--NB: TO DO --> 
    <a href="https://loyalty-program-psi.vercel.app">View Demo of a dApp interacting with the protocol.</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Report Bug</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>

- [About](#about)
  - [Example Gift Contracts](#example-gift-contracts)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Test](#test)
  - [Test coverage](#test-coverage)
  - [Build](#build)
  - [Live example](#live-example)
- [Known Issues](#known-issues)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)
  
</details>


<!-- ABOUT -->
## About
The Loyal protocol provides a modular, composable and gas efficient framework for blockchain based customer engagement programs. 

This repository provides examples implementations of loyalty gift contracts: Contracts that exchange points for gifts or vouchers. These contracts interact with standard loyalty programs: ERC-1155 based contracts that mint (fungible) points and (non-fungible) loyalty cards. 

If you have not checked out the loyalty-program repository, please do so first. See the repository at [https://github.com/7Cedars/loyalty-program-contracts](https://github.com/7Cedars/loyalty-program-contracts).

### Example Gift Contracts 
* `PointsForLoyaltyGifts.sol`: Simple exchange of points for immediate gift. 
* `PointsForLoyaltyVouchers.sol`: Simple exchange of points for gift voucher.
* `TieredAccess.sol`: provides 'gold', 'silver', 'bronze' vouchers for tiered access to gifts.
* `PointsForPseudoRaffle.sol`: a pseudo random allocation of gifts and vouchers. *Work in Progress.*
* `PointsForRaffle.sol`: A randomised raffle, using Chainling VRF. *Coming soon.*
* `FreeGiftFriday.sol`: Gifts are only available on a certain day. 
* `TransactionsForGifts.sol`: Gifts on the basis of number of transactions over the last 7 and 14 days. *Coming soon.*

### Built With
* Solidity 0.8.19
* Foundry 0.2.0
* OpenZeppelin 5.0
* Chainlink 
* www.svgrepo.com

- Gift Contratcs build on the following ERC standards:  
  - [ERC-1155: Multi-Token Standard]: the Loyalty Program contract mints fungible points and non-fungible loyalty Cards; external contracts can mint semi-fungible vouchers. 
  - [ERC-165: Standard Interface Detection]: gift contracts are checked if they follow they ILoyaltyGift interface.  

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running do the following.

### Prerequisites

Foundry
  - Install following the directions at [getfoundry.sh](https://getfoundry.sh/).
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

A blockchain with an ERC-6551 registry (v.0.3.1) deployed at address 0x000000006551c19487814612e58FE06813775758. 
  - To check what chains have an ERC-6551 registry deployed, see [tokenbound.org](https://docs.tokenbound.org/contracts/deployments). 
  - To deploy yourself (or on a local chain) follow the steps at [tokenbound.org](https://docs.tokenbound.org/guides/deploy-registry).

### Quickstart
1. Clone the repo
    ```
    git clone https://github.com/7Cedars/loyalty-program-contracts.git
    ```
2. navigate to the folder
    ```
    cd loyalty-program-contracts
    ```
3. create a .env file and add the following:
     ```
     SELECTED_RPC_URL = <PATH_TO_RPC> 
     ```
   
  Where <PATH_TO_RPC> is the url to your rpc provider, for example: https://eth-sepolia.g.alchemy.com/v2/... or http://localhost:8545 for a local anvil chain. 

  Note that tests will not ru on a chain that does not have an ERC-6551 registry deployed. Due to compiler conflicts, it is not possible to deterministically deploy the erc6511 registry inside the test suite itself.    

1. run make
    ```
    make
    ```

## Usage
### Test 
  ```sh
  $ forge test
   ```

### Test coverage
  ```sh
  forge coverage
  ```

and for coverage based testing: 
  ```sh
  forge coverage --report debug
  ```

### Build
  ```sh
   $ forge build
   ```

<!-- USAGE EXAMPLES -->
### Live example
A front-end dApp demonstration of this web3 protocol has been deployed on vercel.com. 
Try it out at [https://loyalty-program-psi.vercel.app/](https://loyalty-program-psi.vercel.app/). 

<!-- KNOWN ISSUES -->
## Known Issues
These contracts have not been audited. Do not deploy on anything else than a test chain. 

<!-- ROADMAP -->
## Roadmap
- [ ] Implement missing example gift contracts. The truly random `PointsForRaffle.sol` is top of the list. 

See the [open issues](https://github.com/7Cedars/loyalty-program-contracts/issues) for a full list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## Contributing
Contributions and suggestions are more than welcome. If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Thank you! 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->
## Contact

Seven Cedars - [@7__Cedars](https://twitter.com/7__Cedars) - cedars7@proton.me

GitHub profile [https://github.com/7Cedars](https://github.com/7Cedars)



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
* This project was build while following [PatrickCollins](https://www.youtube.com/watch?v=wUjYK5gwNZs&t) amazing Learn Solidity, Blockchain Development, & Smart Contracts Youtube course. Comes highly recommended for anyone wanting to get into Foundry & intermediate/advanced solidity coding. 
* I took the template for the readme file from [Drew Othneil](https://github.com/othneildrew/Best-README-Template/blob/master/README.md?plain=1). 
* All the images for the gifts and vouchers were created with help from www.svgrepo.com. A fantastic repo with CC licensed art work. Specific links are included in all the images.   
* And a special thanks should go out to [SpeedRunEthereum](https://speedrunethereum.com/) and [LearnWeb3](https://learnweb3.io/) for providing the first introductions to solidity coding. 
* The DateTime library was copy-pasted from https://github.com/RollaProject/solidity-datetime/blob/master/contracts/DateTime.sol 
* And the deploy scripts use Etherscan.io APIs.



<!-- MARKDOWN LINKS & IMAGES -->
[issues-shield]: https://img.shields.io/github/issues/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[issues-url]: https://github.com/7Cedars/loyalty-program-contracts/issues/
[license-shield]: https://img.shields.io/github/license/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[license-url]: https://github.com/7Cedars/loyalty-program-contracts/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
<!-- See list of icons here: https://hendrasob.github.io/badges/ -->
