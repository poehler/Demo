<!---
<fusedoc fuse="sql_i_audit_trails_01.cfm" language="ColdFusion" version="2.0">
	<responsibilities>
		This template generates and executes an update query.
	</responsibilities>
    <properties>
		<history author="Jimbo"
				 date="8/26/2011"
				 role="Architect"
				 type="Create"
		/>
    </properties>
	<io>
		<in>
		</in>
		<out>
		</out>
	</io>
</fusedoc>
--->
<cftry>
    <cfif not isValid("numeric", arguments.user_id)>
        <cfset arguments.user_id = 0>
    </cfif>
    <cfif not isDefined("arguments.location_id") or not isValid("numeric", arguments.location_id)>
        <cfset arguments.location_id = 0>
    </cfif>
    <cfif not isDefined("arguments.gateway_id") or not isValid("numeric", arguments.gateway_id)>
        <cfset arguments.gateway_id = 0>
    </cfif>
    <cfif not isDefined("arguments.device_id") or not isValid("numeric", arguments.device_id)>
        <cfset arguments.device_id = 0>
    </cfif>
    <cfif not isDefined("arguments.channel_id") or not isValid("numeric", arguments.channel_id)>
        <cfset arguments.channel_id = 0>
    </cfif>
    <cfquery name="i_audit_messages" datasource="#application.datasource#">
insert into audit_messages
       (user_id, type, msg, location_id, gateway_id, device_id, channel_id, audit_date)
values (<cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_BIGINT">,
        <cfqueryparam value="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#left(arguments.message, 5000)#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.location_id#" cfsqltype="CF_SQL_BIGINT">,
        <cfqueryparam value="#arguments.gateway_id#" cfsqltype="CF_SQL_BIGINT">,
        <cfqueryparam value="#arguments.device_id#" cfsqltype="CF_SQL_BIGINT">,
        <cfqueryparam value="#arguments.channel_id#" cfsqltype="CF_SQL_BIGINT">,
        now())
    </cfquery>

<cfcatch>
    <cfdump var="#cfcatch#">
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>