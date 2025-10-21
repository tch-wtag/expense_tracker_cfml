<cfscript>
    if (NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn) {
        writeLog(file="expenseHandler", text="Authentication failed - session.isLoggedIn: " & structKeyExists(session, 'isLoggedIn'));
        location(url="/views/auth/login.cfm", addtoken="false");
        abort;
    }

    response = {success = false, message = ""};
    
    try {
        expenseRepo = new repositories.ExpenseRepository();
        action = form.action ?: "";
        
        switch(action) {
            case "create":
                // Create new expense
                if (NOT structKeyExists(form, "categoryId") OR NOT structKeyExists(form, "categoryName") OR 
                    NOT structKeyExists(form, "amount") OR NOT structKeyExists(form, "expenseDate")) {
                    response.message = "Missing required fields";
                    break;
                }
                
                categoryId = val(form.categoryId);
                if (categoryId == 0) {
                    categoryId = javaCast("null", "");
                }
                
                result = expenseRepo.create(
                    userId = session.userId,
                    categoryId = categoryId,
                    categoryName = form.categoryName,
                    amount = form.amount,
                    expenseDate = parseDateTime(form.expenseDate),
                    description = form.description ?: ""
                );
                
                if (result.success) {
                    response.success = true;
                    response.message = "Expense added successfully";
                } else {
                    response.message = result.message;
                }
                break;
            default:
                response.message = "Invalid action";
        }
        
    } catch (any e) {
        response.message = "Error: " & e.message;
    }
    
    if (response.success) {
        session.successMessage = response.message;
    } else {
        session.errorMessage = response.message;
    }
    
    location(url="/views/dashboard/index.cfm", addtoken="false");
</cfscript>

