// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../libraries/AppStorage.sol";

contract MyToken {
    AppStorage internal storex;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    // Constructor
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        storex.name = _name;
        storex.symbol = _symbol;
        storex.decimals = 18;
        storex.totalSupply = _totalSupply * (10 ** uint256(storex.decimals));
        storex.balanceOf[msg.sender] = storex.totalSupply;
        emit Transfer(address(0), msg.sender, storex.totalSupply);
    }

    // Getter functions for AppStorage variables
    function name() public view returns (string memory) {
        return storex.name;
    }

    function symbol() public view returns (string memory) {
        return storex.symbol;
    }

    function decimals() public view returns (uint8) {
        return storex.decimals;
    }

    function totalSupply() public view returns (uint256) {
        return storex.totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return storex.balanceOf[account];
    }

    // Transfer tokens from the sender to another address
function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0), "Invalid address");
    require(storex.balanceOf[msg.sender] >= _value, "Insufficient balance");
    storex.balanceOf[msg.sender] -= _value;
    storex.balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
}

    // Approve another address to spend tokens on behalf of the sender
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address");
        storex.allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens on behalf of an owner (requires prior approval)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(storex.balanceOf[_from] >= _value, "Insufficient balance");
        require(storex.allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        storex.balanceOf[_from] -= _value;
        storex.balanceOf[_to] += _value;
        storex.allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Mint new tokens
    function mint(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        storex.totalSupply += _value;
        storex.balanceOf[_to] += _value;
        emit Mint(_to, _value);
        return true;
    }

    // Burn tokens from the sender's balance
    function burn(uint256 _value) public returns (bool success) {
        require(storex.balanceOf[msg.sender] >= _value, "Insufficient balance");
        storex.totalSupply -= _value;
        storex.balanceOf[msg.sender] -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
}