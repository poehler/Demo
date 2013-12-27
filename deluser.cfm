

<h1>Update User Example</h1>
<cfhttp url="http://dev.poehler.com:8888/rest/users/3" method="DELETE">
</cfhttp>
<cfoutput>#cfhttp.fileContent#</cfoutput>