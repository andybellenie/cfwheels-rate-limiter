<h1>Rate Limiter</h1>
<h3>A plugin for <a href="http://cfwheels.org" target="_blank">Coldfusion on Wheels</a> by Andy Bellenie</h3>
<p>Prevent abuse of your servers by returning status 429 (Too Many Requests) once the specified number of requests has been hit (per time period).</p>
<h2>Example</h2>
<p>In the init() block of a controller, add the following before any filters (times are expressed in seconds):</p>
<pre>
rateLimiter(periodLength=3, maxRequests=10, banLength=60, allowedIPs="192.168.0.1");
</pre>
<p>The plugin runs as a filter. Ensure you call the plugin setup function before any other filters. The 'only' and 'except' arguments are passed through.</p>
<h2>Support</h2>
<p>I try to keep my plugins free from bugs and up to date with Wheels releases, but if you encounter a problem please log an issue using the tracker on Github, where you can also browse my other plugins.<br />
<a href="https://github.com/andybellenie/cfwheels-rate-limiter" target="_blank">https://github.com/andybellenie/cfwheels-rate-limiter</a></p>