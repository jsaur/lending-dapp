# Lending dApp

## Installation

1. Install [Truffle](http://truffleframework.com) and an Ethereum client - like [EthereumJS TestRPC](https://github.com/ethereumjs/testrpc). Note I couldn't get this to work on our VMs so I installed them directly on the Mac.
	```
	[sudo] npm install -g truffle // Version 3.0.5+ required.
	[sudo] npm install -g ethereumjs-testrpc
	```

2. Pull down the repo and install dependancies
	```
	git clone https://github.com/jsaur/lending-dapp
	npm install
	```

3. Launch [`testrpc`](https://github.com/ethereumjs/testrpc) in it's own command prompt tab.
	```
	testrpc <options>
	```

4. Compile and migrate the contracts.
	```
	truffle compile
	truffle migrate
	``` 

4. Run the webpack server for front-end hot reloading. Smart contract changes do not support hot reloading for now.
	```
	npm run start
	```
    
## Tests
This box comes with everything bundled for `unit`, `e2e` and `truffle` contracts testing.

1. `unit` and `e2e` tests.
	```
	npm run test/dapp
	```

2. `truffle` contracts tests.
	```
	npm run test/truffle
	```

3. Alternatively you can directly run `unit`, `e2e` and `truffle` contracts tests in one command.
	```
	npm run test
	```

## Build for production
To build the application for production, use the build command. A production build will be compiled in the `dist` folder.
```javascript
npm run build
```

## Metamask

1. Install Metamask in your browser: https://metamask.io/

2. Change network to: Localhost 8545

3. Import address based on private key, using one of the keys generated initially by testrpc

## Browser solidity

I find that writing, compiling and testing solidity smart contracts is easiest using: https://ethereum.github.io/browser-solidity/

## Mist

1. Launch Mist against your private network. Need to download it for your Mac first. Install location may vary.
	```
	cd /Volumes/Macintosh HD/Applications/Mist.app/Contents/MacOS
	./Mist --rpc localhost:8545
	```

2. Add contract
	The address and name are created when running truffle migrate
	The json interface can be found under build/contracts, the section under "abi"

Note: I've found Mist on testrpc to only be useful for reads - writes fail with a "_signAndSendTransaction not supported" error that seems to be an outstanding Mist issue.

## Possible error resolutions

1. If you're getting npm errors try:
	```
	npm update --scripts-prepend-node-path=auto
	```

2. If you're getting 'out of gas' errors, increase the gas in truffle.js 
	```
	gas: 460000000
	```

3. If you're getting 'Exceeds block gas limit' errors, increase the gas limit on testrpc
	```
	testrpc --gasLimit 50000000
	```

4. If you're getting 'invalid opt code' errors, try starting over
	```
	truffle compile
	truffle migrate --reset
	```

5. If you're getting javascript errors when interacting with you contracts, double check the 'abi' section of your contract json in /build/contracts. Sometimes truffle compile doesn't update these properly and you need to manually make the input/output arguements match what's actually in your solidity contracts. I've saved a backup of the abi in build/contracts/LoanContract.abi.bak, but this is really just a hack, I probably need to file an issue with truffle.

