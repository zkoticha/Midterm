pragma solidity ^0.4.15;

import './Queue.sol';
import './Token.sol';
import './utils/SafeMath.sol';

/**
 * @title Crowdsale
 * @dev Contract that deploys `Token.sol`
 * Is timelocked, manages buyer queue, updates balances on `Token.sol`
FROM GITHUB:
Must deploy Token.sol
The contract must keep track of how many tokens have been sold
The contract must only sell to/refund buyers between start-time and end-time
The contract must forward all funds to the owner after sale is over
Owner:
	Must be set on deployment
	Must be able to time-cap the sale
	Must keep track of start-time
	Must keep track of end-time/time remaining since start-time
	Must be able to specify an initial amount of tokens to create
	Must be able to specify the amount of tokens 1 wei is worth
	Must be able to mint new tokens
		This amount would be added to totalSupply in Token.sol
	Must be able to burn tokens not sold yet
		This amount would be subtracted from totalSupply in Token.sol
	Must be able to receive funds from contract after the sale is over
Buyers:
	Must be able to buy tokens directly from the contract and as long as the sale has not ended, if they are first in the queue and there is someone waiting line behind them
		This would change their balance in Token.sol
		This would change the number of tokens sold
	Must be able to refund their tokens as long as the sale has not ended. Their place in the queue does not matter
		This would change their balance in Token.sol
		This would change the number of tokens sold
Events:
	Fired on token purchase
	Fired on token refund
 */

contract Crowdsale {
	// YOUR CODE HERE
	address _owner;
	uint start_time;
	uint tokenSupply;
	uint time_cap;
	//When do we initialize q?
	Queue q;
	Token token;

	//the amount of tokens 1 wei is worth
	uint tokenPrice;

	event TokensSold(uint numTokens);


	//Ensure that tokenPrice is in wei
	function Crowdsale (uint timeCap, uint initTokenSupply, uint initTokenPrice){
		_owner = tx.origin;
		//I can imagine this will matter, might have to be block.number+constant
		assert (timeCap > block.number);

		start_time 	= block.number;
		tokenSupply = initTokenSupply;
		tokenPrice	= initTokenPrice;
		token = new Token(tokenSupply);
		q = new Queue();
	}

	function mintTokens(uint numTokensToAdd) {
		//tx.origin or msg.sender?
		require(msg.sender == _owner);
		token.totalSupply.add(numTokensToAdd);
	}

	function burnTokens(uint numTokensToBurn) {
		//THIS IMPLIES THAT TOKEN.SOL MUST SPECIFY ITS OWNER
		//TODO: assert(numTokensToBurn< NUM_UNSOLD_TOKENS);
		//tx.origin or msg.sender?
		require(msg.sender == _owner);
		token.tokenSupply.sub(numTokensToBurn);
	}

	function redeemFunds() {
		//TODO: tx.origin or msg.sender?
		assert(msg.sender == _owner);
		//_owner.transfer(this.balance);
	}


	function buyTokens(){
		require(q.getFirst() == msg.sender);
		//TODO: What do if no time_cap?
		require(block.number > time_cap.add(start_time));
		//TODO: Legeng, can you implement isSecond() to check if person behind?
		require (q.qsize() > 1);
		//TODO: CHECK TO MAKE SURE THEY'VE SENT ENOUGH ETHER

		uint tokensToPurchase = msg.value.div(tokenPrice);

		//	This would change their balance in Token.sol
		token.balances[msg.sender].add(tokensToPurchase);

		//	This would change the number of tokens sold
		tokenSupply.add(tokensToPurchase);

		TokensSold(tokensToPurchase);

	}

	//Fallback function (do not delete!!!)
	function () payable {}

}
