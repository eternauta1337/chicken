const bre = require("@nomiclabs/buidler");

async function fastForward(seconds) {
	const provider = bre.ethers.provider;

	await provider.send(
		'evm_increaseTime',
		[seconds],
	);

	await provider.send('evm_mine');
}

module.exports = {
	fastForward,
}
