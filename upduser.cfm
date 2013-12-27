

<h1>Update User Example</h1>
<cfhttp url="http://dev.poehler.com:8888/rest/users" method="PUT">
    <cfhttpparam type="header" name="id" value="1">
    <cfhttpparam type="header" name="password" value="test">
    <cfhttpparam type="header" name="password2" value="test">
</cfhttp>
<cfoutput>#cfhttp.fileContent#</cfoutput>