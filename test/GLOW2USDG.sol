// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {GLOW2USDG} from "../src/GLOW2USDG.sol";
import {IRouter} from "../src/interfaces/IRouter.sol";
import {IERC20} from "@openzeppelin/contracts@5.0.2/interfaces/IERC20.sol";

contract GLOW2USDG_UnitTest is Test {
    IERC20 public GLOW;
    IERC20 public USDG;
    address public here;
    GLOW2USDG public swapper;
    uint256 public constant bal10k = 1e22;

    function setUp() public {
        string memory url = vm.rpcUrl("eth-mainnet");
        vm.createSelectFork(url);

        here = address(this);
        swapper = new GLOW2USDG();

        GLOW = IERC20(0xf4fbC617A5733EAAF9af08E1Ab816B103388d8B6);
        USDG = IERC20(0xe010ec500720bE9EF3F82129E7eD2Ee1FB7955F2);

        deal(address(GLOW), here, bal10k, true);
        GLOW.approve(address(swapper), bal10k);
    }

    function testSwap() public {
        uint256 glowInitialBalance = GLOW.balanceOf(here);
        uint256 usdgInitialBalance = USDG.balanceOf(here);
        uint256 deadline = vm.unixTime() + 100_000;  // 100 seconds

        swapper.swap(bal10k, bal10k, deadline);

        assertEq(usdgInitialBalance, 0, "USDG balance should be 0 before swap");
        assertEq(glowInitialBalance, bal10k, "GLOW balance should be 10k before swap");
        assertGe(USDG.balanceOf(here), bal10k, "USDG balance should be at least 10k after swap");
        assertApproxEqAbs(GLOW.balanceOf(here), 0, 0.1e18, "GLOW balance should be approximatly 0 after swap");
    }
}