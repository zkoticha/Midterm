'use strict';

/* Add the dependencies you're testing */
const Queue = artifacts.require("./Queue.sol");

contract('Queue Test', function(accounts) {
	/* Define your constant variables and instantiate constantly changing 
	 * ones
	 */
	let queue;

	/* Do something before every `describe` method */
	beforeEach(async function() {
		queue = await Queue.new();
	});

	/* Group test cases together 
	 * Make sure to provide descriptive strings for method arguements and
	 * assert statements
	 */
	describe('Queue works', function() {
		it("Initializes new queue", async function() {
			let queue_size = await queue.qsize();
			assert.equal(queue_size.valueOf(), 0, "queue size should be 0 when first initialized");
		});

		it("Check is queue is empty", async function() {
			let queue_size = await queue.qsize();
			assert.equal(queue_size.valueOf(), 0, "queue size should be 0 when first initialized");
			assert.equal(await queue.empty(), true, "queue should be empty when first initilized");
			await queue.enqueue(accounts[0]);
			assert.equal(await queue.empty(), false, "queue should not be empty after enqueing.");
		});

		it("Enqueues new address to queue", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			await queue.enqueue(accounts[2]);
			await queue.enqueue(accounts[3]);
			let size = await queue.qsize();
			assert.equal(size, 4, "queue size should be 4.");
		});

		it("Gets first address in queue", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			assert.equal(await queue.qsize(), 2, "queue size should be 2");
			let first = await queue.getFirst();
			assert.equal(first, accounts[0], "queue should return first elem.");
		});

		it("Checks if second person exists in queue", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			assert.equal(await queue.isSecond(), true, "there should be second person in queue.");
		});

		it("Cannot enqueue more address than limit allows", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			await queue.enqueue(accounts[2]);
			await queue.enqueue(accounts[3]);
			await queue.enqueue(accounts[4]);
			await queue.enqueue(accounts[5]);
			assert.equal(await queue.qsize().valueOf(), 5, "there should be 5 people in queue.");
			await queue.enqueue(accounts[6]);
			await queue.enqueue(accounts[7]);
			assert.equal(await queue.qsize().valueOf(), 5, "there should be 5 people in queue.");
		});

		it("Dequeues the first address", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			await queue.enqueue(accounts[2]);
			await queue.enqueue(accounts[3]);

			assert.equal(await queue.qsize().valueOf(), 4, "there should be 4 people in queue.");

			assert.equal(await queue.empty(), false, "queue should not be emtpy.");

			await queue.dequeue();
			assert.equal(await queue.qsize().valueOf(), 3, "there should be 3 people in queue.");
			assert.equal(await queue.getFirst(), accounts[1]);

			await queue.dequeue();
			assert.equal(await queue.qsize().valueOf(), 2, "there should be 2 people in queue.");
			assert.equal(await queue.getFirst(), accounts[2]);

			await queue.dequeue();
			assert.equal(await queue.qsize().valueOf(), 1, "there should be 1 person in queue.");
			assert.equal(await queue.getFirst(), accounts[3]);

			await queue.dequeue();
			assert.equal(await queue.qsize().valueOf(), 0, "there should be 0 people in queue.");
			assert.equal(await queue.empty(), true);

		});

		it("Checks the place in queue", async function() {
			await queue.enqueue(accounts[0]);
			await queue.enqueue(accounts[1]);
			await queue.enqueue(accounts[2]);
			await queue.enqueue(accounts[3]);
			
			let position1 = await queue.checkPlace.call({from: accounts[0]});
			assert.equal(position1, 1, "account[0] should be 1st in queue");
			let position4 = await queue.checkPlace.call({from: accounts[4]});
			assert.equal(position4, 0, "account[4] should not be in queue");
			let position2 = await queue.checkPlace.call({from: accounts[2]});
			assert.equal(position2, 3, "account[2] should be 3rd in queue");
		});

	});
});