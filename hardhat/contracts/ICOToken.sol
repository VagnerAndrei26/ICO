// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.0;

  import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "./ICryptoDevs.sol";

  contract ICOToken is ERC20, Ownable {

    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 1e18;
    uint256 public constant maxTotalSupply = 10000 * 1e18;
    ICryptoDevs cryptodevsnft;

    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Vagner token", "VAG") {
        cryptodevsnft = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value > _requiredAmount, "Not enough ether provided");
        uint256 amountWithDecimals = amount * 1e18;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "No more tokens can be minted");

        _mint(msg.sender, amountWithDecimals);
    }


    function claim() public {

        uint256 balance = cryptodevsnft.balanceOf(msg.sender);
        require(balance > 1, "You dont own any NFT");
        uint256 amount = 0;
        for(uint i=0; i < balance; i++) {
            uint256 tokenId = cryptodevsnft.tokenOfOwnerByIndex(msg.sender,i);
            if(!tokenIdsClaimed[tokenId]) {
                amount ++;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }
    

    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        require(amount > 0 ,"No ether stored in this contract");
        address _owner = owner();
        (bool success, ) = _owner.call{value:amount}("");
        require(success, "Failed to send ether");
    }


    receive() payable external{}
    fallback() payable external{}
  }