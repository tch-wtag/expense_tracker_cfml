component output="false" rest="true" restPath="expenses" displayName="ExpensesController" extends="BaseRestController" {
    /**
     * GET all expenses for authenticated user
     * GET /api/expenses
     */
    function getAll() access="remote" httpMethod="GET" returnFormat="json" output="false" {
        var response = {};
        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            var result = expenseRepo.findByUserId(user.sub);
            
            setHTTPStatus(200); // OK
            response = {
                status = "success",
                expenses = expenseRepo.queryToArray(result)
            };

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
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
                setHTTPStatus(200); // OK
                var expenses = expenseRepo.queryToArray(result);
                response = {
                    status = "success",
                    expense = expenses[1]
                };
            } else {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Expense not found"
                };
            }

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
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
                setHTTPStatus(201, "Created");
                response = {
                    status = "success",
                    message = "Expense added successfully",
                    expenseId = result.insertId
                };
            } else {
                setHTTPStatus(400, "Bad Request");
                response = {
                    status = "error",
                    message = result.message
                };
            }

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
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
            
            // Check if expense exists and belongs to user
            var existing = expenseRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Expense not found"
                };
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
                setHTTPStatus(200); // OK
                response = {
                    status = "success",
                    message = "Expense updated successfully"
                };
            } else {
                setHTTPStatus(400, "Bad Request");
                response = {
                    status = "error",
                    message = "Failed to update expense"
                };
            }

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
        }

        return response;
    }
    /**
     * DELETE an expense
     * DELETE /api/expenses/{id}
     */
    function remove(required numeric id) access="remote" httpMethod="DELETE" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            // Check if expense exists and belongs to user
            var existing = expenseRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Expense not found"
                };
                return response;
            }
            
            var success = expenseRepo.delete(arguments.id, user.sub);
            
            if (success) {
                setHTTPStatus(200); // OK
                response = {
                    status = "success",
                    message = "Expense deleted successfully"
                };
            } else {
                setHTTPStatus(500, "Internal Server Error");
                response = {
                    status = "error",
                    message = "Failed to delete expense"
                };
            }

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
        }

        return response;
    }

<<<<<<< HEAD
=======
    /**
     * GET expenses by date range
     * GET /api/expenses/range?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
     */
    function getByDateRange(required string startDate, required string endDate) access="remote" httpMethod="GET" restPath="range" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            var start = parseDateTime(arguments.startDate);
            var end = parseDateTime(arguments.endDate);
            
            var result = expenseRepo.findByDateRange(user.sub, start, end);
            
            setHTTPStatus(200); // OK
            response = {
                status = "success",
                expenses = expenseRepo.queryToArray(result),
                startDate = arguments.startDate,
                endDate = arguments.endDate
            };

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else if (findNoCase("invalid date", e.message)) {
                setHTTPStatus(400, "Bad Request");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
        }

        return response;
    }

    /**
     * GET total spending by category
     * GET /api/expenses/summary/category?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
     */
    function getSummaryByCategory(string startDate, string endDate) access="remote" httpMethod="GET" restPath="summary/category" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            var args = {userId = user.sub};
            if (structKeyExists(arguments, "startDate") && structKeyExists(arguments, "endDate")) {
                args.startDate = parseDateTime(arguments.startDate);
                args.endDate = parseDateTime(arguments.endDate);
            }
            
            var result = expenseRepo.getTotalByCategory(argumentCollection=args);
            
            setHTTPStatus(200); // OK
            response = {
                status = "success",
                summary = expenseRepo.queryToArray(result)
            };

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else if (findNoCase("invalid date", e.message)) {
                setHTTPStatus(400, "Bad Request");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
        }

        return response;
    }

    /**
     * GET expense statistics
     * GET /api/expenses/statistics?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
     */
    function getStatistics(string startDate, string endDate) access="remote" httpMethod="GET" restPath="statistics" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var expenseRepo = new repositories.ExpenseRepository();
            
            var args = {userId = user.sub};
            if (structKeyExists(arguments, "startDate") && structKeyExists(arguments, "endDate")) {
                args.startDate = parseDateTime(arguments.startDate);
                args.endDate = parseDateTime(arguments.endDate);
            }
            
            var stats = expenseRepo.getStatistics(argumentCollection=args);
            
            setHTTPStatus(200); // OK
            response = {
                status = "success",
                statistics = stats
            };

        } catch (any e) {
            if (e.type == "Unauthorized") {
                setHTTPStatus(401, "Unauthorized");
            } else if (findNoCase("invalid date", e.message)) {
                setHTTPStatus(400, "Bad Request");
            } else {
                setHTTPStatus(500, "Internal Server Error");
            }
            response = {
                status = "error",
                message = e.message
            };
        }

        return response;
    }
>>>>>>> 3e00ebb (Feat: Introduced REST endpoints for reporting data.)
}