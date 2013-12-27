<!---
<fusedoc fuse="Audit.cfc" language="ColdFusion" version="2.0">
    <responsibilities>
        This CFC is used to manage adding audit messages to the
        audit_trails database.
    </responsibilities>
    <properties>
        <history author="Jimbo"
                 date="08/26/2011"
                 role="Architect"
                 type="Create"
        />
        <copyright>Digi (c) 2011</copyright>
    </properties>
</fusedoc>
--->
<cfcomponent output="false" name="NewObject">

    <!--- public properties --->

    <!--- private properties --->

    <!--- ----------------------------------------------------------------------
	<method name="logAction">
	    <responsibilities>
	        This method will insert a record into the table audit_trails
	    </responsibilities>
	    <properties>
	        <history author="Jimbo" date="08/26/2011" role="Architect" type="Create" />
	    </properties>
	    <io>
	        <in>
                <object name="session.user" optional="no" comments="The user object created when a user logs in" />
                <integer name="arguments.device_id" optional="yes" comments="The unique ID of the object" />
                <string name="arguments.type" optional="no" comments="What type of message is being logged, ERROR|WARNING|INFO" />
                <string name="arguments.message" optional="no" comments="The message being logged" />
	        </in>
	        <out>
                <boolean name="" comments="Will return a boolean on whether the message was logged" />
	        </out>
	    </io>
	</method>
	--->
    <cffunction name="logAction" hint="This method inserts a record into the audit trails table">

        <!--- input variables --->
        <cfargument name="usr_id" required="no" default="0">
        <cfargument name="type">
        <cfargument name="message">
        <cfargument name="location_id" required="no" default="0">
        <cfargument name="gateway_id" required="no" default="0">
        <cfargument name="device_id" required="no" default="0">
        <cfargument name="channel_id" required="no" default="0">

        <cftry>
	        <cfinclude template="audits/sql_i_audit_trails_01.cfm">
        <cfcatch>
            <cfmail from="jim.poehler@digi.com" to="jim.poehler@digi.com" subject="auditerror" type="html"><cfdump var="#cfcatch#"></cfmail>
        </cfcatch></cftry>

        <cfreturn true>

    </cffunction>
    <!--- END logAction --------------------------------------------------- --->

</cfcomponent>