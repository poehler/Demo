<cfcomponent output="false">

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
        <cfset var is_valid = false>
        <cfset var rtn = "">

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_02.cfm">

            <!--- Check for success --->
            <cfif s_users.recordCount eq 0>

                <!--- No user found --->
                <cfset log = application.auditLogger.logAction(0, 0, "SECURITY", "No account could be found for #arguments.user_name#")>

            <cfelse>

                <!--- A record matched the user name.  Now check the password --->
                <cfset is_valid = checkPassword(arguments.password, s_users.password, s_users.salt)>

                <!--- Did the password match? --->
                <cfif is_valid>

                    <!--- Create a new session_id --->
                    <cfset rtn = s_users.usr_id>


                <cfelse>

                    <!--- Not valid.  Log the incident --->
                    <cfset log = application.auditLogger.logAction(0, 0, "SECURITY", "Invalid Validation Attempt for #arguments.user_name#")>

                </cfif>

                <cfreturn rtn>

            </cfif>

        <cfcatch>
            <!--- Log the exeception --->
            <cfset log = application.auditLogger.logAction(0, 0, "ERROR", "The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#")>

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END of validateUser --------------------------------------------- --->

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
    <method name="validateUserSession">
        <responsibilities>
            This method validates a user id and session.  The session must be active
            in the sessions table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_id" optional="no" comments="The user name" />
                <string name="arguments.session_id" optional="no" comments="The password" />
            </in>
            <out>
                <boolean name="anon" comments="The user object reference" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="validateUserSession" access="public" returntype="any" hint="returns a user object if correct credentials turned in" output="false">

        <!--- Input variables --->
        <cfargument name="user_id" hint="the user's login id">
        <cfargument name="session_id" hint="the user's session_id">

        <!--- local variables --->

        <cftry>
            <!--- Query the sessions table to find a match --->
            <cfinclude template="sql_s_sessions_01.cfm">

            <!--- Check for success --->
            <cfif s_sessions.recordCount eq 0>
                <cfreturn false>
            <cfelse>
                <cfreturn true>
            </cfif>

        <cfcatch>
            <cfreturn false>
        </cfcatch></cftry>

    </cffunction>
    <!--- END of validateUserSession --------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="validateUserAccess">
        <responsibilities>
            This method validates a user's access to view a particular location/gateway/device.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_id" optional="no" comments="The user id" />
                <string name="arguments.session_id" optional="no" comments="The session id" />
                <string name="arguments.id" optional="no" comments="The id of the object" />
                <string name="arguments.type" optional="no" comments="The type of the object" />
            </in>
            <out>
                <boolean name="anon" comments="True if a user has rights to access the object" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="validateUserAccess" access="public" returntype="any" hint="returns a user object if correct credentials turned in" output="false">
        <!--- Input variables --->
        <cfargument name="user_id" hint="the user's id">
        <cfargument name="id" hint="the id of the object being accessed">
        <cfargument name="type" hint="the object type being accessed">

        <!--- local variables --->

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_01.cfm">

            <!--- Check for success --->
            <cfif s_user_info.recordCount eq 0>

                <!--- No user found --->
                <cfinvoke component="arch.Audit" method="logAction">
                    <cfinvokeargument name="user_id" value="">
                    <cfinvokeargument name="device_id" value="">
                    <cfinvokeargument name="type" value="SECURITY">
                    <cfinvokeargument name="message" value="No account could be found for #arguments.user_name#">
                </cfinvoke>
                <cfreturn false>

            <cfelse>

                <!--- Create the appropriate user object type --->
                <cfswitch expression="#s_user_info.user_type#">

                    <!--- Administrators. --->
                    <cfcase value="A,G">
                        <!--- Always return true --->
                        <cfreturn true>
                    </cfcase>

                    <!--- Admin Tech. --->
                    <cfcase value="D">
                        <!--- They can access all spas --->
                        <cfif trim(arguments.type) eq 1>
                            <!--- Always return true --->
                            <cfreturn true>
                        <cfelse>
                            <!--- Always return true --->
                            <cfreturn false>
                        </cfif>
                    </cfcase>

                    <!--- Dealer --->
                    <cfcase value="B,E,F">
                        <!--- What type of object are they trying to access? --->
                        <cfswitch expression="#arguments.type#">
                            <!--- A spa. --->
                            <cfcase value="1">
                                <!--- Is the spa in question assigned to them --->
                                <cfinclude template="sql_s_dealer_devices_01.cfm">
                                <cfif s_dealer_devices.recordCount eq 0>
                                    <!--- No --->
                                    <cfreturn false>
                                <cfelse>
                                    <!--- Yes --->
                                    <cfreturn true>
                                </cfif>
                            </cfcase>
                            <cfdefaultcase>
                                <!--- Unknown, return false --->
                                <cfreturn false>
                            </cfdefaultcase>
                        </cfswitch>
                    </cfcase>

                    <!--- An owner --->
                    <cfcase value="C">
                        <!--- What type of object are they trying to access? --->
                        <cfswitch expression="#arguments.type#">
                            <!--- A spa. --->
                            <cfcase value="1">
                                <!--- Is the spa in question assigned to them --->
                                <cfinclude template="sql_s_owner_devices_01.cfm">
                                <cfif s_owner_devices.recordCount eq 0>
                                    <!--- No --->
                                    <cfreturn false>
                                <cfelse>
                                    <!--- Yes --->
                                    <cfreturn true>
                                </cfif>
                            </cfcase>
                            <cfdefaultcase>
                                <!--- Unknown, return false --->
                                <cfreturn false>
                            </cfdefaultcase>
                        </cfswitch>
                    </cfcase>

                    <cfdefaultcase>
                        <cfreturn false>
                    </cfdefaultcase>

                </cfswitch>


            </cfif>

        <cfcatch>
            <!--- Log the exeception --->
            <cfinvoke component="arch.Audit" method="logAction">
                <cfinvokeargument name="user_id" value="0">
                <cfinvokeargument name="device_id" value="0">
                <cfinvokeargument name="type" value="ERROR">
                <cfinvokeargument name="message" value="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#">
            </cfinvoke>

            <cfreturn false>

        </cfcatch></cftry>

    </cffunction>
    <!--- END of validateUser --------------------------------------------- --->

    <!--- ----------------------------------------------------------------------
    <method name="validateUserRole">
        <responsibilities>
            This method validates a user's role.  This is used to control access
            to certain functions.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <integer name="arguments.user_id" optional="no" comments="The user id" />
                <string name="arguments.role" optional="no" comments="The role to be checked" />
            </in>
            <out>
                <boolean name="anon" comments="True if a user has rights to access the object" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="validateUserRole" access="public" returntype="any" hint="Checks whether a user has the correct role" output="false">
        <!--- Input variables --->
        <cfargument name="user_id" hint="the user's id">
        <cfargument name="role_id" hint="The role to be checked">

        <!--- local variables --->

        <cftry>

            <!--- Search the database for a match --->
            <cfinclude template="sql_s_users_01.cfm">

            <!--- Check for success --->
            <cfif s_user_info.recordCount eq 0>

                <!--- No user found --->
                <cfreturn false>

            <cfelse>

                <!--- Is this an administrator?  They always pass.--->
                <cfif s_user_info.user_type eq "A">

	                <cfreturn true>

                <cfelseif arguments.role_id eq  0>

	                <cfreturn true>

                <cfelseif listFind(valueList(s_user_info.role_id), arguments.role_id) gt 0>

                    <!--- Role was in the query --->
	                <cfreturn true>

                <cfelse>

                    <!--- Wasn't an admin and the role wasn't in the query --->
	                <cfreturn false>

                </cfif>

            </cfif>

        <cfcatch>
            <cfreturn false>
        </cfcatch></cftry>

    </cffunction>
    <!--- END of validateUserRole --------------------------------------------- --->

</cfcomponent>