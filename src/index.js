const nodeHttp = require("http");
const httpProxy = require("http-proxy");
const wait_on = require("wait-on");

const serve = async ({ idle_time, origin, port, wait, api_key }) => {

  const proxy = httpProxy.createProxyServer({
    target: origin,
  });

  let first_req = true;

  const server = nodeHttp.createServer(async function (req, res) {


    if (first_req) {
      try {
        await wait_on({
          resources: [origin],
          timeout: wait * 1000,
        });
      } catch (err) {
        console.log(`Couldn't reach ${origin} within ${wait} seconds, exiting.`);
        process.exit(1);
      }

      first_req = false
    }

    console.log(`${req.url}`);

    if (api_key && req.headers.authorization.trim() !== `Bearer ${api_key}`) {
      res.statusCode = 401;
      res.end();
      return;
    }

    proxy.web(req, res);
  });

  server.on("upgrade", function (req, socket, head) {
    proxy.ws(req, socket, head);
  });

  // number of inflight requests
  let active_requests = 0;
  let last_inactive = Date.now();

  proxy.on("proxyReq", function () {
    active_requests += 1;
  });

  proxy.on("proxyRes", function () {
    if (active_requests > 0) {
      active_requests -= 1;
    }

    if (active_requests <= 0) {
      last_inactive = Date.now();
    }
  });

  proxy.on("open", function () {
    active_requests += 1;
  });

  proxy.on("close", function () {
    if (active_requests > 0) {
      active_requests -= 1;
    }

    if (active_requests <= 0) {
      last_inactive = Date.now();
    }
  });

  const monitor_inactivity = () => {
    if (last_inactive + idle_time * 1000 < Date.now() && active_requests <= 0) {
      const time_inactive = (Date.now() - last_inactive) / 1000;
      console.log(
        `Proxy detected no activity since ${time_inactive} seconds, exiting.`
      );
      process.exit(0);
    }

    setTimeout(monitor_inactivity, 5_000);
  };

  monitor_inactivity();

  server.listen(port);
};

require("yargs")
  .scriptName("tired-ollama-proxy")
  .env("OLLAMA_PROXY")
  .usage("$0 <cmd> [args]")
  .command(
    "serve [args]",
    "proxy connection to ollama",
    (yargs) => {
      yargs.option("p", {
        alias: "port",
        describe: "The port to listen at.",
        type: "number",
        default: 8080,
      });

      yargs.option("i", {
        alias: "idle-time",
        describe: "The number of seconds to wait for a request before exiting.",
        type: "number",
        default: 20,
      });

      yargs.option("o", {
        alias: "origin",
        describe: "The url of the ollama server to proxy requests to.",
        type: "string",
        default: "http://localhost:11434",
      });

      yargs.option("w", {
        alias: "wait",
        describe:
          "The number of seconds to wait for the port to open before listening.",
        type: "number",
        default: 10,
      });

      yargs.option("k", {
        alias: "api_key",
        describe:
          "Check the Authorization header for a bearer token matching this, if present.",
        type: "string",
      });
    },
    function (argv) {
      serve({
        idle_time: argv.idleTime,
        origin: argv.origin,
        port: argv.port,
        wait: argv.wait,
        api_key: argv["api_key"],
      });
    }
  )
  .help().argv;
