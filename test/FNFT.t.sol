// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/FNFT.sol";
import "../src/MockNFT.sol";
import "./Helpers.sol";

contract FNFTTest is Helpers {
    TestNFT nft;
    FNFT fnft;
    address userA;
    address userB;
    address userC;

    uint256 privKeyA;
    uint256 privKeyB;
    uint256 privKeyC;

    function setup() public {
        // userA = address(0x123);
        // userB = address(0x456);
        // userC = address(0x789);

        (userA, privKeyA) = mkaddr("userA");
        (userB, privKeyB) = mkaddr("userB");
        (userC, privKeyC) = mkaddr("userC");

        nft = new TestNFT();
        nft._mint(userA, 1);

        fnft = new FNFT();

        nft.approve(address(fnft), 1);
    }

    function testFractionalize() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        assertEq(
            fnft.balanceOf(userA, 1),
            100,
            "userA should own 100 fractions"
        );

        assertEq(
            nft.ownerOf(1),
            address(fnft),
            "FractionalizedNFT should own original NFT"
        );
    }

    function testList() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        fnft.setListStatus{from: userA}(1, true);

        assertTrue(
            fnft.nfts(1).listed,
            "Fractionalized token should be listed"
        );
    }

    function testBuy() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        fnft.setListStatus{from: userA}(1, true);

        fnft.buy{from: userB, value: 10 ether}(1, 10);

        assertEq(fnft.balanceOf(userB, 1), 10, "userB should own 10 fractions");

        assertEq(fnft.balanceOf(userA, 1), 90, "userA should own 90 fractions");

        assertEq(
            balanceOf(userA),
            9.99 ether,
            "userA should receive 9.99 ether"
        );
    }

    function testTransfer() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        fnft.setListStatus{from: userA}(1, true);

        fnft.buy{from: userB, value: 10 ether}(1, 10);

        fnft.safeTransferFrom{from: userB}(userB, userC, 1, 5, "");

        assertEq(fnft.balanceOf(userC, 1), 5, "userC should own 5 fractions");

        assertEq(fnft.balanceOf(userB, 1), 5, "userB should own 5 fractions");
    }

    function testBuy2() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        fnft.setListStatus{from: userA}(1, true);

        fnft.buy{from: userB, value: 10 ether}(1, 10);

        assertEq(fnft.balanceOf(userB, 1), 10, "userB should own 10 fractions");

        assertEq(fnft.balanceOf(userA, 1), 90, "userA should own 90 fractions");

        assertEq(
            balanceOf(userA),
            9.99 ether,
            "userA should receive 9.99 ether"
        );
    }

    function testRedeem() public {
        fnft.fractionalize{from: userA}(address(nft), 1, 100, 1 ether);

        fnft.redeem{from: userA}(1);

        assertEq(nft.ownerOf(1), userA, "userA should own original NFT");

        assertEq(
            fnft.balanceOf(userA, 1),
            0,
            "userA should own zero fractions"
        );
    }
}
