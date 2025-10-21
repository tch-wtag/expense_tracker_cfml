component output="false" rest="true" restPath="categories" displayName="CategoriesController" {
    // Private helper to authorize JWT token
    private struct function authorize() {
        if (not structKeyExists(cgi,"http_authorization")) {
            throw(type="Unauthorized", message="No Authorization header found");
        }
        var authHeader = cgi.http_authorization;
        if (left(authHeader,7) neq "Bearer ") {
            throw(type="Unauthorized", message="Invalid Authorization header");
        }

        var token = trim(mid(authHeader,8)); // Remove "Bearer "
        var tokenHelper = new helpers.Token();
        return tokenHelper.verifyToken(token);
    }

    /**
     * GET all categories for the authenticated user
     * GET /api/categories
     */
    function getAll() access="remote" httpMethod="GET" returnFormat="json" output="false" {
        var response = {};
        try {
            var user = authorize();
            var repo = new repositories.CategoryRepository();
            var result = repo.findByUserId(user.sub);
            response = {
                status = "success",
                categories = repo.queryToArray(result)
            };

        } catch (any e) {
            response = {status="error", message=e.message};
        }
        return response;
    }

    function getById(required numeric id) access="remote" httpMethod="GET" restPath="{id}" returnFormat="json" output="false" {
        var response = {};
        try {
            var user = authorize();
            var repo = new repositories.CategoryRepository();
            var result = repo.findById(arguments.id, user.sub);
            if (result.recordCount > 0) {
                var categories = repo.queryToArray(result);
                response = {
                    status = "success",
                    category = categories[1]
                };
            } else {
                response = {status="error", message="Category not found"};
            }
        } catch (any e) {
            response = {status="error", message=e.message};
        }
        return response;
    }

    /**
     * CREATE a new category
     * POST /api/categories
     */
    function create(
        required string name,
        string description="",
        string color="##FF8C55"
    ) access="remote" httpMethod="POST" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var repo = new repositories.CategoryRepository();
            if (repo.nameExistsForUser(arguments.name, user.sub)) {
                response = {status="error", message="Category name already exists"};
                return response;
            }          
            var result = repo.create(
                userId = user.sub,
                name = arguments.name,
                description = arguments.description,
                color = arguments.color
            );    
            if (result.success) {
                response = {
                    status = "success",
                    message = "Category created successfully",
                    categoryId = result.insertId
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
     * UPDATE an existing category
     * PUT /api/categories/{id}
     */
    function update(
        required numeric id,
        string name,
        string description,
        string color
    ) access="remote" httpMethod="PUT" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var repo = new repositories.CategoryRepository();
            
            // Check if category exists and belongs to user
            var existing = repo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                response = {status="error", message="Category not found"};
                return response;
            }
            
            // Check if new name conflicts with existing category
            if (structKeyExists(arguments, "name") && len(trim(arguments.name))) {
                if (repo.nameExistsForUser(arguments.name, user.sub, arguments.id)) {
                    response = {status="error", message="Category name already exists"};
                    return response;
                }
            }
            
            var updateArgs = {id=arguments.id, userId=user.sub};
            if (structKeyExists(arguments, "name")) updateArgs.name = arguments.name;
            if (structKeyExists(arguments, "description")) updateArgs.description = arguments.description;
            if (structKeyExists(arguments, "color")) updateArgs.color = arguments.color;
            
            var success = repo.update(argumentCollection=updateArgs);
            
            if (success) {
                response = {
                    status = "success",
                    message = "Category updated successfully"
                };
            } else {
                response = {status="error", message="Failed to update category"};
            }

        } catch (any e) {
            response = {status="error", message=e.message};
        }

        return response;
    }
}