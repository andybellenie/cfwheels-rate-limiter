# Rate Limiter

Prevent abuse of your servers by returning status 429 (Too Many Requests) once the specified number of requests has been hit (per time period).
##### Example

In the init() block of a controller, add the following before any filters (times are expressed in seconds):

````rateLimiter(periodLength=3, maxRequests=10, banLength=60, allowedIPs="192.168.0.1");````

The plugin runs as a filter. Ensure you call the plugin setup function before any other filters. The 'only' and 'except' arguments are passed through.