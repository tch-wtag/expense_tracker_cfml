component output="false" rest="true" restPath="categories" displayName="CategoriesController" extends="BaseRestController" {
    /**
     * GET all categories for the authenticated user
     * GET /api/categories
     */
    function getAll() access="remote" httpMethod="GET" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var categoryRepo = new repositories.CategoryRepository();
            var result = categoryRepo.findByUserId(user.sub);
            
            setHTTPStatus(200); // OK
            response = {
                status = "success",
                categories = categoryRepo.queryToArray(result)
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
     * GET a single category by ID
     * GET /api/categories/{id}
     */
    function getById(required numeric id) access="remote" httpMethod="GET" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var categoryRepo = new repositories.CategoryRepository();
            var result = categoryRepo.findById(arguments.id, user.sub);
            
            if (result.recordCount > 0) {
                setHTTPStatus(200); // OK
                var categories = categoryRepo.queryToArray(result);
                response = {
                    status = "success",
                    category = categories[1]
                };
            } else {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Category not found"
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
            var categoryRepo = new repositories.CategoryRepository();
            
            // Check if category name already exists
            if (categoryRepo.nameExistsForUser(arguments.name, user.sub)) {
                setHTTPStatus(409, "Conflict");
                response = {
                    status = "error",
                    message = "Category name already exists"
                };
                return response;
            }
            
            var result = categoryRepo.create(
                userId = user.sub,
                name = arguments.name,
                description = arguments.description,
                color = arguments.color
            );
            
            if (result.success) {
                setHTTPStatus(201, "Created");
                response = {
                    status = "success",
                    message = "Category created successfully",
                    categoryId = result.insertId
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
            var categoryRepo = new repositories.CategoryRepository();
            
            // Check if category exists and belongs to user
            var existing = categoryRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Category not found"
                };
                return response;
            }
            
            // Check if new name conflicts with existing category
            if (structKeyExists(arguments, "name") && len(trim(arguments.name))) {
                if (categoryRepo.nameExistsForUser(arguments.name, user.sub, arguments.id)) {
                    setHTTPStatus(409, "Conflict");
                    response = {
                        status = "error",
                        message = "Category name already exists"
                    };
                    return response;
                }
            }
            
            var updateArgs = {id=arguments.id, userId=user.sub};
            if (structKeyExists(arguments, "name")) updateArgs.name = arguments.name;
            if (structKeyExists(arguments, "description")) updateArgs.description = arguments.description;
            if (structKeyExists(arguments, "color")) updateArgs.color = arguments.color;
            
            var success = categoryRepo.update(argumentCollection=updateArgs);
            
            if (success) {
                setHTTPStatus(200); // OK
                response = {
                    status = "success",
                    message = "Category updated successfully"
                };
            } else {
                setHTTPStatus(400, "Bad Request");
                response = {
                    status = "error",
                    message = "Failed to update category"
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
     * DELETE a category
     * DELETE /api/categories/{id}
     */
    function remove(required numeric id) access="remote" httpMethod="DELETE" restPath="{id}" returnFormat="json" output="false" {
        var response = {};

        try {
            var user = authorize();
            var categoryRepo = new repositories.CategoryRepository();
            
            // Check if category exists and belongs to user
            var existing = categoryRepo.findById(arguments.id, user.sub);
            if (existing.recordCount == 0) {
                setHTTPStatus(404, "Not Found");
                response = {
                    status = "error",
                    message = "Category not found"
                };
                return response;
            }
            
            // Check if category is in use
            var usageCount = categoryRepo.getUsageCount(arguments.id, user.sub);
            if (usageCount > 0) {
                response = {
                    status = "warning",
                    message = "This category is used in " & usageCount & " expense(s). Deleting it will set those expenses' category to null.",
                    usageCount = usageCount
                };
                // Still allow deletion - foreign key is set to ON DELETE SET NULL
            }
            
            var success = categoryRepo.delete(arguments.id, user.sub);
            
            if (success) {
                setHTTPStatus(200); // OK
                response = {
                    status = "success",
                    message = "Category deleted successfully"
                };
            } else {
                setHTTPStatus(500, "Internal Server Error");
                response = {
                    status = "error",
                    message = "Failed to delete category"
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
}