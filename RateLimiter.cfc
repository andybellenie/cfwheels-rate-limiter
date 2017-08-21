<cfcomponent output="false" displayname="Rate limiting plugin for Coldfusion on Wheels">

	
	<!--- init --->

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset this.version = "1.4.5" />
		<cfreturn this />
	</cffunction>



	<!--- setup --->

	<cffunction name="rateLimiter" returntype="void" output="false" mixin="controller">
		<cfargument name="periodLength" type="numeric" required="true" hint="I am the duration of the testing period (in seconds).">
		<cfargument name="maxRequests" type="numeric" required="true" hint="I am the maximum number of requests allowed in the testing period.">
		<cfargument name="banLength" type="numeric" required="true" hint="I am the duration of the ban (in seconds).">
		<cfargument name="allowedIPs" type="string" default="" hint="I am a list of IP addresses that are ignored by the request limiter.">
		<cfargument name="only" type="string" default="" hint="See documentation for filters().">
		<cfargument name="except" type="string" default="" hint="See documentation for filters().">
		<cfargument name="$test" type="boolean" default="false">
		<cfset variables.$class.$rateLimiter = Duplicate(arguments)>
		<cfset variables.$class.$rateLimiter.periodLength = variables.$class.$rateLimiter.periodLength * 1000> <!--- convert to ms --->
		<cfset variables.$class.$rateLimiter.banLength = variables.$class.$rateLimiter.banLength * 1000> <!--- convert to ms --->
		<cfset filters(through="$rateLimiterFilter", only=arguments.only, except=arguments.except)>
	</cffunction>



	<!--- filter --->

	<cffunction name="$rateLimiterFilter" returntype="void" output="false" mixin="controller">

		<cfset local.settings = variables.$class.$rateLimiter>
		
		<cfif not ListFind(local.settings.allowedIPs, cgi.remote_addr)>
			
			<cflock name="rateLimitLock" timeout="3" throwontimeout="true">

				<cfset local.timestamp = Now().GetTime()> <!--- get current epoch time --->
				<cfset local.cachekey = Hash("RateLimiter:#cgi.remote_addr#")> <!--- create a unique cache key this ip address --->
				<cfset local.limiter = CacheGet(local.cachekey)> <!--- fetch from cache --->

				<cfif IsNull(local.limiter)> <!--- new ip, create a new limiter struct --->
					<cfset local.limiter = StructNew()>
					<cfset local.limiter.requests = ArrayNew(1)>
					<cfset local.limiter.bannedTill = "">
				<cfelseif IsNumeric(local.limiter.bannedTill) and local.limiter.bannedTill gt local.timestamp> <!--- banned --->
					<cfset local.wait = local.limiter.bannedTill - local.timestamp>
					<cfheader statuscode="429" statustext="Too Many Requests">
					<cfoutput>Too many requests, try again in #Ceiling(local.wait/1000)# seconds.</cfoutput>
					<cfabort>
				<cfelseif IsNumeric(local.limiter.bannedTill)> <!--- ban expired, reset --->
					<cfset local.limiter.requests = ArrayNew(1)>
					<cfset local.limiter.bannedTill = "">
				<cfelse> <!--- not banned, remove expired requests  --->
					<cfloop condition="#ArrayLen(local.limiter.requests)#">
						<cfif local.limiter.requests[1] + local.settings.periodLength lt local.timestamp>
							<cfset ArrayDeleteAt(local.limiter.requests, 1)>
						<cfelse>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfif>

				<!--- store this request's timestamp --->
				<cfset ArrayAppend(local.limiter.requests, local.timestamp)>

				<!--- check to see if total requests have hit the limit --->
				<cfif ArrayLen(local.limiter.requests) gte local.settings.maxRequests>
					<cfset local.limiter.bannedTill = local.timestamp + local.settings.banLength>
				</cfif>

				<!--- store in the cache for long enough to ensure a ban is fully honoured --->
				<cfset local.cacheMinutes = Ceiling(local.settings.banLength / 60000)>
				<cfset CachePut(local.cachekey, local.limiter, CreateTimeSpan(0, 0, local.cacheMinutes, 0))>

				<cfif local.settings.$test>
					<cfdump var="#local.limiter#" abort="true" showUdfs="false" />
				</cfif>

			</cflock>

		</cfif>

	</cffunction>


</cfcomponent>