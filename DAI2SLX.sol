// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "./IMimo.sol";

/// @custom:security-contact info@whynotswitch.com
library DAI2SLX {
    error InputIsZero();
    error TransferError();
    error ApprovalFailed();

    event Deposit(
        uint256 indexed amount,
        address indexed from,
        address indexed to,
        uint256 timestamp
    );

    event Claim(address indexed to, uint256 indexed amount, uint256 indexed timestamp);

    IERC20 public constant DAI = IERC20(0x1CbAd85Aa66Ff3C12dc84C5881886EEB29C1bb9b); // ioDAI
    IMimo public constant MIMO = IMimo(0x147CdAe2BF7e809b9789aD0765899c06B361C5cE); // router

    function depositDAI(uint256 amount) internal {
        if (!DAI.transferFrom(msg.sender, address(this), amount)) revert TransferError();
        emit Deposit(amount, msg.sender, address(this), block.timestamp);
    }

    function claimSLX(uint amountIn, uint256 amountOutMin, uint256 deadline) internal {
        if (amountIn < 1) revert InputIsZero();
        if (!DAI.approve(address(MIMO), amountIn)) revert ApprovalFailed();

        address[] memory path = new address[](2);
        path[0] = address(DAI);
        path[1] = 0x1CbAd85Aa66Ff3C12dc84C5881886EEB29C1bb9b; // TODO: added DePIN token address

        MIMO.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
        emit Claim(msg.sender, amountIn, block.timestamp);
    }
}
