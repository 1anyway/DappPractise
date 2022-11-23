// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ERC721.sol";

contract ZZ is ERC721 {
    uint public MAX_LPLS = 10; // 总量
    address private owner;
    uint256 private counter;
    // 构造函数
    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        owner = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://voidtech.cn/i/2022/11/21/w6opnx.png";
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    // 铸造函数
    function mint(address to) external onlyOwner {
        uint256 tokenId = counter;
        require(tokenId >= 0 && tokenId < MAX_LPLS, "tokenId out of range");
        _mint(to, tokenId);
        counter++;
    }
}
