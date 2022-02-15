running
setUp
	super setUp.
	server := WebsideServer new.
	server
		apiClass: PowerlangWebsideAPI;
		baseUri: '/websideapitest';
		port: 9999;
		start.
	client := ZnClient new
		accept: ZnMimeType applicationJson