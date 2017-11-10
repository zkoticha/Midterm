pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	/* State variables */
	uint8 size = 5;
	address[] queue;
	uint time_limit = 5 minutes; // arbitrary time limit
	uint front_queue_timestamp;

	/* Add events */
	event Ejected(address ejected);

	/* Constructor */
	function Queue() {}

	/* Returns the number of people waiting in line */
	function qsize() constant returns(uint8) {
		return uint8(queue.length);
	}

	/* Returns whether the queue is empty or not */
	function empty() constant returns(bool) {
		return queue.length == 0;
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() constant returns(address) {
		// TODO: handle case when no one in queue
		if (queue.length != 0) {
			return queue[0];
		}
	}

	/* Check if there is a second person in queue behind the first. */
	function isSecond() constant returns(bool) {
		return queue.length >= 2;
	}
	
	/* Allows `msg.sender` to check their position in the queue.
	Returns -1 if 'msg.sender' not in queue.*/
	function checkPlace() constant returns(int8) {
		for (uint8 i = 0; i < size; i++) {
			if (queue[i] == msg.sender) {
				return int8(i);
			}
		}
		return -1;
	}
	
	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() {
		if (!empty()) {
			if (now - front_queue_timestamp > time_limit) {
				address ejected = dequeue();
				Ejected(ejected);
			}
		}
	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase.
	 */
	function dequeue() returns (address) {
		if (empty()) {
			return;
		}
		address ejected = queue[0];
		// Not too sure about code below; might be very buggy
		for (uint i = 0; i < queue.length - 1; i++) {
			queue[i] = queue[i + 1];
		}
		delete queue[queue.length - 1];
		queue.length--;
		return ejected;
		// TODO: Remember to reset the timestamp!
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) {
		if (queue.length < size) {
			queue.push(addr);
		}
	}
}
