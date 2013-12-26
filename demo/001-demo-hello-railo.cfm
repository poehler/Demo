<h1>001 Demo - Hello Railo</h1>
<a href="../index.cfm">Home</a><br>
<hr>

<cfoutput>
<p>#ExpandPath('/api')#</p>
</cfoutput>

<p>
 Taken from: http://www.getrailo.org/index.cfm/whats-up/railo-40-beta-released/features/rest-services/<br>
<p/>

<cfscript>
http url="http://localhost:8888/rest/demo/hello/" method="GET";
dump(cfhttp);

http url="http://localhost:8888/rest/demo/hello/railo-url" method="GET";
dump(cfhttp);

http url="http://localhost:8888/rest/demo/hello/" method="POST" {
	httpparam name="a" value="railo-form" type="formField";
}
dump(cfhttp);
</cfscript>

