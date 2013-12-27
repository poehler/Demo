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
    <cfquery name="u_users" datasource="#application.datasource#">
update users
   set
<cfif isDefined("hashedPassword")>
       password = <cfqueryparam value="#hashedPassword#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("salt")>
       salt = <cfqueryparam value="#salt#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.fName") and len(trim(arguments.fName)) gt 0>
       fname = <cfqueryparam value="#arguments.fName#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.lName") and len(trim(arguments.lName)) gt 0>
       lName = <cfqueryparam value="#arguments.lName#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.addr1") and len(trim(arguments.addr1)) gt 0>
       addr1 = <cfqueryparam value="#arguments.addr1#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.addr2")>
       addr2 = <cfqueryparam value="#arguments.addr2#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.city") and len(trim(arguments.city)) gt 0>
       city = <cfqueryparam value="#arguments.city#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.state") and len(trim(arguments.state)) gt 0>
       state = <cfqueryparam value="#arguments.state#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.zip") and len(trim(arguments.zip)) gt 0>
       zip = <cfqueryparam value="#arguments.zip#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.country") and len(trim(arguments.country)) gt 0>
       country = <cfqueryparam value="#arguments.country#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.phone")>
       phone = <cfqueryparam value="#arguments.phone#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.phone2")>
       phone2 = <cfqueryparam value="#arguments.phone2#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.email")>
       email = <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.type") and len(trim(arguments.type)) eq 1>
       type = <cfqueryparam value="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
<cfif isDefined("arguments.status_cde") and len(trim(arguments.status_cde)) eq 1>
       status_cde = <cfqueryparam value="#arguments.status_cde#" cfsqltype="CF_SQL_VARCHAR">,
</cfif>
       username = username
 where user_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_BIGINT">

    </cfquery>
<cfcatch>
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>