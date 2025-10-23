<section id="categories" class="dashboard-section">
    <div class="section-header">
        <h2>Manage Categories</h2>
        <button class="btn btn-primary" onclick="openCategoryModal()">
            <span class="icon icon-plus"></span> Add Category
        </button>
    </div>

    <!-- Categories Grid -->
    <div class="categories-grid">
        <cfif categories.recordCount GT 0>
            <cfloop query="categories">
                <cfset usageCount = categoryRepo.getUsageCount(categories.id, session.userId)>
                <div class="category-card" data-category-id="<cfoutput>#categories.id#</cfoutput>">
                    <div class="category-card-header" style="background: <cfoutput>#categories.color#</cfoutput>;">
                        <h3><cfoutput>#categories.name#</cfoutput></h3>
                    </div>
                    <div class="category-card-body">
                        <p class="category-description"><cfoutput>#categories.description#</cfoutput></p>
                        <div class="category-stats">
                            <span class="stat-label">Used in expenses:</span>
                            <cfoutput><span class="stat-number">#usageCount#</span></cfoutput>
                        </div>
                    </div>
                    <div class="category-card-footer">
                        <cfoutput>
                            <button class="btn-icon"
                                    data-id="#categories.id#"
                                    data-name="#encodeForHTMLAttribute(categories.name & "")#"
                                    data-description="#encodeForHTMLAttribute(categories.description & "")#"
                                    data-color="#encodeForHTMLAttribute(categories.color & "")#"
                                    onclick="editCategoryFromElement(this)"
                                    title="Edit">
                                <span class="icon icon-edit"></span>
                            </button>
                            <button class="btn-icon btn-danger" onclick="deleteCategory(#categories.id#, '#JSStringFormat(categories.name)#')" title="Delete">
                                <span class="icon icon-trash"></span>
                            </button>
                        </cfoutput>
                    </div>
                </div>
            </cfloop>
        <cfelse>
            <div class="empty-state-full">
                <span class="icon icon-tags-large"></span>
                <p>No categories yet. Create your first category!</p>
            </div>
        </cfif>
    </div>
</section>

<!-- Add/Edit Category Modal -->
<div id="categoryModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="categoryModalTitle">Add Category</h3>
            <span class="close" onclick="closeCategoryModal()">&times;</span>
        </div>
        <form id="categoryForm" method="POST" action="/controllers/categoryHandler.cfm" onsubmit="return prepareCategory(event)">
            <input type="hidden" id="categoryId" name="id">
            <input type="hidden" id="categoryAction" name="action" value="create">
            
            <div class="form-group">
                <label for="categoryName">Category Name *</label>
                <input type="text" id="categoryName" name="name" class="form-input" 
                       placeholder="e.g., Food & Dining" required maxlength="50">
            </div>

            <div class="form-group">
                <label for="categoryDescription">Description</label>
                <textarea id="categoryDescription" name="description" class="form-textarea" 
                          rows="2" placeholder="Brief description of this category..."></textarea>
            </div>

            <div class="form-group">
                <label for="categoryColor">Color *</label>
                <div class="color-picker">
                    <input type="color" id="categoryColor" name="color" value="#FF8C55">
                    <span class="color-preview" id="colorPreview"></span>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeCategoryModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Category</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteConfirmModal" class="modal">
    <div class="modal-content" style="max-width: 400px;">
        <div class="modal-header">
            <h3>Confirm Delete</h3>
            <span class="close" onclick="closeDeleteConfirm()">&times;</span>
        </div>
        <div class="modal-body">
            <p id="deleteConfirmMessage">Are you sure you want to delete this category?</p>
            <p style="color: #666; font-size: 0.9em; margin-top: 10px;">This action cannot be undone.</p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeDeleteConfirm()">Cancel</button>
            <button type="button" class="btn btn-danger" onclick="confirmDelete()">Delete</button>
        </div>
    </div>
</div>
