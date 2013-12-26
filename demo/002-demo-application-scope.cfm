<h1>001 Demo - Hello Application Scope</h1>
<a href="../index.cfm">Home</a><br>
<hr>

<cfdump var="#APPLICATION#" label="web application scope">

<p>
 Taken from: http://www.getrailo.org/index.cfm/whats-up/railo-40-beta-released/features/rest-services/<br>
<p/>

<cfscript>
	http url="http://localhost:8888/rest/demo/scope/application" method="GET";
	dump(var=cfhttp.filecontent, label="api application scope [statuscode: #cfhttp.statuscode#]");
</cfscript>

