pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	/* State variables */
	uint8 sizeLimit = 5;
	uint8 currentSize;
	address[] queue;
	uint time_limit = 5 minutes; // arbitrary time limit
	uint timestamp;


	/* Add events */
	event Ejected(address ejected);

	/* Constructor */
	function Queue() {
		currentSize = 0;
	}

	/* Returns the number of people waiting in line */
	function qsize() constant returns(uint8) {
		return currentSize;
	}

	function qSizeLimit() constant returns(uint8) {
		return sizeLimit;
	}

	/* Returns whether the queue is empty or not */
	function empty() constant returns(bool) {
		return (currentSize == 0);
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() constant returns(address) {
		if (currentSize > 0) {
			return queue[0];
		}
		return address(0);
	}

	/* Check if there is a second person in queue behind the first. */
	function isSecond() constant returns(bool) {
		return currentSize >= 2;
	}
	
	/* Allows `msg.sender` to check their position in the queue.
	Returns -1 if 'msg.sender' not in queue.*/
	function checkPlace() constant returns(uint8) {
		for (uint8 i = 0; i < currentSize; i++) {
			if (queue[i] == msg.sender) {
				return i + 1;
			}
		}
		return 0;
	}
	
	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() {
		if (!empty()) {
			if (now - timestamp > time_limit) {
				dequeue();
			}
		}
	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase.
	 */
	function dequeue() {
		if (empty()) {
		} else {
			for (uint i = 1; i < currentSize; i++) {
				queue[i - 1] = queue[i];
			}
			queue[currentSize - 1] = address(0);
			currentSize -= 1;
			timestamp = now;
		}
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) external {
		if (currentSize >= sizeLimit) {
			return;
		} else {
			if (qsize() == 0) {
				timestamp = now;
			}
			queue.push(addr);
			currentSize = currentSize + 1;	
		}
	}
}
