component extends="BaseRepository" displayname="ExpenseRepository" hint="Repository for expense data access" {
    /**
     * Get all expenses for a user
     */
    public query function findByUserId(required numeric userId, string orderBy="expense_date DESC") {
        var sql = "
            SELECT e.id, e.user_id, e.category_id, e.category_name, 
                   e.amount, e.expense_date, e.description, 
                   e.created_at, e.updated_at,
                   c.color as category_color
            FROM expenses e
            LEFT JOIN categories c ON e.category_id = c.id
            WHERE e.user_id = :userId
            ORDER BY #arguments.orderBy#
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        return executeQuery(sql, params);
    }

    /**
     * Find expense by ID
     */
    public query function findById(required numeric id, required numeric userId) {
        var sql = "
            SELECT e.id, e.user_id, e.category_id, e.category_name, 
                   e.amount, e.expense_date, e.description, 
                   e.created_at, e.updated_at,
                   c.color as category_color
            FROM expenses e
            LEFT JOIN categories c ON e.category_id = c.id
            WHERE e.id = :id AND e.user_id = :userId
        ";
        
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        return executeQuery(sql, params);
    }

    /**
     * Create a new expense
     */
    public struct function create(
        required numeric userId, 
        numeric categoryId=0,
        required string categoryName,
        required numeric amount, 
        required date expenseDate, 
        string description=""
    ) {
        var sql = "
            INSERT INTO expenses (user_id, category_id, category_name, amount, expense_date, description)
            VALUES (:userId, :categoryId, :categoryName, :amount, :expenseDate, :description)
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"},
            categoryId = {value=arguments.categoryId == 0 ? javaCast("null", "") : arguments.categoryId, type="cf_sql_integer", null=arguments.categoryId == 0},
            categoryName = {value=arguments.categoryName, type="cf_sql_varchar"},
            amount = {value=arguments.amount, type="cf_sql_decimal"},
            expenseDate = {value=arguments.expenseDate, type="cf_sql_date"},
            description = {value=arguments.description, type="cf_sql_varchar"}
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
}