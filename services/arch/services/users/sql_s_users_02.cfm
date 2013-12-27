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
    <cfquery name="s_users" datasource="#application.datasource#">
select <cfloop array="#searchColumns#" item="column">#column#,</cfloop> user_id
  from users
 where status_cde != 'Z'
   and user_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_BIGINT">
    </cfquery>

<cfcatch>
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>