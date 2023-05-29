// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./token/ABaseNFT.sol";
import "./interface/IMinimalSBT.sol";

contract SimpleNFT is ABaseNFT, IERC5192 {
    mapping(uint256 => bool) _locked;

    constructor(string memory name, string memory symbol) ABaseNFT(name, symbol) {}

    modifier isTransferAllowed(uint256 tokenId) {
        require(!_locked[tokenId], "SimpleNFT: transfer is not allowed");
        _;
    }

    function mintTo(
        address receiver,
        uint256 tokenId,
        string calldata tokenURI
    ) external override onlyOwner {
        _mint(receiver, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _lock(tokenId);
    }

    function getUserTokens(address user) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(user);

        uint256[] memory tokens = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(user, i);
        }

        return tokens;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ABaseNFT) isTransferAllowed(tokenId) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function locked(uint256 tokenId) public view returns (bool) {
        require(ownerOf(tokenId) != address(0), "SimpleNFT: query for nonexistent token");
        return _locked[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view override(ABaseNFT) returns (bool) {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }

    function _lock(uint256 tokenId) internal {
        if (!_locked[tokenId]) {
            _locked[tokenId] = true;
            emit Locked(tokenId);
        }
    }
}
