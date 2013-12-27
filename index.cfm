<h1>Railo Ember Example</h1>

<ol>
    <li><a href="demo/001-demo-hello-railo.cfm">Hello Railo</a></li>
    <li><a href="demo/002-demo-application-scope.cfm">Hello Application Scope</a></li>
</ol>
<cfhttp url="http://dev.poehler.com:8888/rest/users" method="GET">
    <cfhttpparam type="header" name="user_id" value="1">
    <cfhttpparam type="header" name="session_id" value="TestNOT">
</cfhttp>
<cfoutput>#cfhttp.fileContent#</cfoutput>