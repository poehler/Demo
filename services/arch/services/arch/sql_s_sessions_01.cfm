 <cftry>
    <cfquery name="s_sessions" datasource="#application.datasource#">
select a.session_date, b.user_id, b.type
  from sessions a inner join users b on a.user_id = b.user_id
 where a.user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_BIGINT">
   and a.session_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
   and a.session_date > date_add(now(), INTERVAL -5 DAY)
   and b.status_cde = 'A'
    </cfquery>
<cfcatch>
    <cfthrow message="#getFileFromPath(getCurrentTemplatePath())# #cfcatch.message#"
             detail="#cfcatch.detail#">
</cfcatch>
</cftry>