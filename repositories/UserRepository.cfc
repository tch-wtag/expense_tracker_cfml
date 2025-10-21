component extends="BaseRepository" displayname="UserRepository" hint="Repository for user data access" {
    /**
     * Find user by email
     */
    public query function findByEmail(required string email) {
        var sql = "
            SELECT id, username, email, password, created_at, updated_at
            FROM users
            WHERE email = :email
        ";
        var params = {
            email = {value=arguments.email, type="cf_sql_varchar"}
        };
        return executeQuery(sql, params);
    }
    /**
     * Find user by ID
     */
    public query function findById(required numeric id) {
        var sql = "
            SELECT id, username, email, created_at, updated_at
            FROM users
            WHERE id = :id
        ";
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"}
        };
        return executeQuery(sql, params);
    }

    /**
     * Create a new user
     */
    public struct function create(required string username, required string email, required string password) {
        var sql = "
            INSERT INTO users (username, email, password)
            VALUES (:username, :email, :password)
        ";
        var params = {
            username = {value=arguments.username, type="cf_sql_varchar"},
            email = {value=arguments.email, type="cf_sql_varchar"},
            password = {value=arguments.password, type="cf_sql_varchar"}
        };
        try {
            var result = executeUpdate(sql, params);
            return {success=true, insertId=result.generatedKey};
        } catch (any e) {
            return {success=false, message=e.message};
        }
    }

    /**
     * Update user details
     */
    public boolean function update(required numeric id, string username, string email) {
        var setParts = [];
        var params = {id = {value=arguments.id, type="cf_sql_integer"}};
        if (structKeyExists(arguments, "username")) {
            arrayAppend(setParts, "username = :username");
            params.username = {value=arguments.username, type="cf_sql_varchar"};
        }
        if (structKeyExists(arguments, "email")) {
            arrayAppend(setParts, "email = :email");
            params.email = {value=arguments.email, type="cf_sql_varchar"};
        }
        if (arrayLen(setParts) == 0) return false;
        var sql = "UPDATE users SET " & arrayToList(setParts, ", ") & " WHERE id = :id";
        
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Delete user
     */
    public boolean function delete(required numeric id) {
        var sql = "DELETE FROM users WHERE id = :id";
        var params = {id = {value=arguments.id, type="cf_sql_integer"}};
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Verify user credentials
     */
    public struct function verifyCredentials(required string email, required string hashedPassword) {
        var sql = "
            SELECT id, username, email, created_at
            FROM users
            WHERE email = :email AND password = :password
        ";
        
        var params = {
            email = {value=arguments.email, type="cf_sql_varchar"},
            password = {value=arguments.hashedPassword, type="cf_sql_varchar"}
        };
        
        var result = executeQuery(sql, params);
        
        if (result.recordCount > 0) {
            return {
                success = true,
                user = {
                    id = result.id[1],
                    username = result.username[1],
                    email = result.email[1],
                    created_at = result.created_at[1]
                }
            };
        } else {
            return {success = false, message = "Invalid credentials"};
        }
    }

    /**
     * Update user password (for security upgrades or password resets)
     */
    public boolean function updatePassword(required numeric id, required string hashedPassword) {
        var sql = "UPDATE users SET password = :password WHERE id = :id";
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            password = {value=arguments.hashedPassword, type="cf_sql_varchar"}
        };
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Check if email exists
     */
    public boolean function emailExists(required string email) {
        var sql = "SELECT COUNT(*) as count FROM users WHERE email = :email";
        var params = {email = {value=arguments.email, type="cf_sql_varchar"}};
        var result = executeQuery(sql, params);
        return result.count[1] > 0;
    }
}