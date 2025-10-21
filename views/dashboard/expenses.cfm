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
                                        <button class="btn-icon" onclick='editExpense(#serializeJSON({
                                            id=allExpenses.id,
                                            categoryId=allExpenses.category_id,
                                            categoryName=allExpenses.category_name,
                                            amount=allExpenses.amount,
                                            expenseDate=dateFormat(allExpenses.expense_date, "yyyy-mm-dd"),
                                            description=allExpenses.description
                                        })#)' title="Edit">
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
                <label for="expenseCategory">Category *</label>
                <select id="expenseCategory" name="categoryId" class="form-select" required>
                    <option value="">Select Category</option>
                    <cfloop query="categories">
                        <cfoutput>
                            <option value="#categories.id#" data-name="#categories.name#">#categories.name#</option>
                        </cfoutput>
                    </cfloop>
                </select>
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


