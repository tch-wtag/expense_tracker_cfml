<cfparam name="form.username" default="">
<cfparam name="form.email" default="">
<cfparam name="form.password" default="">
<cfparam name="form.confirmPassword" default="">

<cfscript>
    errorMessage = "";
    successMessage = "";
    
    try {
        if (len(trim(form.username)) == 0) {
            errorMessage = "Username is required";
        } else if (len(trim(form.email)) == 0) {
            errorMessage = "Email is required";
        } else if (len(trim(form.password)) == 0) {
            errorMessage = "Password is required";
        } else if (len(trim(form.password)) < 6) {
            errorMessage = "Password must be at least 6 characters long";
        } else if (form.password neq form.confirmPassword) {
            errorMessage = "Passwords do not match";
        } else {
            userRepo = new repositories.UserRepository();
            if (userRepo.emailExists(form.email)) {
                errorMessage = "Email already exists. Please use a different email or login.";
            } else {
                passwordHelper = new helpers.PasswordHelper();
                hashedPassword = passwordHelper.hashPassword(trim(form.password));
                result = userRepo.create(
                    username = trim(form.username),
                    email = trim(form.email),
                    password = hashedPassword
                );
                
                if (result.success) {
                    successMessage = "Signup successful! Redirecting to login...";
                    variables.successMessage = successMessage;
                    include "/views/auth/signup.cfm";
                    abort;
                } else {
                    errorMessage = "Signup failed: " & result.message;
                }
            }
        }
        
        if (len(errorMessage) > 0) {
            variables.errorMessage = errorMessage;
            include "/views/auth/signup.cfm";
        }
        
    } catch (any e) {
        variables.errorMessage = "An error occurred: " & e.message;
        include "/views/auth/signup.cfm";
    }
</cfscript>