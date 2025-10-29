component output="false" rest="true" restPath="expenses" displayName="ExpensesController" extends="BaseRestController" {

    function getAll() access="remote" httpMethod="GET" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            var result = expenseRepo.findByUserId(user.sub);
            
            response = {
                status = "success",
                expenses = expenseRepo.queryToArray(result)
            };

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }

    /**
     * GET a single expense by ID
     * GET /api/expenses/{id}
     */
    function getById(required numeric id) access="remote" httpMethod="GET" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            var result = expenseRepo.findById(arguments.id, user.sub);
            
            if (result.recordCount > 0) {
                var expenses = expenseRepo.queryToArray(result);
                response = {
                    status = "success",
                    expense = expenses[1]
                };
            } else {
                response = {status="error", message="Expense not found"};
            }

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }

    /**
     * CREATE a new expense
     * POST /api/expenses
     */
    function create(
        numeric categoryId=0,
        required string categoryName,
        required numeric amount,
        required string expenseDate,
        string description=""
    ) access="remote" httpMethod="POST" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            // Parse date if string
            var expDate = isDate(arguments.expenseDate) ? parseDateTime(arguments.expenseDate) : arguments.expenseDate;
            
            var result = expenseRepo.create(
                userId = user.sub,
                categoryId = arguments.categoryId,
                categoryName = arguments.categoryName,
                amount = arguments.amount,
                expenseDate = expDate,
                description = arguments.description
            );
            
            if (result.success) {
                response = {
                    status = "success",
                    message = "Expense added successfully",
                    expenseId = result.insertId
                };
            } else {
                response = {status="error", message=result.message};
            }

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }

    /**
     * UPDATE an existing expense
     * PUT /api/expenses/{id}
     */
    function update(
        required numeric id,
        numeric categoryId,
        string categoryName,
        numeric amount,
        string expenseDate,
        string description
    ) access="remote" httpMethod="PUT" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            var existing = expenseRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                response = {status="error", message="Expense not found"};
                return response;
            }
            
            var updateArgs = {id=arguments.id, userId=user.sub};
            if (structKeyExists(arguments, "categoryId")) updateArgs.categoryId = arguments.categoryId;
            if (structKeyExists(arguments, "categoryName")) updateArgs.categoryName = arguments.categoryName;
            if (structKeyExists(arguments, "amount")) updateArgs.amount = arguments.amount;
            if (structKeyExists(arguments, "expenseDate")) {
                updateArgs.expenseDate = isDate(arguments.expenseDate) ? parseDateTime(arguments.expenseDate) : arguments.expenseDate;
            }
            if (structKeyExists(arguments, "description")) updateArgs.description = arguments.description;
            
            var success = expenseRepo.update(argumentCollection=updateArgs);
            
            if (success) {
                response = {
                    status = "success",
                    message = "Expense updated successfully"
                };
            } else {
                response = {status="error", message="Failed to update expense"};
            }

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }
    /**
     * DELETE an expense
     * DELETE /api/expenses/{id}
     */
    function remove(required numeric id) 
        access="remote" 
        httpMethod="DELETE" 
        restPath="{id}" 
        returnFormat="json" 
        output="false" {
            
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            // Check if expense exists and belongs to user
            var existing = expenseRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                response = {status="error", message="Expense not found"};
                return response;
            }
            
            var success = expenseRepo.delete(arguments.id, user.sub);
            
            if (success) {
                response = {
                    status = "success",
                    message = "Expense deleted successfully"
                };
            } else {
                response = {status="error", message="Failed to delete expense"};
            }

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }

}

