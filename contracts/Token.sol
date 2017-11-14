 pragma solidity ^0.4.15;

import './interfaces/ERC20Interface.sol';
import '.Crowdsale.sol';
/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

contract Token is ERC20Interface {
	// YOUR CODE HERE
  uint256 public totalSupply;
  mapping (address => uint256) balances;
  //mapping (address => uint256) innerAllowance; //amount of funds which address can tranfer on behalf of some person
  mapping (address => mapping(address => uint256)) allowances; //key is person whose money is being spent, value is map of person spending --> max they can spend)

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  //constructor
  function Token(uint256 _totalSupply){
    totalSupply = _totalSupply;
  }

  function balanceOf(address _owner) constant returns (uint256 balance){
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success){
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
    if (allowances[_from][msg.sender] >=_value && balances[_from] >= _value && _value > 0) {
      allowances[_from][msg.sender] -= _value;
      //I decided to decrease allowances first after looking at the gnosis contract
      //they opted to first decrease _from's balance, which  creates a race conditions
      //vulernability in which msg.sender is able to transfer more of _from's money than
      //is dictated by allowances[_from][_to]
      balances[_from] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  function approve(address _spender, uint256 _value) returns (bool success){
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining){
    return allowances[_owner][_spender];
  }


}
