component {
    public any function validateUser(string user_name, string password){

        <!--- local variables --->
        var isValid = false;
        var rtn = ""

        try {

            include "sql_s_users_02.cfm";

            if(s_users.recordCount eq 0)
                application.AuditLogger.logAction(type="SECURITY", message="No account could be found for #arguments.user_name#");
            else{

                is_valid = checkPassword(arguments.password, s_users.password, s_users.salt);

                if(is_valid)
                    rtn = s_users.usr_id;
                else
                    application.AuditLogger.logAction(type="SECURITY", message="Invalid Validation Attempt for #arguments.user_name#");

                return rtn;
            }
        } catch (any e) {
            application.AuditLogger.logAction(type="ERROR", message="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#");
            return false
        }
    }

    public any function checkPassword(string password, string stored_password, string salt){

        var hashed_password = application.crypto.computeHash(arguments.password, arguments.salt);

        try {
            if(hashed_password eq arguments.stored_password)
                return true;
            else
                return false;
        } catch (any e) {
            application.AuditLogger.logAction(type="ERROR", message="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#");
            return false
        }
    }

    public any function validateSession(string user_id, string session_id){

        var user = {};
        user.user_id = 0;
        user.type = "";

        try {
            include "sql_s_sessions_01.cfm";

            if(s_sessions.recordCount gt 0) {
                user.user_id = s_sessions.user_id;
                user.type = s_sessions.type;
            }
            else
                application.AuditLogger.logAction(type="SECURITY", message="The user #arguments.user_id#'s session could not be validated.(#arguments.session_id#)");

            return user;

        } catch (any e) {
            application.AuditLogger.logAction(type="ERROR", message="The user #arguments.user_name# could not be validated. #cfcatch.message# #cfcatch.detail#");
            return user
        }

    }
}