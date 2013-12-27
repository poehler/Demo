<cfcomponent output="false">

    <!--- ----------------------------------------------------------------------
    <method name="getRecordsForGrid">
        <responsibilities>
            This method returns a JSON array of user info
        </responsibilities>
        <properties>
            <history author="Jimbo" date="01/23/2013" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
            </in>
            <out>
                <xml name="xml" comments="The xml document" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="getRecordsForGrid" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="sEcho" type="string" default="">
        <cfargument name="iDisplayStart" type="string" default="0">
        <cfargument name="iDisplayLength" type="string" default="10">
        <cfargument name="sSearch" type="string" default="">
        <cfargument name="iSortCol_0" type="string" default="1">
        <cfargument name="sSortDir_0" type="string" default="asc">

        <cftry>
        <!--- Declare local variables --->
        <cfset var pt = structNew()>
        <cfset var rtn = structNew()>
        <cfset rtn["aaData"] =arrayNew(1)>
        <cfset var tblColumns = [ "a.name", "a.user_name", "b.decode", "a.email", "a.status_cde", "d.name", "a.user_type", "a.company", "a.addr1", "a.addr2", "a.city", "a.state", "a.zip", "a.country", "a.phone", "a.fax", "a.hint", "c.code"]>

        <cfif not isValid("integer", arguments.iDisplayStart)>
            <cfset arguments.iDisplayStart = 0>
        </cfif>

        <cfif not isValid("integer", arguments.iDisplayLength)>
            <cfset arguments.iDisplayLength = 0>
        </cfif>

        <cfswitch expression="#arguments.sSortDir_0#">
            <cfcase value="asc">
                <cfset primary_sort = "asc">
                <cfset secondary_sort = "desc">
            </cfcase>
            <cfdefaultcase>
                <cfset primary_sort = "desc">
                <cfset secondary_sort = "asc">
            </cfdefaultcase>
        </cfswitch>

        <cfif arguments.iSortCol_0 lt 0 or arguments.iSortCol_0 gte arrayLen(tblColumns)>
            <cfset var sort_col = "a.user_name">
            <cfset var short_sort_col = "user_name">

        <cfelse>
            <cfset var sort_col = tblColumns[arguments.iSortCol_0 + 1]>
            <cfset var short_sort_col = listGetAt(tblColumns[arguments.iSortCol_0 + 1], 2, ".")>
        </cfif>

        <cfif not isDefined("session.user")>
            <cfthrow message="Invalid Session Credentials">
        </cfif>

        <!--- Make sure that the dealer_id can't be overwritten --->
        <cfif findNoCase("B", session.user.getUser_Type()) gt 0 or
              findNoCase("E", session.user.getUser_Type()) gt 0 or
              findNoCase("F", session.user.getUser_Type()) gt 0 >
            <cfset dealer_id = session.user.getDealer_ID()>
        </cfif>

        <!--- Get the data from the database --->
        <cfinclude template="sql_s_user_03.cfm">

        <cfloop query="s_users" startRow="#arguments.iDisplayStart + 1#" endRow="#arguments.iDisplayStart + arguments.iDisplayLength#">
            <cfset pt = structNew()>
            <cfset pt["DT_RowId"] = usr_id>
            <cfset pt["user_name"] = user_name>
            <cfset pt["user_type"]["value"] = user_type>
            <cfset pt["user_type"]["name"] = type>
            <cfset pt["status_cde"]["value"] = status_cde>
            <cfset pt["status_cde"]["name"] = status>
            <cfset pt["dealer_id"]["value"] = dealer_id>
            <cfset pt["dealer_id"]["name"] = dealer>
            <cfset pt["name"] = name>
            <cfset pt["email"] = email>
            <cfset pt["addr1"] = addr1>
            <cfset pt["addr2"] = addr2>
            <cfset pt["city"] = city>
            <cfset pt["state"] = state>
            <cfset pt["zip"] = zip>
            <cfset pt["country"] = country>
            <cfset pt["hint"] = hint>
            <cfset pt["company"] = company>
            <cfset pt["phone"] = phone>
            <cfset pt["fax"] = fax>
            <cfset arrayAppend(rtn["aaData"], pt)>
        </cfloop>


        <cfset rtn["sEcho"] = arguments.sEcho>
        <cfset rtn["iTotalRecords"] = s_users.recordCount>
        <cfset rtn["iTotalDisplayRecords"] = s_users.recordCount>

        <cfif not isDefined("arguments.returnObj") or arguments.returnObj neq "Y">
            <cfcontent type="text/json">
        </cfif>
        <cfreturn serializeJSON(rtn)>
        <cfcatch>
        </cfcatch></cftry>
    </cffunction>


    <!--- ----------------------------------------------------------------------
    <method name="getAsOptions">
        <responsibilities>
            This method returns a JSON array of users
        </responsibilities>
        <properties>
            <history author="Jimbo" date="01/23/2013" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
            </in>
            <out>
                <xml name="xml" comments="The xml document" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="getAsOption" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="type" default="C">

        <!--- Local Variables --->
        <cfset var rtn = arrayNew(1)>
        <cftry>

            <!--- Get a list of users --->
            <cfinclude template="sql_s_users_03.cfm">

            <cfloop query="s_users">
                <cfset var pt = structNew()>
                <cfset pt["name"] = name>
                <cfset pt["value"] = usr_id>
		cfset pt["dealer_id"]["value"] = dealer_id>
		<cfset pt["dealer_id"]["name"] =dealer
                <cfset arrayAppend(rtn, pt)>
            </cfloop>
            <cfif not isDefined("arguments.returnObj") or arguments.returnObj neq "Y">
                <cfcontent type="text/json">
            </cfif>

            <cfreturn serializeJSON(rtn)>
        <cfcatch>
        </cfcatch></cftry>
    </cffunction>

    <!--- ----------------------------------------------------------------------
    <method name="ajaxCall">
        <responsibilities>
            This method returns a JSON array of user info
        </responsibilities>
        <properties>
            <history author="Jimbo" date="01/23/2013" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
            </in>
            <out>
                <xml name="xml" comments="The xml document" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="ajaxCall" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="lst_upd_id" default="">
        <cfargument name="session_id" default="">
        <cfargument name="action" required="true" default="">

        <!---  --->
        <cfset var data = structNew()>
        <cfset var rtn = structNew()>
        <cfset var errors = arrayNew(1)>
        <cfset var err = structNew()>
        <cfset var sub_rtn = structNew()>
        <cftry>

        <!--- BGN validating the caller's rights to perform the action --->
            <!--- Copy the user's credentials into local vars--->
            <cfif arguments.lst_upd_id eq "">
                <cfif isDefined("session.user")>
                    <cfset arguments.lst_upd_id = session.user.getUsr_ID()>
                <cfelse>
                    <cfthrow message="The user could not be #arguments.action#ted" detail="(invalid user credentials)">
                </cfif>
            </cfif>

            <cfif arguments.session_id eq "">
                <cfif isDefined("session.user")>
                    <cfset arguments.session_id = session.user.getsession_id()>
                <cfelse>
                    <cfthrow message="The user could not be #arguments.action#ted" detail="(invalid session credentials)">
                </cfif>
            </cfif>

            <!--- Verify the session --->
            <cfif not application.security.validateUserSession(arguments.lst_upd_id, arguments.session_id)>
                <cfthrow message="The user could not be #arguments.action#ed" detail="(invalid session)">
            </cfif>

            <!--- Verify the user access
            <cfif not application.security.validateUserRole(arguments.lst_upd_id, 2)>
                <cfthrow message="The user could not be #arguments.action#ed" detail="(invalid role)">
            </cfif>
            --->
        <!--- END validating the caller's rights to perform the action --->

        <!--- BGN validating input arguments --->

            <cfif isDefined("arguments.user_data")>
                <cfset data = arguments.user_data>
            </cfif>

            <!--- The arguments come in with a string as dot notation.  Create a real struct from that --->
            <cfloop collection="#arguments#" item="key">
                <cfset st = REFind("DATA\[.*\]", key, 1, "TRUE")>
                <cfif st.len[1] gt 0>
                    <cfset data[mid(key, 6, st.len[1] - 6)] = arguments[key]>
                </cfif>
            </cfloop>

            <!--- Now validate input --->
            <cfif arguments.action neq "remove">
            <cfif not structKeyExists(data, "user_name") or data.user_name eq "">
                <cfset err["name"] = "user_name">
                <cfset err["status"] = "Please enter a user name">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "email") or data.email eq "" or not isValid("email", data.email)>
                <cfset err["name"] = "email">
                <cfset err["status"] = "Please enter an e-mail address">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "status_cde") or len(data.status_cde) neq 1>
                <cfset err["name"] = "status_cde">
                <cfset err["status"] = "Please select a status">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "user_type") or len(data.user_type) neq 1>
                <cfset err["name"] = "user_type">
                <cfset err["status"] = "Please select a user type">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <!--- Make sure that the dealer_id can't be overwritten --->
            <cfif findNoCase("B", session.user.getUser_Type()) gt 0 or
                  findNoCase("E", session.user.getUser_Type()) gt 0 or
                  findNoCase("F", session.user.getUser_Type()) gt 0 >
                <cfset data.dealer_id = session.user.getDealer_ID()>
            <cfelse>
                <!--- Figure out what the dealer id was from the name --->
                <cfset data.dealer_id = "">
            </cfif>

            <cfif not structKeyExists(data, "addr1") or len(trim(data.addr1)) eq 0>
                <cfset err["name"] = "addr1">
                <cfset err["status"] = "Please enter a street address">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "city") or len(trim(data.city)) eq 0>
                <cfset err["name"] = "city">
                <cfset err["status"] = "Please enter a city">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "state") or len(trim(data.state)) eq 0>
                <cfset err["name"] = "state">
                <cfset err["status"] = "Please enter a state or province">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "zip") or len(trim(data.zip)) eq 0>
                <cfset err["name"] = "zip">
                <cfset err["status"] = "Please enter a postal code">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif not structKeyExists(data, "country") or len(trim(data.country)) eq 0>
                <cfset err["name"] = "country">
                <cfset err["status"] = "Please enter a country">
                <cfset arrayAppend(errors, err)>
            </cfif>

            <cfif arrayLen(errors) gt 0>
                <cfthrow message="Validation Errors" detail="#arrayLen(errors)# fields failed validation">
            </cfif>
            </cfif>
        <!--- END validating input arguments --->

        <!--- BGN calling correct sub-method --->
            <!--- Now ready to send the data to the right method --->
            <cfswitch expression="#arguments.action#">

                <!--- Create --->
                <cfcase value="create">

                    <cfset data["lst_upd_id"] = arguments.lst_upd_id>
                    <cfset sub_rtn = insertRow(data)>

                    <!--- Copy the usr_id to the arguments scope if successful --->
                    <cfif sub_rtn["code"] eq 200>
                        <cfif structKeyExists(sub_rtn, "id")>
                            <cfset arguments.id = sub_rtn["id"]>
                        <cfelse>
                            <cfset arguments.id = 11>
                        </cfif>
                    <cfelseif sub_rtn["code"] eq 301>
                        <cfset rtn["error"] = sub_rtn["message"]>
                    </cfif>

                </cfcase><!--- End of Create --->

                <!--- Edit --->
                <cfcase value="edit">

                    <cfset data["usr_id"] = arguments.id>
                    <cfset data["lst_upd_id"] = arguments.lst_upd_id>
                    <cfset sub_rtn = updateRow(data)>

                    <!--- Did they want to update their password too? --->
                    <cfif isDefined("data.password") and len(trim(data.password)) gt 0
                          and isDefined("data.hint") and len(trim(data.hint)) gt 0>

                        <!--- Encrypt the password --->
                        <cfset var crypto = createObject('component', 'arch.Crypto') />
                        <cfset var salt = crypto.genSalt() />
                        <cfset var hashed_password = crypto.computeHash(data.password, salt) />

                        <!--- Now update the user. --->
                        <cfinclude template="sql_u_users_04.cfm">

                        <cfset nll = application.AuditLogger.logAction(lst_upd_id, 0, "INFORMATION", "The password for usr_id (#arguments.id#) was changed by #arguments.lst_upd_id#")>

                    </cfif>
                </cfcase>

                <!--- Delete --->
                <cfcase value="remove">
                    <cfset data["usr_id"] = arguments["DATA[]"]>
                    <cfset data["lst_upd_id"] = arguments.lst_upd_id>
                    <cfset sub_rtn = deleteRow(data)>
                </cfcase>

                <cfdefaultcase>
                </cfdefaultcase>
            </cfswitch>
        <!--- END calling correct sub-method --->

            <!--- Set the id and row in the return object --->
            <cfif isValid("numeric", arguments.id)>
                <cfset rtn["id"] = arguments.id>
            <cfelse>
                <cfset rtn["id"] = -1>
            </cfif>

            <!--- Check the return --->
            <cfif sub_rtn.code neq 200>
                <cfset rtn["id"] = -1>
            </cfif>

            <cfset rtn["row"] = structNew()>

            <!--- Now populate the row struct --->
            <cfloop collection="#data#" item="key">
                <cfset rtn["row"][key] = data[key]>
            </cfloop>

        <cfcatch>

            <!--- Set a bad ID --->
            <cfset rtn["id"] = -1>

            <cfif arrayLen(errors) eq 0>
                <cfset rtn["error"] = "There was an error with your request.  #cfcatch.message# #cfcatch.detail#">
            <cfelse>
                <cfset rtn["fieldErrors"] = errors>
            </cfif>


        </cfcatch></cftry>

        <!--- Return the struct --->
        <cfif not isDefined("arguments.returnObj") or arguments.returnObj neq "Y">
            <cfcontent type="text/json">
            <cfreturn serializeJSON(rtn)>
        <cfelse>
            <cfreturn rtn>
        </cfif>

    </cffunction>
    <!--- END of ajaxCall --------------------------------------------- --->


    <!--- ----------------------------------------------------------------------
    <method name="insertRow">
        <responsibilities>
            This method inserts a new user record into the users table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <struct name="data" optional="no" comments="A structure with all the required data elements" />
            </in>
            <out>
                <struct name="rtn" comments="Info about the success of the call" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="insertRow" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="data" type="struct">

        <cfset rtn = structNew()>
        <cfset rtn["code"] = 200>
        <cfset rtn["message"] = "The user was successfully created">

        <!--- local variables --->
        <cftry>
            <!--- Encrypt the password --->
            <cfset var crypto = createObject('component', 'arch.Crypto') />
            <cfset var salt = crypto.genSalt() />
            <cfset var hashed_password = crypto.computeHash(arguments.data.password, salt) />

            <cfset var ii = 1>
            <cfset var fname = "">
            <cfset var lname = "">
            <cfloop list="#arguments.data.name#" index="seg" delimiters=" ">
                <cfif ii eq listLen(arguments.data.name, " ")>
                    <cfset lname = seg>
                <cfelse>
                    <cfset fname = "#fname# #seg#">
                </cfif>
                <cfset ii = ii + 1>
            </cfloop>

            <!--- Attempt the insert --->
            <cfinclude template="sql_i_users_01.cfm">

            <!--- Set the usr_id in the return --->
            <cfset rtn["id"] = s_users.usr_id>

            <!--- Log the event --->
            <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0,  "INFORMATION", "A new user was created  for #arguments.data.user_name# by #arguments.data.lst_upd_id#")>

            <!--- Return the new usr_id value --->
            <cfreturn rtn>

        <cfcatch>
            <!--- Was the user name taken? --->
            <cfif findNoCase("UNIQUE KEY", cfcatch.detail) gt 0>
                <cfset rtn["code"] = 301>
                <cfset rtn["id"] = -1>
                <cfset rtn["message"] = "The user name has already been registered">
            <cfelse>
<cfmail from="julie.ganz@digi.com" to="julie.ganz@digi.com" subject="#application.site_name# Debugging" type="html"><cfdump var="#cfcatch#"></cfmail>
                <!--- Log the exeception --->
                <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0, "ERROR", "A new user could not be created #cfcatch.message# #cfcatch.detail#")>
                <cfset rtn["code"] = 500>
                <cfset rtn["id"] = -1>
                <cfset rtn["message"] = "The user could not be created.">
            </cfif>
            <cfreturn rtn>
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END insertRow -------------------------------------------------  --->


    <!--- ----------------------------------------------------------------------
    <method name="updateRow">
        <responsibilities>
            This method updates an existing user record into the users table.
        </responsibilities>
        <properties>
            <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
        </properties>
        <io>
            <in>
                <struct name="data" optional="no" comments="A structure with all the required data elements" />
            </in>
            <out>
                <struct name="rtn" comments="Info about the success of the call" />
            </out>
        </io>
    </method>
    --->
    <cffunction name="updateRow" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="data" type="struct">

        <cfset rtn = structNew()>
        <cfset rtn["code"] = 200>
        <cfset rtn["message"] = "The user was successfully updated">

        <!--- local variables --->
        <cftry>

            <cfset var ii = 1>
            <cfset var fname = "">
            <cfset var lname = "">
            <cfloop list="#arguments.data.name#" index="seg" delimiters=" ">
                <cfif ii eq listLen(arguments.data.name, " ")>
                    <cfset lname = seg>
                <cfelse>
                    <cfset fname = "#fname# #seg#">
                </cfif>
                <cfset ii = ii + 1>
            </cfloop>

            <!--- Update the account --->
            <cfinclude template="sql_u_users_01.cfm">

            <!--- Log the update --->
            <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0, "INFORMATION", "The user for #arguments.data.usr_id# was updated by #arguments.data.lst_upd_id#")>

            <!--- Send the struct back --->
            <cfreturn rtn>

        <cfcatch>
            <!--- Log the exeception --->
            <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0, "ERROR", "The user for #arguments.data.usr_id# could not be updated #cfcatch.message# #cfcatch.detail#")>
            <cfset rtn["code"] = 500>
            <cfset rtn["message"] = "The user could not be updated.">
            <cfreturn rtn>
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END updateRow -------------------------------------------------  --->

    <!--- ----------------------------------------------------------------------
    <method name="deleteRow">
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
    <cffunction name="deleteRow" access="remote" returntype="any">

        <!--- input variables --->
        <cfargument name="data" type="struct">
        <cfset rtn = structNew()>
        <cfset rtn["code"] = 200>
        <cfset rtn["message"] = "The user was successfully deleted">

        <!--- local variables --->
        <cftry>

            <!--- delete the account --->
            <cfinclude template="sql_d_users_01.cfm">

            <!--- Log the update --->
            <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0, "INFORMATION", "The user for #arguments.data.usr_id# was deleted by #arguments.data.lst_upd_id#")>

            <!--- Send the struct back --->
            <cfreturn rtn>

        <cfcatch>
            <!--- Log the exeception --->
            <cfset nll = application.AuditLogger.logAction(arguments.data.lst_upd_id, 0, "ERROR", "The user for #arguments.data.usr_id# could not be deleted #cfcatch.message# #cfcatch.detail#")>
            <cfset rtn["code"] = 500>
            <cfset rtn["message"] = "The user could not be deleted.">
            <cfreturn rtn>
        </cfcatch>
        </cftry>

    </cffunction>
    <!--- END deleteRow -------------------------------------------------  --->
</cfcomponent>