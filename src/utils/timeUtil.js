const bre = require("@nomiclabs/buidler");

function now() {
	return Math.floor(new Date().getTime() / 1000);
}

async function fastForward(seconds) {
	const provider = bre.ethers.provider;

	await provider.send(
		'evm_increaseTime',
		[seconds],
	);

	await provider.send('evm_mine');
}

async function fastForwardTo(time) {
	await fastForward(time - now());
}

module.exports = {
	now,
	fastForward,
	fastForwardTo,
}
