component output="false" displayName="BaseRestController" {
    private struct function authorize() {
        if (not structKeyExists(cgi, "http_authorization")) {
            throw(type="Unauthorized", message="No Authorization header found");
        }

        var authHeader = cgi.http_authorization;
        if (left(authHeader, 7) neq "Bearer ") {
            throw(type="Unauthorized", message="Invalid Authorization header");
        }

        var token = trim(mid(authHeader, 8)); 
        var tokenHelper = new helpers.Token();
        return tokenHelper.verifyToken(token);
    }
}
