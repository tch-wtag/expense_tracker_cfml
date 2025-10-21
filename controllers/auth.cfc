component output="false" rest="true" restPath="auth" displayName="AuthController" {
    function signup(
        required string username,
        required string email,
        required string password
    ) access="remote" httpMethod="POST" restPath="signup" returnFormat="json" output="false" {
        var response = {};
        try {
            if (len(trim(arguments.username)) == 0) {
                return { status="error", message="Username is required" };
            }
            if (len(trim(arguments.email)) == 0) {
                return { status="error", message="Email is required" };
            }
            if (len(trim(arguments.password)) < 6) {
                return { status="error", message="Password must be at least 6 characters" };
            }

            var userRepo = new repositories.UserRepository();
            if (userRepo.emailExists(arguments.email)) {
                return { status="error", message="Email already exists" };
            }
            var passwordHelper = new helpers.PasswordHelper();
            var hashedPassword = passwordHelper.hashPassword(trim(arguments.password));

            // Create user
            var result = userRepo.create(
                username = trim(arguments.username),
                email = trim(arguments.email),
                password = hashedPassword
            );

            if (result.success) {

                response = {
                    status = "success",
                    message = "User created successfully",
                    userId = result.insertId
                };
            } else {
                response = { status="error", message=result.message };
            }
        } catch (any e) {
            response = { status="error", message=e.message };
        }
        return response;
    }


    function login(
        required string email,
        required string password
    ) access="remote" httpMethod="POST" restPath="login" returnFormat="json" output="false" {
        var response = {};

        try {
            var userRepo = new repositories.UserRepository();
            var passwordHelper = new helpers.PasswordHelper();

            // Find user by email
            var userResult = userRepo.findByEmail(arguments.email);

            if (userResult.recordCount == 0) {
                return { status="error", message="Invalid email or password" };
            }
            var storedHash = userResult.password[1];
            if (passwordHelper.verifyPassword(trim(arguments.password), storedHash)) {
                session.isLoggedIn = true;
                session.userId = userResult.id[1];
                session.username = userResult.username[1];

                var tokenHelper = new helpers.Token();
                var jwt = tokenHelper.generateToken(userResult.id[1], userResult.username[1]);

                response = {
                    status = "success",
                    message = "Login successful",
                    token = jwt,
                    user = {
                        id = userResult.id[1],
                        username = userResult.username[1],
                        email = userResult.email[1]
                    }
                };
            } else {
                response = { status="error", message="Invalid email or password" };
            }

        } catch (any e) {
            response = { status="error", message=e.message };
        }
        return response;
    }


    function logout() access="remote" httpMethod="POST" restPath="logout" returnFormat="json" output="false" {
        var response = {};
        try {
            if (structKeyExists(session, "isLoggedIn")) {
                sessionInvalidate();
            }
            response = {
                status = "success",
                message = "Logged out successfully"
            };
        } catch (any e) {
            response = { status="error", message=e.message };
        }
        return response;
    }
    function getCurrentUser() access="remote" httpMethod="GET" restPath="me" returnFormat="json" output="false" {
        var response = {};
        try {
            if (structKeyExists(session, "isLoggedIn") && session.isLoggedIn) {
                var userRepo = new repositories.UserRepository();
                var result = userRepo.findById(session.userId);

                if (result.recordCount > 0) {
                    response = {
                        status = "success",
                        user = {
                            id = result.id[1],
                            username = result.username[1],
                            email = result.email[1],
                            created_at = result.created_at[1]
                        }
                    };
                } else {
                    response = { status="error", message="User not found" };
                }
            } else {
                response = { status="error", message="Not authenticated" };
            }

        } catch (any e) {
            response = { status="error", message=e.message };
        }
        return response;
    }
}
