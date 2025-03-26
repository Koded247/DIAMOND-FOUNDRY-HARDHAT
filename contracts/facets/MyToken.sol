// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.28;

 import "../libraries/AppStorage.sol";
 
 contract MyToken {

  AppStorage internal storex;
     // Token details

    //  string public name;
    //  string public symbol;
    //  uint8 public decimals = 18; // Standard ERC-20 decimals
    //  uint256 public storex.totalSupply;
 
     // Balances and allowances
    //  mapping(address => uint256) public balanceOf;
    //  mapping(address => mapping(address => uint256)) public allowance;
 
     // Events
     event Transfer(address indexed from, address indexed to, uint256 value);
     event Approval(address indexed owner, address indexed spender, uint256 value);
     event Mint(address indexed to, uint256 value); // Mint event
     event Burn(address indexed from, uint256 value); // Burn event
 
     // Constructor to initialize token details and total supply
     constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {

      storex.name = _name;
      storex.symbol = _symbol;
      storex.decimals = 18;
      storex.totalSupply = _totalSupply * (10 ** uint256(storex.decimals)); // Adjust for decimals
      storex.balanceOf[msg.sender] = storex.totalSupply; // Assign all tokens to the deployer
         emit Transfer(address(0), msg.sender, storex.totalSupply); // Minting event
     }
 
     // Transfer tokens from the sender to another address
     function transfer(address _to, uint256 _value) public returns (bool success) {
         require(_to != address(0), "Invalid address"); // Prevent sending to zero address
         require(storex.balanceOf[msg.sender] >= _value, "Insufficient balance"); // Check sender's balance
         storex.balanceOf[msg.sender] -= _value; // Deduct from sender
         storex.balanceOf[_to] += _value; // Add to recipient
         emit Transfer(msg.sender, _to, _value); // Emit Transfer event
         return true;
     }
 
     // Approve another address to spend tokens on behalf of the sender
     function approve(address _spender, uint256 _value) public returns (bool success) {
         require(_spender != address(0), "Invalid address"); // Prevent approving zero address
         storex.allowance[msg.sender][_spender] = _value; // Set allowance
         emit Approval(msg.sender, _spender, _value); // Emit Approval event
         return true;
     }
 
     // Transfer tokens on behalf of an owner (requires prior approval)
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         require(_to != address(0), "Invalid address"); // Prevent sending to zero address
         require(storex.balanceOf[_from] >= _value, "Insufficient balance"); // Check owner's balance
         require(storex.allowance[_from][msg.sender] >= _value, "Allowance exceeded"); // Check allowance
         storex.balanceOf[_from] -= _value; // Deduct from owner
         storex.balanceOf[_to] += _value; // Add to recipient
         storex.allowance[_from][msg.sender] -= _value; // Deduct from allowance
         emit Transfer(_from, _to, _value); // Emit Transfer event
         return true;
     }
 
     // Mint new tokens
     function mint(address _to, uint256 _value) public returns (bool success) {
         require(_to != address(0), "Invalid address"); // Prevent minting to zero address
         storex.totalSupply += _value; // Increase total supply
         storex.balanceOf[_to] += _value; // Add to recipient's balance
         emit Mint(_to, _value); // Emit Mint event
         return true;
     }
 
     // Burn tokens from the sender's balance
     function burn(uint256 _value) public returns (bool success) {
         require(storex.balanceOf[msg.sender] >= _value, "Insufficient balance"); // Check balance
         storex.totalSupply -= _value; // Decrease total supply
         storex.balanceOf[msg.sender] -= _value; // Deduct from sender's balance
         emit Burn(msg.sender, _value); // Emit Burn event
         return true;
     }
 }