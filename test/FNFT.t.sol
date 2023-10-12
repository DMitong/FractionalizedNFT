// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/FNFT.sol";

contract FNFTTest is Test {
    ERC721 nft;
    FNFT fnft;
    address alice;
    address bob;
    address charlie;

    function setup() public {
        alice = address(0x123);
        bob = address(0x456);
        charlie = address(0x789);

        nft = new ERC721("Test NFT", "TNFT");
        nft._mint(alice, 1);

        fnft = new FNFT("https://example.com/");

        nft.approve(address(fnft), 1);
    }

    // Define a test function to check if Alice can fractionalize her NFT
    function testFractionalize() public {
        // Call the fractionalize function from Alice's account with some parameters
        fnft.fractionalize{from: alice}(address(nft), 1, 100, 1 ether);

        // Check if Alice owns 100 fractions of the fractionalized token ID 1
        assertEq(
            fnft.balanceOf(alice, 1),
            100,
            "Alice should own 100 fractions"
        );

        // Check if the FractionalizedNFT contract owns Alice's original NFT
        assertEq(
            nft.ownerOf(1),
            address(fnft),
            "FractionalizedNFT should own original NFT"
        );
    }

    // Define a test function to check if Alice can list her fractions for sale
    function testList() public {
        // Call the fractionalize function from Alice's account with some parameters
        fnft.fractionalize{from: alice}(address(nft), 1, 100, 1 ether);

        // Call the setListStatus function from Alice's account with true as status
        fnft.setListStatus{from: alice}(1, true);

        // Check if the fractionalized token ID 1 is listed for sale
        assertTrue(
            fnft.nfts(1).listed,
            "Fractionalized token should be listed"
        );
    }

    // Define a test function to check if Bob can buy fractions of Alice's NFT
    function testBuy() public {
        // Call the fractionalize function from Alice's account with some parameters
        fnft.fractionalize{from: alice}(address(nft), 1, 100, 1 ether);

        // Call the setListStatus function from Alice's account with true as status
        fnft.setListStatus{from: alice}(1, true);

        // Call the buy function from Bob's account with some parameters and value
        fnft.buy{from: bob, value: 10 ether}(1, 10);

        // Check if Bob owns 10 fractions of the fractionalized token ID 1
        assertEq(fnft.balanceOf(bob, 1), 10, "Bob should own 10 fractions");

        // Check if Alice owns 90 fractions of the fractionalized token ID 1
        assertEq(fnft.balanceOf(alice, 1), 90, "Alice should own 90 fractions");

        // Check if Alice received 9.99 ether (minus fee) from Bob
        assertEq(
            balanceOf(alice),
            9.99 ether,
            "Alice should receive 9.99 ether"
        );
    }

    // Define a test function to check if Bob can transfer fractions of Alice's NFT to Charlie
    function testTransfer() public {
        // Call the fractionalize function from Alice's account with some parameters
        fnft.fractionalize{from: alice}(address(nft), 1, 100, 1 ether);

        // Call the setListStatus function from Alice's account with true as status
        fnft.setListStatus{from: alice}(1, true);

        // Call the buy function from Bob's account with some parameters and value
        fnft.buy{from: bob, value: 10 ether}(1, 10);

        // Call the safeTransferFrom function from Bob's account with some parameters
        fnft.safeTransferFrom{from: bob}(bob, charlie, 1, 5, "");

        // Check if Charlie owns 5 fractions of the fractionalized token ID 1
        assertEq(
            fnft.balanceOf(charlie, 1),
            5,
            "Charlie should own 5 fractions"
        );

        // Check if Bob owns 5 fractions of the fractionalized token ID 1
        assertEq(fnft.balanceOf(bob, 1), 5, "Bob should own 5 fractions");
    }
}
