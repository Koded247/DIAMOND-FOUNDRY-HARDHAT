# Diamond Staking Contract

## Overview
This project implements a Diamond Staking contract using the [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535). The contract allows users to stake ERC20 tokens and earn rewards over time. It is developed using [Foundry](https://book.getfoundry.sh/) for Solidity development and is tested using the `MyERC20` token.

## Features
- Modular and upgradeable smart contract architecture using the Diamond Standard.
- Users can stake `MyERC20` tokens to earn rewards.
- Supports flexible staking durations.
- Efficient reward distribution mechanism.
- Fully tested with Foundry.

## Requirements
- Foundry ([Installation Guide](https://book.getfoundry.sh/getting-started/installation))
- Node.js & npm/yarn (for deployment scripts, if applicable)
- A supported Ethereum wallet (e.g., MetaMask) for testing on a live network

## Installation
Clone the repository and install dependencies:

```sh
git clone <repository_url>
cd diamond-staking
forge install
```

## Compilation
Compile the smart contracts with:
```sh
forge build
```

## Testing
Run the test suite with:
```sh
forge test --gas-report
```

### Test Coverage Report
Below is an example of a test coverage report generated by Foundry:

![Test Coverage Report](![Uploading Screenshot (51).png…]()
![Screenshot (50)](https://github.com/user-attachments/assets/b87d9f8d-9160-4224-998d-83d722056452)
)

## Deployment
To deploy the Diamond Staking contract, run:
```sh
forge script script/Deploy.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```
Replace `<YOUR_RPC_URL>` and `<YOUR_PRIVATE_KEY>` with appropriate values.

## Usage
### Staking Tokens
1. Approve the contract to spend `MyERC20` tokens:
   ```solidity
   MyERC20.approve(diamondStakingAddress, amount);
   ```
2. Stake tokens:
   ```solidity
   DiamondStaking.stake(amount);
   ```

### Claiming Rewards
Users can claim their staking rewards:
```solidity
DiamondStaking.claimRewards();
```

### Unstaking
To unstake tokens after the required lock period:
```solidity
DiamondStaking.unstake(amount);
```

## Contract Structure
- **Diamond.sol**: The main contract implementing EIP-2535.
- **StakingFacet.sol**: Handles staking logic.
- **RewardFacet.sol**: Manages rewards calculation and distribution.
- **OwnershipFacet.sol**: Handles contract ownership and upgrades.

## Security Considerations
- Ensure `MyERC20` token is audited and secure.
- Only interact with verified contract addresses.
- Use a multisig wallet for contract ownership where applicable.

## License
This project is licensed under the MIT License.

## Contributors
- [korede Abidoye]
- Contributions are welcome! Feel free to submit PRs or open issues.

