// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;


/**
 * @title Converter
 * @dev Converts bytes32 and string pair.
 */
contract Converter {
    /**
     * @dev Converts string to bytes32 
     *
     * References:
     *
     * - https://blockchangers.github.io/solidity-converter-online/
     */
    function stringToBytes32(
        string memory source
    ) public pure returns (
        bytes32 result
    ) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) { return 0x0; }
        assembly { result := mload(add(source, 32)) }
    }

    /**
     * @dev Converts string to bytes32 
     *
     * References:
     *
     * - https://ethereum.stackexchange.com/questions/2519/
     */
    function bytes32ToString(
        bytes32 x
    ) public pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint256(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    /**
     * @dev Retures hashed value of uint256 and seed.
     */
    function uint256ToKeccak256WithSeed(
        uint256 x,
        uint256 seed
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, seed));
    }

    /**
     * @dev Retures hashed value of int256 and seed.
     */
    function int256ToKeccak256WithSeed(
        int256 x,
        uint256 seed
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(uint256(x), seed));
    }

    /**
     * @dev Converts uint256 to int256
     */
    function uint256ToInt256(
        uint256 x
    ) public pure returns (
        int256 y
    ) {
        y = int256(x);
    }

    /**
     * @dev Converts int256 to uint256
     */
    function int256ToUint256(
        int256 x
    ) public pure returns (
        uint256 y
    ) {
        y = uint256(x);
    }
}
