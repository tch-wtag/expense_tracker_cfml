<section id="expenses" class="dashboard-section">
    <div class="section-header">
        <h2>Manage Expenses</h2>
        <button class="btn btn-primary" onclick="openExpenseModal()">
            <span class="icon icon-plus"></span> Add Expense
        </button>
    </div>

    <!-- Expenses Table -->
    <div class="card">
        <div class="table-responsive">
            <table class="expense-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="expenseTableBody">
                    <cfif allExpenses.recordCount GT 0>
                        <cfloop query="allExpenses">
                            <tr data-expense-id="<cfoutput>#allExpenses.id#</cfoutput>" 
                                data-category="<cfoutput>#allExpenses.category_name#</cfoutput>"
                                data-date="<cfoutput>#dateFormat(allExpenses.expense_date, 'yyyy-mm-dd')#</cfoutput>">
                                <td><cfoutput>#dateFormat(allExpenses.expense_date, "mmm dd, yyyy")#</cfoutput></td>
                                <td>
                                    <cfoutput>
                                        <span class="category-badge" style="background: #allExpenses.category_color#;">
                                            #allExpenses.category_name#
                                        </span>
                                    </cfoutput>
                                </td>
                                <td><cfoutput>#allExpenses.description#</cfoutput></td>
                                <td><cfoutput><strong>৳#numberFormat(allExpenses.amount, "9,999.99")#</strong></cfoutput></td>
                                <td>
                                    <cfoutput>
                                        <button class="btn-icon" 
                                            data-id="#allExpenses.id#"
                                            data-category-id="#allExpenses.category_id ?: ''#"
                                            data-category-name="#encodeForHTMLAttribute(allExpenses.category_name)#"
                                            data-amount="#allExpenses.amount#"
                                            data-expense-date="#dateFormat(allExpenses.expense_date, 'yyyy-mm-dd')#"
                                            data-description="#encodeForHTMLAttribute(allExpenses.description ?: '')#"
                                            onclick="editExpenseFromData(this)" 
                                            title="Edit">
                                            <span class="icon icon-edit"></span>
                                        </button>
                                        <button class="btn-icon btn-danger" onclick="deleteExpense(#allExpenses.id#)" title="Delete">
                                            <span class="icon icon-trash"></span>
                                        </button>
                                    </cfoutput>
                                </td>
                            </tr>
                        </cfloop>
                    <cfelse>
                        <tr>
                            <td colspan="5" class="empty-state">No expenses found. Click "Add Expense" to get started!</td>
                        </tr>
                    </cfif>
                </tbody>
            </table>
        </div>
    </div>
</section>

<!-- Add/Edit Expense Modal -->
<div id="expenseModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="expenseModalTitle">Add Expense</h3>
            <span class="close" onclick="closeExpenseModal()">&times;</span>
        </div>
        <form id="expenseForm" onsubmit="saveExpense(event)">
            <input type="hidden" id="expenseId" name="expenseId">
            
            <div class="form-group">
                <label for="categoryType">Category *</label>
                <div style="display: flex; gap: 10px; margin-bottom: 10px;">
                    <label style="display: flex; align-items: center; gap: 5px; cursor: pointer;">
                        <input type="radio" name="categoryType" value="existing" checked onchange="toggleCategoryInput()">
                        <span>Select Existing</span>
                    </label>
                    <label style="display: flex; align-items: center; gap: 5px; cursor: pointer;">
                        <input type="radio" name="categoryType" value="custom" onchange="toggleCategoryInput()">
                        <span>Type Custom</span>
                    </label>
                </div>
                
                <select id="expenseCategory" name="categoryId" class="form-select">
                    <option value="">Select Category</option>
                    <cfloop query="categories">
                        <cfoutput>
                            <option value="#categories.id#" data-name="#categories.name#">#categories.name#</option>
                        </cfoutput>
                    </cfloop>
                </select>
                
                <input type="text" 
                       id="customCategoryName" 
                       name="customCategoryName" 
                       class="form-input" 
                       placeholder="Enter custom category name" 
                       style="display: none;"
                       maxlength="50">
                <small style="color: #666; font-size: 0.85em; display: block; margin-top: 5px;">
                    Tip: Use "Type Custom" for one-time expenses to avoid cluttering your category list
                </small>
            </div>

            <div class="form-group">
                <label for="expenseAmount">Amount *</label>
                <input type="number" id="expenseAmount" name="amount" class="form-input" 
                       step="0.01" min="0.01" placeholder="0.00" required>
            </div>

            <div class="form-group">
                <label for="expenseDate">Date *</label>
                <input type="date" id="expenseDate" name="expenseDate" class="form-input" required>
            </div>

            <div class="form-group">
                <label for="expenseDescription">Description</label>
                <textarea id="expenseDescription" name="description" class="form-textarea" 
                          rows="3" placeholder="Enter expense details..."></textarea>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeExpenseModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Expense</button>
            </div>
        </form>
    </div>
</div>
