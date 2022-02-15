initialization
initializeRuntime
	| image |
	image := VirtualSmalltalkImage fromSpec
		wordSize: 8;
		genesis.
	runtime := VirtualSmalltalkRuntime new
		image: image;
		initializeClassPools