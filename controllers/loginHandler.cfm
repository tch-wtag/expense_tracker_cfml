<cfparam name="form.email" default="">
<cfparam name="form.password" default="">

<cftry>
    <cfscript>
        userRepo = new repositories.UserRepository();
        result = userRepo.findByEmail(form.email);
        
        if (result.recordCount == 0) {
            variables.errorMessage = "Invalid email or password";
            include "/views/auth/login.cfm";
        } else {
            passwordHelper = new helpers.PasswordHelper();
            storedHash = result.password[1];
            if (passwordHelper.verifyPassword(trim(form.password), storedHash)) {
                session.isLoggedIn = true;
                session.userId = result.id[1];
                session.username = result.username[1];
                session.userRole = "user";
                
                location(url="/views/dashboard/index.cfm", addtoken="false");
            } else {
                variables.errorMessage = "Invalid email or password";
                include "/views/auth/login.cfm";
            }
        }
    </cfscript>

    <cfcatch type="any">
        <cfset variables.errorMessage = "Login error: " & cfcatch.message>
        <cfinclude template="/views/auth/login.cfm">
    </cfcatch>
</cftry>
