<cfscript>
    if (NOT structKeyExists(session, "isLoggedIn") OR NOT session.isLoggedIn) {
        writeLog(file="categoryHandler", text="Authentication failed - session.isLoggedIn: " & structKeyExists(session, 'isLoggedIn'));
        location(url="/views/auth/login.cfm", addtoken="false");
        abort;
    }
    response = {success = false, message = ""}; 
    try {
        categoryRepo = new repositories.CategoryRepository();
        action = form.action ?: "";
        
        switch(action) {
            case "create":
                // Create new category
                if (NOT structKeyExists(form, "name")) {
                    response.message = "Category name is required";
                    break;
                }
                result = categoryRepo.create(
                    userId = session.userId,
                    name = form.name,
                    description = form.description ?: "",
                    color = form.color ?: "##FF8C55"
                );
                
                if (result.success) {
                    response.success = true;
                    response.message = "Category created successfully";
                } else {
                    response.message = result.message;
                }
                break;
            case "update":
                // Update existing category
                if (NOT structKeyExists(form, "id")) {
                    response.message = "Category ID is required";
                    break;
                }
                
                updateArgs = {
                    id = form.id,
                    userId = session.userId
                };
                
                if (structKeyExists(form, "name")) updateArgs.name = form.name;
                if (structKeyExists(form, "description")) updateArgs.description = form.description;
                if (structKeyExists(form, "color")) updateArgs.color = form.color;
                
                success = categoryRepo.update(argumentCollection=updateArgs);
                
                if (success) {
                    response.success = true;
                    response.message = "Category updated successfully";
                } else {
                    response.message = "Failed to update category";
                }
                break;

            case "delete":
                // Delete category
                if (NOT structKeyExists(form, "id")) {
                    response.message = "Category ID is required";
                    break;
                }
                
                success = categoryRepo.delete(form.id, session.userId);
                
                if (success) {
                    response.success = true;
                    response.message = "Category deleted successfully";
                } else {
                    response.message = "Failed to delete category";
                }
                break;

            default:
                response.message = "Invalid action";
        }
        
    } catch (any e) {
        response.message = "Error: " & e.message;
    }
    
    // Redirect back to dashboard with message
    if (response.success) {
        session.successMessage = response.message;
    } else {
        session.errorMessage = response.message;
    }
    
    location(url="/views/dashboard/index.cfm##categories", addtoken="false");
</cfscript>

