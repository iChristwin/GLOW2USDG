// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import "./interfaces/IRouter.sol";

/// @custom:security-contact info@whynotswitch.com
contract GLOW2USDG {
    error InputIsZero();
    error TransferError();
    error ApprovalFailed();

    IERC20 public constant GLOW = IERC20(0xf4fbC617A5733EAAF9af08E1Ab816B103388d8B6); 
    IERC20 public constant USDG = IERC20(0xe010ec500720bE9EF3F82129E7eD2Ee1FB7955F2);
    IRouter public constant ROUTER = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function swap(uint amountIn, uint256 amountOutMin, uint256 deadline) external {
        if (amountIn < 1) revert InputIsZero();
        if (!GLOW.transferFrom(msg.sender, address(this), amountIn)) revert TransferError();
        if (!GLOW.approve(address(ROUTER), amountIn)) revert ApprovalFailed();

        address[] memory path = new address[](2);
        path[0] = address(GLOW);
        path[1] = address(USDG);

        ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}
