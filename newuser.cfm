

<h1>Add New User Example</h1>
<cfparam name="form.username" default="">
<cfparam name="form.fname" default="">
<cfparam name="form.lname" default="">
<cfparam name="form.addr1" default="">
<cfparam name="form.addr2" default="">
<cfparam name="form.city" default="">
<cfparam name="form.state" default="">
<cfparam name="form.zip" default="">
<cfparam name="form.country" default="USA">
<cfparam name="form.phone" default="">
<cfparam name="form.phone2" default="">
<cfparam name="form.email" default="">
<cfoutput>
    <form name="frm" action="http://dev.poehler.com:8888/rest/users" method="post">
        UserName: <input type="text" name="username" value="#form.username#"><br>
        Password: <input type="text" name="password" value=""><br>
        First Name: <input type="text" name="fname" value="#form.fname#"><br>
        Last Name: <input type="text" name="lname" value="#form.username#"><br>
        Addr1: <input type="text" name="addr1" value="#form.addr1#"><br>
        Addr2: <input type="text" name="addr2" value="#form.addr2#"><br>
        City: <input type="text" name="city" value="#form.city#"><br>
        State: <input type="text" name="state" value="#form.State#"><br>
        Zip: <input type="text" name="zip" value="#form.Zip#"><br>
        Country: <input type="text" name="country" value="#form.country#"><br>
        Phone1: <input type="text" name="phone" value="#form.phone#"><br>
        Phone2: <input type="text" name="phone2" value="#form.phone2#"><br>
        e-mail: <input type="text" name="email" value="#form.email#"><br>
        type: <input type="text" name="type" value="U"><br>
        <input type="submit" value="go">
    </form>
</cfoutput>
