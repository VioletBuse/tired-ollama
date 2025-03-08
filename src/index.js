const yargs = require("yargs/yargs")

const argv = yargs(process.argv)

const idle_time = argv.idle;
const origin = argv.origin;
const port = argv.port;
const wait = argv.wait;

const httpProxy = require("http-proxy");

const proxy = httpProxy.createProxyServer()
