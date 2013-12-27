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
<cfcomponent output="false">

    <!--- public properties --->


    <!--- private properties --->

    <!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->
    <!--- PUBLIC METHODS                                                    --->
    <!--- ----------------------------------------------------------------- --->
    <!--- ----------------------------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="changePassword">
        <responsibilities>
            This method changes a user's password.  To change the password the
            following conditions must be met:
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_name" optional="yes" comments="The user name of the user requesting the password change" />
                <integer name="arguments.password" optional="yes" comments="The password of the user requesting the password change" />
                <integer name="arguments.usr_id" optional="no" comments="The id of the account being updated" />
                <string name="arguments.orig_password" optional="no" comments="The original password" />
                <string name="arguments.new_password" optional="no" comments="The new password" />
                <string name="arguments.new_password2" optional="no" comments="The new password again" />
                <string name="arguments.hint" optional="no" comments="A hint to help the user remember their password" />
                <integer name="session.user" optional="no" comments="The user calling this method must be logged in" />
            </in>
            <out>
                <boolean name="rtn" comments="Either true or false" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="changePassword" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="requestor_user_name" default="">
        <cfargument name="requestor_password" default="">
        <cfargument name="usr_id">
        <cfargument name="orig_password">
        <cfargument name="new_password">
        <cfargument name="new_password2">
        <cfargument name="hint">

        <!--- local variables --->
        <cfset var lst_upd_id = 0>
        <cfset var requestor_user_type = "">
        <cfset var check_original = "true">

        <cftry>

            <!--- If they passed in a user name and password make sure they sent it encrypted --->
            <cfif (len(arguments.requestor_user_name) gt 0 or len(arguments.requestor_password) gt 0) and cgi.http eq "off">

                <!--- The user name and password were set in uncrypted --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method changePassword was called with no encryption">
                </cfinvoke>
                <cfreturn false>

            </cfif>

            <!--- Set the lst_upd_id based on either a username/pw or session object --->
            <cfif len(arguments.requestor_user_name) gt 0 and len(arguments.requestor_password) gt 0>
                <cfset lst_upd_id = validateUser(arguments.requestor_user_name, arguments.requestor_password)>
            <cfelseif isDefined("session.user")>
                <cfset lst_upd_id = session.user.getUsr_Id()>
            </cfif>

            <!--- Make sure the user calling the method is valid --->
            <cfif lst_upd_id eq 0>

                <!--- The user name and password were invalid --->
                <cfinvoke component="arch.Audit" method="logAction">
	                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method changePassword was called with invalid security credentials (#arguments.requestor_user_name#)">
                </cfinvoke>
                <cfreturn false>

            </cfif> <!--- DONE checking validity of user --->

            <!--- Check to see if the user is authorized to update this password --->
	        <cfset requestor_user_type = getUserType(lst_upd_id)>
            <cfif lst_upd_id eq arguments.usr_id>
                <!--- Trying to update own password, this is OK --->
            <cfelseif findNoCase("A", requestor_user_type) gt 0>
                <!--- Administrator trying to update password, this is OK --->
            <cfelseif findNoCase("B", requestor_user_type) gt 0>
                <!--- HC Engineering trying to update password, this is OK --->
            <cfelseif findNoCase("C", requestor_user_type) gt 0>
                <!--- HC Sales trying to update password, this is OK --->
            <cfelseif (findNoCase("D", requestor_user_type) gt 0 or findNoCase("D", requestor_user_type) gt 0) and listFind(getDependents(lst_upd_id), arguments.usr_id) gt 0>
                <!--- Grandparent or Parent trying to update password for a child account, this is OK --->
                <!--- Flip the check_original flag --->
                <cfset check_original = false>
            <cfelse>

                <!--- The user wasn't trying to update their own password and they weren't an administrator --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="User #arguments.requestor_user_name# (#lst_upd_id#) attempted to change the password for #arguments.usr_id# listFind(getDependents(arguments.usr_id), arguments.usr_id) :: #listFind(getDependents(arguments.usr_id), arguments.usr_id)# :: listFind(#getDependents(lst_upd_id)#, #arguments.usr_id#)">
                </cfinvoke>
                <cfreturn false>

            </cfif><!--- DONE checking to see if the caller is authorized to update the password --->

            <!--- Make sure the two new passwords match --->
            <cfif arguments.new_password neq arguments.new_password2>

                <!--- The two new passwords didn't match --->
                <cfinvoke component="arch.Audit" method="logAction">
	                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="WARNING">
                    <cfinvokeargument name="message" value="The password for #arguments.usr_id# could not be changed because the new passwords did not match">
                </cfinvoke>
                <cfreturn false>

            </cfif><!--- Checking to make sure two new passwords match --->

            <!--- Do any additional password checking here --->


            <!--- Get the current password from the database --->
            <cfinclude template="sql_s_users_02.cfm">

            <!--- Was a record found? --->
            <cfif s_users.recordCount eq 0>

                <!--- No --->
                <cfinvoke component="arch.Audit" method="logAction">
	                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="No account could be found for #arguments.usr_id# for a password change">
                </cfinvoke>
                <cfreturn false>

            <cfelse>

                <!--- Check the original password against what is on file.  This will be skipped for admins. --->
	            <cfif findNoCase("A", requestor_user_type) eq 0>
	                <!--- Administrator trying to update password, this is OK --->
	            <cfelseif findNoCase("B", requestor_user_type) gt 0>
	                <!--- HC Engineering trying to update password, this is OK --->
	            <cfelseif findNoCase("C", requestor_user_type) gt 0>
	                <!--- HC Sales trying to update password, this is OK --->
                <cfelse>
                    <cfset var original_is_valid = false>
	                <cfif not check_original>
	                    <!--- This is a parent or grandparent.  Check the orig_password with the lst_upd_id to determine if the password is correct --->
                        <cfinclude template="sql_s_users_05.cfm">
						<cfset original_is_valid = checkPassword(arguments.orig_password, s_requestor_info.password, s_requestor_info.salt)>
	                <cfelse>
						<cfset original_is_valid = checkPassword(arguments.orig_password, s_users.password, s_users.salt)>
		            </cfif> <!--- DONE checking original password against what is on file --->

                    <cfif not original_is_valid>
		                <!--- The original password didn't match what was on file --->
	                    <cfinvoke component="arch.Audit" method="logAction">
			                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
		                    <cfinvokeargument name="device_id" value="0">
		                    <cfinvokeargument name="type" value="SECURITY">
		                    <cfinvokeargument name="message" value="The password for #arguments.usr_id# could not be changed because the orig password did not match">
	                    </cfinvoke>
		                <cfreturn false>
                    </cfif>

	            </cfif> <!--- DONE checking original password against what is on file --->

                <!--- Hash the new password --->
		        <cfset var crypto = createObject('component', 'arch.Crypto') />
	            <cfset var salt = crypto.genSalt() />
		        <cfset var hashed_password = crypto.computeHash(arguments.new_password, salt) />

                <!--- Update the user record --->
                <cfinclude template="sql_u_users_02.cfm">
                <cfinvoke component="arch.Audit" method="logAction">
	                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="INFORMATION">
                    <cfinvokeargument name="message" value="The password for #arguments.usr_id# was changed">
                </cfinvoke>

		        <cfreturn true>

            </cfif> <!--- DONE processing a found record --->
        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="11">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The password for #arguments.usr_id# could not be changed because of exceptions.  MSG = #cfcatch.message#, DTL = #cfcatch.detail#">
            </cfinvoke>
            <cfreturn false>
        </cfcatch></cftry>

    </cffunction>
    <!--- END changePassword ---------------------------------------------  --->

    <!--- ----------------------------------------------------------------------
    <method name="insertUser">
        <responsibilities>
            This method inserts a new user record into the users table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_name" optional="yes" comments="The user name of the account trying to create the new user" />
                <integer name="arguments.password" optional="yes" comments="The password of the account trying to create the new user" />
                <string name="arguments.new_user_name" optional="no" comments="The user name of the new user" />
                <string name="arguments.new_password" optional="no" comments="The new password" />
                <string name="arguments.hint" optional="yes" comments="A hint to help the user remember their password" />
                <string name="arguments.user_type" optional="no" comments="The code for the user type" />
                <string name="arguments.name" optional="yes" comments="The name of the user" />
                <string name="arguments.company" optional="yes" comments="The company of the user" />
                <string name="arguments.email" optional="yes" comments="The e-mail address of the user" />
                <string name="arguments.phone" optional="yes" comments="The phone number of the user" />
                <string name="arguments.addr1" optional="yes" comments="The address of the user" />
                <string name="arguments.addr2" optional="yes" comments="The secondary address of the user" />
                <string name="arguments.city" optional="yes" comments="The city of the user" />
                <string name="arguments.state" optional="yes" comments="The state of the user" />
                <string name="arguments.zip" optional="yes" comments="The zip code of the user" />
            </in>
            <out>
                <integer name="usr_id" comments="The usr_id of the new record" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="createUser" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="user_name">
        <cfargument name="password">
        <cfargument name="hint" required="no" default="">
        <cfargument name="user_type">
        <cfargument name="name" required="no" default="">
        <cfargument name="company" required="no" default="">
        <cfargument name="email" required="no" default="">
        <cfargument name="phone" required="no" default="">
        <cfargument name="fax" required="no" default="">
        <cfargument name="pager" required="no" default="">
        <cfargument name="addr1" required="no" default="">
        <cfargument name="addr2" required="no" default="">
        <cfargument name="city" required="no" default="">
        <cfargument name="state" required="no" default="">
        <cfargument name="zip" required="no" default="">
        <cfargument name="country" required="no" default="">

        <!--- local variables --->
        <cfset var lst_upd_id = 0>

        <cftry>

            <!--- If they passed in a user name and password make sure they sent it encrypted --->
            <cfif isDefined("session.user")>
                <cfset lst_upd_id = session.user.getUsr_Id()>
            </cfif>

            <!--- Make sure the user calling the method is valid --->
            <cfif lst_upd_id eq 0>

                <!--- The user name and password were invalid --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method insertUser was called with invalid security credentials">
                </cfinvoke>
                <cfreturn false>

            </cfif> <!--- DONE checking validity of user --->

            <!--- Encrypt the password --->
            <cfset var crypto = createObject('component', 'arch.Crypto') />
            <cfset var salt = crypto.genSalt() />
            <cfset var hashed_password = crypto.computeHash(arguments.password, salt) />

            <!--- Attempt the insert --->
            <cfinclude template="sql_i_users_01.cfm">

            <!--- Log the event --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="INFORMATION">
                <cfinvokeargument name="message" value="A new user was created for #arguments.user_name# ()">
            </cfinvoke>

            <!--- Return the new usr_id value --->
            <cfreturn s_users.usr_id>

        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="A new account could not be created #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>
            <cfreturn "A new account could not be created. #cfcatch.message# #cfcatch.detail#">
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END insertUser -------------------------------------------------  --->


    <!--- ----------------------------------------------------------------------
    <method name="updateUser">
        <responsibilities>
            This method updates an existing user record into the users table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.requestor_user_name" optional="yes" comments="The user name of the account trying to create the new user" />
                <integer name="arguments.requestor_password" optional="yes" comments="The password of the account trying to create the new user" />
                <string name="arguments.usr_id" optional="no" comments="The ID of the user" />
                <string name="arguments.user_name" optional="no" comments="The user name of the user" />
                <string name="arguments.user_type" optional="no" comments="The code for the user type" />
                <integer name="arguments.status_cde" optional="no" comments="The status of the user" />
                <string name="arguments.name" optional="yes" comments="The name of the user" />
                <string name="arguments.company" optional="yes" comments="The company of the user" />
                <string name="arguments.email" optional="yes" comments="The e-mail address of the user" />
                <string name="arguments.phone" optional="yes" comments="The phone number of the user" />
                <string name="arguments.addr1" optional="yes" comments="The address of the user" />
                <string name="arguments.addr2" optional="yes" comments="The secondary address of the user" />
                <string name="arguments.city" optional="yes" comments="The city of the user" />
                <string name="arguments.state" optional="yes" comments="The state of the user" />
                <string name="arguments.zip" optional="yes" comments="The zip code of the user" />
            </in>
            <out>
                <boolean name="" comments="Whether the record was updated or not" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="updateUser" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="requestor_user_name" default="">
        <cfargument name="requestor_password" default="">
        <cfargument name="usr_id">
        <cfargument name="user_name">
        <cfargument name="user_type">
        <cfargument name="status_cde">
        <cfargument name="name" required="no" default="">
        <cfargument name="company" required="no" default="">
        <cfargument name="email" required="no" default="">
        <cfargument name="phone" required="no" default="">
        <cfargument name="addr1" required="no" default="">
        <cfargument name="addr2" required="no" default="">
        <cfargument name="city" required="no" default="">
        <cfargument name="state" required="no" default="">
        <cfargument name="zip" required="no" default="">

        <!--- local variables --->
        <cfset var lst_upd_id = 0>
        <cfset var requestor_user_type = "">

        <cftry>

            <!--- If they passed in a user name and password make sure they sent it encrypted --->
            <cfif (len(arguments.requestor_user_name) gt 0 or len(arguments.requestor_password) gt 0) and cgi.http eq "off">

                <!--- The user name and password were set in uncrypted --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method updateUser was called with no encryption">
                </cfinvoke>
                <cfreturn false>

            </cfif>

            <!--- Set the lst_upd_id based on either a username/pw or session object --->
            <cfif len(arguments.requestor_user_name) gt 0 and len(arguments.requestor_password) gt 0>
		        <cfset lst_upd_id = validateUser(arguments.requestor_user_name, arguments.requestor_password)>
            <cfelseif isDefined("session.user")>
                <cfset lst_upd_id = session.user.getUsr_Id()>
            </cfif>

            <!--- Make sure the user calling the method is valid --->
            <cfif lst_upd_id eq 0>

                <!--- The user name and password were invalid --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method updateUser was called with invalid security credentials (#arguments.requestor_user_name#)">
                </cfinvoke>
                <cfreturn false>

            </cfif> <!--- DONE checking validity of user --->

            <!--- Check to see if the user is authorized to update this user --->
            <cfset requestor_user_type = getUserType(lst_upd_id)>
            <cfif  lst_upd_id neq arguments.usr_id and findNoCase("A", requestor_user_type) eq 0>

                <!--- The user wasn't trying to update their own account and they weren't an administrator --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="Invalid user type, the user #arguments.requestor_user_name# (#lst_upd_id#) attempted to update the user account #arguments.usr_id#">
                </cfinvoke>
                <cfreturn false>

            </cfif><!--- DONE checking to see if the caller is authorized to update the account --->

            <!--- Update the account --->
            <cfinclude template="sql_u_users_03.cfm">

            <!--- Log the update --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="INFORMATION">
                <cfinvokeargument name="message" value="The account for #arguments.usr_id# was updated by #lst_upd_id#">
            </cfinvoke>
            <cfreturn true>
        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The account for #arguments.usr_id# could not be updated #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>
            <cfreturn false>
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END updateUser -------------------------------------------------  --->



    <!--- ----------------------------------------------------------------------
    <method name="deleteUser">
        <responsibilities>
            This method deletes an existing user record in the users table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_name" optional="no" comments="The identifier of the user trying to delete the account" />
                <integer name="arguments.password" optional="no" comments="The password of the user trying to delete the account" />
                <string name="arguments.usr_id" optional="no" comments="The ID of the user" />
            </in>
            <out>
                <boolean name="" comments="Whether the record was deleted or not" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="deleteUser" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="requestor_user_name">
        <cfargument name="requestor_password">
        <cfargument name="usr_id">

        <!--- local variables --->
        <cfset var lst_upd_id = 0>
        <cfset var requestor_user_type = "">

        <cftry>

            <!--- If they passed in a user name and password make sure they sent it encrypted --->
            <cfif (len(arguments.requestor_user_name) gt 0 or len(arguments.requestor_password) gt 0) and cgi.http eq "off">

                <!--- The user name and password were set in uncrypted --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method deleteUser was called with no encryption">
                </cfinvoke>
                <cfreturn false>

            </cfif>

            <!--- Set the lst_upd_id based on either a username/pw or session object --->
            <cfif len(arguments.requestor_user_name) gt 0 and len(arguments.requestor_password) gt 0>
                <cfset lst_upd_id = validateUser(arguments.requestor_user_name, arguments.requestor_password)>
            <cfelseif isDefined("session.user")>
                <cfset lst_upd_id = session.user.getUsr_Id()>
            </cfif>

            <!--- Make sure the user calling the method is valid --->
            <cfif lst_upd_id eq 0>

                <!--- The user name and password were invalid --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="The method updateUser was called with invalid security credentials (#arguments.requestor_user_name#)">
                </cfinvoke>
                <cfreturn false>

            </cfif> <!--- DONE checking validity of user --->

            <!--- Check to see if the user is authorized to update this user --->
            <cfset requestor_user_type = getUserType(lst_upd_id)>
            <cfif  findNoCase("A", requestor_user_type) eq 0>

                <!--- The user wasn't an administrator --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="Invalid user type, the user #arguments.requestor_user_name# (#lst_upd_id#) attempted to delete the user account #arguments.usr_id#">
                </cfinvoke>
                <cfreturn false>

            </cfif><!--- DONE checking to see if the caller is authorized to update the account --->

            <!--- delete the account --->
            <cfinclude template="sql_d_users_01.cfm">

            <!--- Log the account deletion --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="#lst_upd_id#">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="INFORMATION">
                <cfinvokeargument name="message" value="The account for #arguments.usr_id# was deleted by #arguments.requestor_user_name# (#lst_upd_id#)">
            </cfinvoke>
            <cfreturn true>
        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The account for #arguments.usr_id# could not be deleted #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>
            <cfreturn false>
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END deleteUser -------------------------------------------------  --->

    <!--- ----------------------------------------------------------------------
    <method name="validateUser">
        <responsibilities>
            This method determines if a user is a valid user or not
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <string name="arguments.user_name" optional="no" comments="The user_name to be checked" />
                <string name="arguments.password" optional="no" comments="The password to be checked" />
                <string name="arguments.valid_user_types" optional="no" comments="A list of valid user types.  Leave blank if not desired" />
            </in>
            <out>
                <integer name="usr_id" comments="The usr_id of the account" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="validateUser" access="remote" returntype="any" hint="returns a user object if correct credentials turned in" output="false">

        <!--- input variables --->
        <cfargument name="user_name" hint="the user's login id">
        <cfargument name="password" hint="the user's password">
        <cfargument name="valid_user_types" required="no" default="" hint="a list of valid user types">

        <!--- local variables --->
        <cfset var usr_id = -1>
        <cfset var is_valid = false>

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_01.cfm">

            <!--- Check for success --->
            <cfif s_users.recordCount eq 0>

                <!--- No user found --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="0">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="No account could be found for #arguments.user_name#">
                </cfinvoke>
                <cfreturn usr_id>

            <cfelse>

                <!--- Check to make sure the user is the right type
                <cfif listLen(arguments.valid_user_types) gt 0 and findNoCase(s_users.user_type, arguments.valid_user_types) eq 0>
                    <cfreturn usr_id>
                </cfif>
                --->

                <!--- A record matched the user name.  Now check the password --->
                <cfset is_valid = checkPassword(arguments.password, s_users.password, s_users.salt)>

                <!--- Did the password match? --->
                <cfif is_valid>
                    <cfset usr_id = s_users.usr_id>
                <cfelse>
                    <!--- Not valid.  Log the incident --->
                    <cfinvoke component="arch.Audit" method="logAction">
                        <cfinvokeargument name="usr_id" value="0">
                        <cfinvokeargument name="device_id" value="0">
                        <cfinvokeargument name="type" value="SECURITY">
                        <cfinvokeargument name="message" value="Invalid Validation Attempt for #arguments.user_name#">
                    </cfinvoke>
                </cfif>
                <cfreturn usr_id>

            </cfif>

        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END validateUser -----------------------------------------------  --->


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


    <!--- ----------------------------------------------------------------------
    <method name="getUserType">
        <responsibilities>
            This method returns the user type for an account
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.usr_id" optional="no" comments="The user id of the record to be returned" />
            </in>
            <out>
                <string name="user_type" comments="The user type string" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="getUserType" access="remote" returntype="any" hint="Returns the user type for an account" output="false">

        <!--- input variables --->
        <cfargument name="usr_id" hint="the user's id">

        <!--- local variables --->
        <cfset var user_type = "">

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_02.cfm">

            <!--- Check for success --->
            <cfif s_users.recordCount eq 0>

                <!--- No user found --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="usr_id" value="0">
                    <cfinvokeargument name="device_id" value="0">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="No user_type could be found for #arguments.usr_id#">
                </cfinvoke>
                <cfreturn usr_type>

            <cfelse>

                <cfset user_type = s_users.user_type>

                <cfreturn user_type>

            </cfif>

        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The user type for user #arguments.usr_id# could not be found. #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END validateUser -----------------------------------------------  --->




    <!--- ----------------------------------------------------------------------
    <method name="getDependents">
        <responsibilities>
            This method returns a list of users who fall under a given user
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.usr_id" optional="no" comments="The user id of the record to be returned" />
            </in>
            <out>
                <string name="dependent_list" comments="The list of usr_id's that fall under the user" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="getDependents" access="remote" returntype="any" hint="Returns the user type for an account" output="false">

        <!--- input variables --->
        <cfargument name="usr_id" hint="the user's id">

        <!--- local variables --->
        <cfset var user_list = "">
        <cfset var max_users = 10>
        <cfset var ii = 0>

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_04.cfm">

            <!--- Check for existance of child accounts --->
            <cfif s_children.recordCount eq 0>

                <!--- No children, return the empty list --->
                <cfreturn user_list>

            <cfelse>

                <!--- This user has children add them to the user_list --->
                <cfset user_list = valueList(s_children.tgt_id)>

                <cfloop query="s_children">
                    <!--- Put in a check to make sure recursion doesn't go crazy. --->
                    <cfif ii lte max_users>
	                    <cfset var sub = getDependents(tgt_id)>
	                    <cfif listLen(sub) gt 0>
		                    <cfset user_list = user_list & "," & sub>
	                    </cfif>
                    </cfif>
                    <cfset ii = ii + 1>
                </cfloop>

                <cfreturn user_list>

            </cfif>

            <cfreturn user_list>

        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="usr_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The user list for user #arguments.usr_id# could not be found. #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END getDependents -----------------------------------------------  --->

</cfcomponent>