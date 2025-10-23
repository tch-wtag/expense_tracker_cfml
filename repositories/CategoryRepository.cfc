component extends="BaseRepository" displayname="CategoryRepository" hint="Repository for category data access" {
    /**
     * Get all categories for a user
     */
    public query function findByUserId(required numeric userId) {
        var sql = "
            SELECT id, user_id, name, description, color, created_at, updated_at
            FROM categories
            WHERE user_id = :userId
            ORDER BY name ASC";
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };      
        return executeQuery(sql, params);
    }

    /**
     * Find category by ID
     */
    public query function findById(required numeric id, required numeric userId) {
        var sql = "
            SELECT id, user_id, name, description, color, created_at, updated_at
            FROM categories
            WHERE id = :id AND user_id = :userId
        ";
        
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        return executeQuery(sql, params);
    }

    /**
     * Create a new category
     */
    public struct function create(required numeric userId, required string name, string description="", string color="##FF8C55") {
        var sql = "
            INSERT INTO categories (user_id, name, description, color)
            VALUES (:userId, :name, :description, :color)";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"},
            name = {value=trim(arguments.name), type="cf_sql_varchar"},
            description = {value=arguments.description, type="cf_sql_varchar"},
            color = {value=arguments.color, type="cf_sql_varchar"}
        };
        try {
            var result = executeUpdate(sql, params);
            // The prefix object contains GENERATEDKEY (uppercase) from cfquery result
            var insertId = structKeyExists(result, "GENERATEDKEY") ? result.GENERATEDKEY : 
                          (structKeyExists(result, "generatedKey") ? result.generatedKey : 0);
            return {success=true, insertId=insertId};
        } catch (any e) {
            return {success=false, message=e.message};
        }
    }
    /**
     * Check if category name exists for user
     */
    public boolean function nameExistsForUser(required string name, required numeric userId, numeric excludeId=0) {
        var sql = "
            SELECT COUNT(*) as count 
            FROM categories 
            WHERE user_id = :userId AND LOWER(name) = LOWER(:name)";
        if (arguments.excludeId > 0) {
            sql &= " AND id != :excludeId";
        }
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"},
            name = {value=trim(arguments.name), type="cf_sql_varchar"}
        };
        if (arguments.excludeId > 0) {
            params.excludeId = {value=arguments.excludeId, type="cf_sql_integer"};
        }
        var result = executeQuery(sql, params);
        return result.count[1] > 0;
    }
    /**
     * Update category
     */
    public boolean function update(required numeric id, required numeric userId, string name, string description, string color) {
        var setParts = [];
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        if (structKeyExists(arguments, "name") && len(trim(arguments.name))) {
            arrayAppend(setParts, "name = :name");
            params.name = {value=trim(arguments.name), type="cf_sql_varchar"};
        }
        
        if (structKeyExists(arguments, "description")) {
            arrayAppend(setParts, "description = :description");
            params.description = {value=arguments.description, type="cf_sql_varchar"};
        }
        
        if (structKeyExists(arguments, "color") && len(trim(arguments.color))) {
            arrayAppend(setParts, "color = :color");
            params.color = {value=arguments.color, type="cf_sql_varchar"};
        }
        
        if (arrayLen(setParts) == 0) return false;
        
        var sql = "UPDATE categories SET " & arrayToList(setParts, ", ") & " WHERE id = :id AND user_id = :userId";
        
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Get category usage count (number of expenses)
     */
    public numeric function getUsageCount(required numeric id, required numeric userId) {
        var sql = "
            SELECT COUNT(*) as count
            FROM expenses
            WHERE category_id = :id AND user_id = :userId
        ";
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        var result = executeQuery(sql, params);
        return result.count[1];
    }
}

