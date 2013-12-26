component restpath="/users" rest="true"{
    remote any function usersRailo() httpmethod="GET" {
        if(isDefined("url.from") and isValid("numeric", url.from))
            arguments.from = url.from;
        else
            arguments.from = 1;

        if(isDefined("url.to") and isValid("numeric", url.to))
            arguments.to = url.to;
        else
            arguments.to = 20;

        if(isDefined("url.sort") and len(url.sort) gt 0)
            arguments.sort = url.sort;
        else
            arguments.sort = "username";

        if(isDefined("url.search") and len(url.search) gt 0)
            arguments.search = url.search;
        else
            arguments.search = "";

        searchColumns = ["username", "lname","fname", "addr1", "addr2", "city", "state", "zip", "country", "phone", "phone2", "email"];

        rtn = {};
        rtn.users = [];
        rtn.cmd = {};
        rtn.cmd.code = 200;

        try {
            include "users/sql_s_users_01.cfm";

            if(s_users.recordCount eq 0) {
                rtn.cmd.records = 0;
                rtn.cmd.code = 404;
                return rtn;
            }

            if(s_users.recordCount lt arguments.to)
                    arguments.to = s_users.recordCount;

            for (ii=arguments.from;ii LTE arguments.to;ii=(ii + 1)){
                    usr = {};
                    usr.id = s_users.user_id[ii];
                    for(jj=1; jj lte arrayLen(searchColumns); jj=jj+1) {
                        targetColumn = searchColumns[jj];
                        usr[targetColumn] = s_users[targetColumn][ii];
                    }
                    arrayAppend(rtn.users, usr);
            }
            rtn.cmd.records = s_users.recordCount;
            return rtn;
        } catch (any e) {
            rtn = {};
            rtn.users = [];
            rtn.cmd = {};
            rtn.cmd.code = 500;
            rtn.cmd.message = "General Error Processing Request";
            return rtn;
        }
    }

    remote any function usersURL(string id restargsource="Path") httpmethod="GET" restpath="{id}" {

        if(not isValid("numeric", arguments.id)){
            rtn = {};
            rtn.user = [];
            rtn.cmd = {};
            rtn.cmd.code = 300;
            rtn.cmd.message = "Invalid ID";
            return rtn;
        }

        searchColumns = ["username", "lname","fname", "addr1", "addr2", "city", "state", "zip", "country", "phone", "phone2", "email"];

        rtn = {};
        rtn.users = [];
        rtn.cmd = {};
        rtn.code = 200;

        try {
            include "users/sql_s_users_02.cfm";

            if(s_users.recordCount eq 0) {
                rtn.cmd.records = 0;
                rtn.cmd.code = 404;
                return rtn;
            }

            usr = {};
            usr.id = s_users.user_id;
            for(jj=1; jj lte arrayLen(searchColumns); jj=jj+1) {
                targetColumn = searchColumns[jj];
                usr[targetColumn] = s_users[targetColumn];
            }
            arrayAppend(rtn.users, usr);

            rtn.cmd.records = 1;
            return rtn;

        } catch (any e) {
            rtn = {};
            rtn.users = [];
            rtn.cmd = {};
            rtn.cmd.code = 500;
            rtn.cmd.message = "General Error Processing Request";
        }
    }

    remote any function usersFORM(string userName restargsource="Form",
                                  string password restargsource="Form",
                                  string fName restargsource="Form",
                                  string lName restargsource="Form",
                                  string addr1 restargsource="Form",
                                  string addr2 restargsource="Form",
                                  string city restargsource="Form",
                                  string state restargsource="Form",
                                  string zip restargsource="Form",
                                  string country restargsource="Form",
                                  string phone restargsource="Form",
                                  string phone2 restargsource="Form",
                                  string email restargsource="Form",
                                  string type restargsource="Form") httpmethod="POST" {

        rtn = {};
        rtn.users = [];
        rtn.cmd = {};
        rtn.cmd.code = 200;

        if(not isDefined("arguments.userName") or len(arguments.userName) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "UserName parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.password") or len(arguments.password) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "Password parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.lName") or len(arguments.lName) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "LName parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.fName") or len(arguments.fName) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "FName parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.addr1") or len(arguments.addr1) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "Addr1 parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.addr2")){
            arguments.addr2 = "";
        }
        if(not isDefined("arguments.city") or len(arguments.city) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "City parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.state") or len(arguments.state) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "State parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.zip") or len(arguments.zip) eq 0){
            rtn.cmd.code = 300;
            rtn.cmd.message = "Zip parameter is not valid";
            return rtn;
        }
        if(not isDefined("arguments.country") or len(arguments.country) eq 0){
            arguments.country = "USA";
        }
        if(not isDefined("arguments.phone") or len(arguments.phone) eq 0){
            arguments.phone = "";
        }
        if(not isDefined("arguments.phone2") or len(arguments.phone2) eq 0){
            arguments.phone2 = "";
        }
        if(not isDefined("arguments.email") or len(arguments.email) eq 0 or not isValid("email", arguments.email)){
            arguments.email = "";
        }

        salt = application.crypto.genSalt();
        hashedPassword = application.crypto.computeHash(arguments.password, salt);

        searchColumns = ["username", "lname","fname", "addr1", "addr2", "city", "state", "zip", "country", "phone", "phone2", "email"];

        try {
            include "users/sql_i_users_01.cfm";

            include "users/sql_s_users_02.cfm";

            if(s_users.recordCount eq 0) {
                rtn.cmd.records = 0;
                rtn.cmd.code = 404;
                return rtn;
            }

            usr = {};
            usr.id = s_users.user_id;
            for(jj=1; jj lte arrayLen(searchColumns); jj=jj+1) {
                targetColumn = searchColumns[jj];
                usr[targetColumn] = s_users[targetColumn];
            }
            arrayAppend(rtn.users, usr);

            rtn.cmd.records = 1;
            return rtn;

        } catch (any e) {
            rtn = {};
            rtn.users = [];
            rtn.cmd = {};
            rtn.cmd.code = 500;
            rtn.cmd.message = "General Error Processing Request. #cfcatch.message#, #cfcatch.detail#";
        }
        return rtn;
    }
}
