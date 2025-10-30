component extends="BaseRepository" displayname="ExpenseRepository" hint="Repository for expense data access" {
    /**
     * Get all expenses for a user
     */
    public query function findByUserId(required numeric userId, string orderBy="expense_date DESC") {
        var sql = "
            SELECT e.id, e.user_id, e.category_id, e.category_name, 
                   e.amount, e.expense_date, e.description, 
                   e.created_at, e.updated_at,
                   COALESCE(c.color, '##FF8C55') as category_color
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
                   COALESCE(c.color, '##FF8C55') as category_color
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
            categoryName = {value=arguments.categoryName, type="cf_sql_varchar"},
            amount = {value=arguments.amount, type="cf_sql_decimal"},
            expenseDate = {value=arguments.expenseDate, type="cf_sql_date"},
            description = {value=arguments.description, type="cf_sql_varchar"}
        };
        
        // Handle categoryId with proper NULL handling
        if (arguments.categoryId == 0) {
            params.categoryId = {value="", type="cf_sql_integer", null=true};
        } else {
            params.categoryId = {value=arguments.categoryId, type="cf_sql_integer", null=false};
        }
        
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
     * Update expense
     */
    public boolean function update(
        required numeric id, 
        required numeric userId,
        numeric categoryId,
        string categoryName,
        numeric amount,
        date expenseDate,
        string description
    ) {
        var setParts = [];
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        if (structKeyExists(arguments, "categoryId")) {
            arrayAppend(setParts, "category_id = :categoryId");
            if (arguments.categoryId == 0) {
                params.categoryId = {value="", type="cf_sql_integer", null=true};
            } else {
                params.categoryId = {value=arguments.categoryId, type="cf_sql_integer", null=false};
            }
        }
        
        if (structKeyExists(arguments, "categoryName")) {
            arrayAppend(setParts, "category_name = :categoryName");
            params.categoryName = {value=arguments.categoryName, type="cf_sql_varchar"};
        }
        
        if (structKeyExists(arguments, "amount")) {
            arrayAppend(setParts, "amount = :amount");
            params.amount = {value=arguments.amount, type="cf_sql_decimal"};
        }
        
        if (structKeyExists(arguments, "expenseDate")) {
            arrayAppend(setParts, "expense_date = :expenseDate");
            params.expenseDate = {value=arguments.expenseDate, type="cf_sql_date"};
        }
        
        if (structKeyExists(arguments, "description")) {
            arrayAppend(setParts, "description = :description");
            params.description = {value=arguments.description, type="cf_sql_varchar"};
        }
        
        if (arrayLen(setParts) == 0) return false;
        
        var sql = "UPDATE expenses SET " & arrayToList(setParts, ", ") & " WHERE id = :id AND user_id = :userId";
        
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Delete expense
     */
    public boolean function delete(required numeric id, required numeric userId) {
        var sql = "DELETE FROM expenses WHERE id = :id AND user_id = :userId";
        
        var params = {
            id = {value=arguments.id, type="cf_sql_integer"},
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        try {
            executeUpdate(sql, params);
            return true;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Get expenses by date range
     */
    public query function findByDateRange(required numeric userId, required date startDate, required date endDate) {
        var sql = "
            SELECT e.id, e.user_id, e.category_id, e.category_name, 
                   e.amount, e.expense_date, e.description, 
                   e.created_at, e.updated_at,
                   COALESCE(c.color, '##FF8C55') as category_color
            FROM expenses e
            LEFT JOIN categories c ON e.category_id = c.id
            WHERE e.user_id = :userId 
            AND e.expense_date BETWEEN :startDate AND :endDate
            ORDER BY e.expense_date DESC
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"},
            startDate = {value=arguments.startDate, type="cf_sql_date"},
            endDate = {value=arguments.endDate, type="cf_sql_date"}
        };
        
        return executeQuery(sql, params);
    }

    /**
     * Get total spending by category
     */
    public query function getTotalByCategory(required numeric userId, date startDate, date endDate) {
        var sql = "
            SELECT 
                e.category_name,
                COALESCE(c.color, '##FF8C55') as category_color,
                SUM(e.amount) as total_amount,
                COUNT(*) as expense_count
            FROM expenses e
            LEFT JOIN categories c ON e.category_id = c.id
            WHERE e.user_id = :userId
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        if (structKeyExists(arguments, "startDate") && structKeyExists(arguments, "endDate")) {
            sql &= " AND e.expense_date BETWEEN :startDate AND :endDate";
            params.startDate = {value=arguments.startDate, type="cf_sql_date"};
            params.endDate = {value=arguments.endDate, type="cf_sql_date"};
        }
        
        sql &= " GROUP BY e.category_name, c.color ORDER BY total_amount DESC";
        
        return executeQuery(sql, params);
    }

    /**
     * Get total spending for a time period
     */
    public numeric function getTotalSpending(required numeric userId, date startDate, date endDate) {
        var sql = "
            SELECT COALESCE(SUM(amount), 0) as total
            FROM expenses
            WHERE user_id = :userId
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        if (structKeyExists(arguments, "startDate") && structKeyExists(arguments, "endDate")) {
            sql &= " AND expense_date BETWEEN :startDate AND :endDate";
            params.startDate = {value=arguments.startDate, type="cf_sql_date"};
            params.endDate = {value=arguments.endDate, type="cf_sql_date"};
        }
        
        var result = executeQuery(sql, params);
        return result.total[1];
    }

    /**
     * Get daily spending totals
     */
    public query function getDailyTotals(required numeric userId, required date startDate, required date endDate) {
        var sql = "
            SELECT 
                expense_date,
                SUM(amount) as daily_total,
                COUNT(*) as expense_count
            FROM expenses
            WHERE user_id = :userId
            AND expense_date BETWEEN :startDate AND :endDate
            GROUP BY expense_date
            ORDER BY expense_date ASC
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"},
            startDate = {value=arguments.startDate, type="cf_sql_date"},
            endDate = {value=arguments.endDate, type="cf_sql_date"}
        };
        
        return executeQuery(sql, params);
    }

    /**
     * Get expense statistics
     */
    public struct function getStatistics(required numeric userId, date startDate, date endDate) {
        var sql = "
            SELECT 
                COUNT(*) as total_count,
                COALESCE(SUM(amount), 0) as total_amount,
                COALESCE(AVG(amount), 0) as avg_amount,
                COALESCE(MAX(amount), 0) as max_amount,
                COALESCE(MIN(amount), 0) as min_amount
            FROM expenses
            WHERE user_id = :userId
        ";
        
        var params = {
            userId = {value=arguments.userId, type="cf_sql_integer"}
        };
        
        if (structKeyExists(arguments, "startDate") && structKeyExists(arguments, "endDate")) {
            sql &= " AND expense_date BETWEEN :startDate AND :endDate";
            params.startDate = {value=arguments.startDate, type="cf_sql_date"};
            params.endDate = {value=arguments.endDate, type="cf_sql_date"};
        }
        
        var result = executeQuery(sql, params);
        
        return {
            totalCount = result.total_count[1],
            totalAmount = result.total_amount[1],
            avgAmount = result.avg_amount[1],
            maxAmount = result.max_amount[1],
            minAmount = result.min_amount[1]
        };
    }
}