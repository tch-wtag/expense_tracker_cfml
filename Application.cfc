component {
    this.name = "ExpenseTrackerAPI";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0,2,0,0); // 2 hours
    this.datasource = "mydsn";
    this.javaSettings = {
        loadPaths = [ "/lib" ],
        reloadOnChange = true
    };

    function onApplicationStart() {
        // Include environment config
        include "env.cfm";

        // Map Google keys from environment config
        application.GOOGLECLIENTID = application.env.GOOGLECLIENTID;
        application.GOOGLECLIENTSECRET = application.env.GOOGLECLIENTSECRET;
        application.GOOGLEREDIRECTURI = application.env.GOOGLEREDIRECTURI;
        application.SECRET_KEY          = application.env.SECRET_KEY;
        try {
            restInitApplication(
                dirPath = expandPath("/var/www/controllers"),
                serviceMapping = "/api",
                password = "hello"
            );
        } catch(any e) {
            writeOutput("REST initialization error: " & e.message);
        }
        return true;
    }

    function onSessionStart() {
        session.isLoggedIn = false;
        session.userRole = "";
    }

    public void function onRequest(string targetPage) {
        try {
            if (structKeyExists(cgi,"path_info") and left(cgi.path_info,5) eq "/api/") return;
            publicPages = ["index.cfm","login.cfm","signup.cfm","signupSuccess.cfm","test_session.cfm"];
            pageName = listLast(arguments.targetPage,"/");

            handlerPages = ["loginHandler.cfm","signupHandler.cfm","expenseHandler.cfm","categoryHandler.cfm"];

            if (arrayFind(publicPages, pageName)) {
                cfinclude(template=arguments.targetPage);
                return;
            }

            if (arrayFind(handlerPages, pageName)) {
                writeLog(file="application", text="Handler page requested: " & pageName);
                
                if (pageName eq "loginHandler.cfm" or pageName eq "signupHandler.cfm") {
                    writeLog(file="application", text="Allowing access to public handler: " & pageName);
                    cfinclude(template=arguments.targetPage);
                    return;
                } else if (structKeyExists(session,"isLoggedIn") and session.isLoggedIn) {
                    writeLog(file="application", text="User authenticated, allowing access to: " & pageName & ", userId: " & session.userId);
                    cfheader(name="Cache-Control", value="no-store, no-cache, must-revalidate");
                    cfheader(name="Pragma", value="no-cache");
                    cfheader(name="Expires", value="0");
                    cfinclude(template=arguments.targetPage);
                    return;
                } else {
                    writeLog(file="application", text="Authentication FAILED for handler: " & pageName & ", isLoggedIn exists: " & structKeyExists(session,'isLoggedIn'));
                    location("/views/auth/login.cfm");
                }
            }

            if (findNoCase("dashboard", targetPage) and (not structKeyExists(session,"isLoggedIn") or not session.isLoggedIn)) {
                location("/views/auth/login.cfm");
            }

            if (structKeyExists(session, "isLoggedIn") and session.isLoggedIn or findNoCase("dashboard", targetPage)) {
                cfheader(name="Cache-Control", value="no-store, no-cache, must-revalidate");
                cfheader(name="Pragma", value="no-cache");
                cfheader(name="Expires", value="0");
            }
            cfinclude(template=arguments.targetPage);

        } catch(any e) {
            writeLog(file="application", text="Error in onRequest: " & e.message & " - " & e.detail);
            if (findNoCase("not authenticated", e.message) or findNoCase("not logged in", e.message)) {
                sessionInvalidate();
                location("/views/auth/login.cfm");
            } else {
                writeOutput("<h3>Oops! Something went wrong.</h3>");
                writeOutput("<p>" & e.message & "</p>");
                if (structKeyExists(url, "debug") or isDefined("application.debug")) {
                    writeDump(var=e);
                }
            }
        }
    }

    function onError(exception, eventName) {
        if (structKeyExists(cgi,"path_info") and left(cgi.path_info,5) eq "/api/") {
            writeOutput(serializeJSON({status="error", message=exception.message}));
        } else {
            writeOutput("<h3>Oops! Something went wrong.</h3>");
            writeDump(var=exception);
        }
    }
}
