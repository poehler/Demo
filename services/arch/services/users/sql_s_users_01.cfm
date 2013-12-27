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
<cfif len(arguments.search) gt 0>
   and (
    <cfloop array="#searchColumns#" item="column">
        #column# like '#arguments.search#%' or
    </cfloop>
        1 = 0
    )
</cfif>
 order by #arguments.sort#
    </cfquery>
<cfcatch>
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>