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
    <cfquery name="i_users" datasource="#application.datasource#">
insert into users
       (username, password, salt, fname, lname,
       addr1, addr2, city, state, zip, country,
       phone, phone2, email, status_cde, type)
values (<cfqueryparam value="#arguments.userName#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#hashedPassword#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#salt#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.fName#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.lName#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.addr1#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.addr2#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.city#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.state#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.zip#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.country#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.phone#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.phone2#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.status_cde#" cfsqltype="CF_SQL_VARCHAR">,
        <cfqueryparam value="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">)

    </cfquery>
    <cfquery name="s_new_user" datasource="#application.datasource#">
select user_id
  from users
 where username=<cfqueryparam value="#arguments.userName#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
    <cfset arguments.id = s_new_user.user_id>
<cfcatch>
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>