// Dashboard JavaScript - Expense Tracker

// Global variables
let currentExpenseId = null;
let currentCategoryId = null;

// Section Navigation
function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.dashboard-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active class from all menu items
    document.querySelectorAll('.menu-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // Show selected section
    document.getElementById(sectionId).classList.add('active');
    
    // Add active class to clicked menu item
    event.target.closest('.menu-item').classList.add('active');
    
    // Update URL hash
    window.location.hash = sectionId;
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Check URL hash and show corresponding section
    const hash = window.location.hash.substring(1);
    if (hash) {
        const section = document.getElementById(hash);
        if (section) {
            showSection(hash);
        }
    }
    
    // Set today's date as default for expense date
    const today = new Date().toISOString().split('T')[0];
    const expenseDateInput = document.getElementById('expenseDate');
    if (expenseDateInput) {
        expenseDateInput.value = today;
    }
    
    // Auto-hide session alerts after 5 seconds
    const sessionAlert = document.getElementById('sessionAlert');
    if (sessionAlert) {
        setTimeout(() => {
            sessionAlert.style.transition = 'opacity 0.5s ease';
            sessionAlert.style.opacity = '0';
            setTimeout(() => {
                sessionAlert.remove();
            }, 500);
        }, 5000);
    }
});

// ============= EXPENSE FUNCTIONS =============

function openExpenseModal() {
    document.getElementById('expenseModalTitle').textContent = 'Add Expense';
    document.getElementById('expenseForm').reset();
    document.getElementById('expenseId').value = '';
    
    // Set today's date
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('expenseDate').value = today;
    
    document.getElementById('expenseModal').style.display = 'block';
    currentExpenseId = null;
}

function closeExpenseModal() {
    document.getElementById('expenseModal').style.display = 'none';
    currentExpenseId = null;
}

function editExpense(expense) {
    document.getElementById('expenseModalTitle').textContent = 'Edit Expense';
    document.getElementById('expenseId').value = expense.id;
    document.getElementById('expenseCategory').value = expense.categoryId || '';
    document.getElementById('expenseAmount').value = expense.amount;
    document.getElementById('expenseDate').value = expense.expenseDate;
    document.getElementById('expenseDescription').value = expense.description || '';
    
    document.getElementById('expenseModal').style.display = 'block';
    currentExpenseId = expense.id;
}

function saveExpense(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    const categorySelect = document.getElementById('expenseCategory');
    const selectedOption = categorySelect.options[categorySelect.selectedIndex];
    const categoryName = selectedOption.getAttribute('data-name');
    
    const expenseData = {
        categoryId: formData.get('categoryId') || 0,
        categoryName: categoryName,
        amount: parseFloat(formData.get('amount')),
        expenseDate: formData.get('expenseDate'),
        description: formData.get('description') || ''
    };
    
    if (currentExpenseId) {
        // Update existing expense
        expenseData.id = currentExpenseId;
        updateExpenseAPI(expenseData);
    } else {
        // Create new expense
        createExpenseAPI(expenseData);
    }
}

function createExpenseAPI(data) {
    // Get JWT token from sessionStorage or generate from session
    const token = sessionStorage.getItem('jwt_token');
    
    if (!token) {
        // If no token, try using session-based approach with direct form POST
        createExpenseViaForm(data);
        return;
    }
    
    fetch('/rest/expenses', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.status === 'success') {
            showNotification('Expense added successfully!', 'success');
            closeExpenseModal();
            setTimeout(() => {
                window.location.reload();
            }, 500);
        } else {
            showNotification('Error: ' + result.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to add expense. Please try again.', 'error');
    });
}

// Fallback to session-based form submission
function createExpenseViaForm(data) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/expenseHandler.cfm';
    
    for (const key in data) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = data[key];
        form.appendChild(input);
    }
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'create';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

function updateExpenseAPI(data) {
    const token = sessionStorage.getItem('jwt_token');
    
    if (!token) {
        // If no token, use session-based approach with direct form POST
        updateExpenseViaForm(data);
        return;
    }
    
    fetch('/rest/expenses/' + data.id, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.status === 'success') {
            showNotification('Expense updated successfully!', 'success');
            closeExpenseModal();
            setTimeout(() => {
                window.location.reload();
            }, 500);
        } else {
            showNotification('Error: ' + result.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to update expense. Please try again.', 'error');
    });
}

// Fallback to session-based form submission
function updateExpenseViaForm(data) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/expenseHandler.cfm';
    
    for (const key in data) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = data[key];
        form.appendChild(input);
    }
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'update';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

function deleteExpense(id) {
    if (confirm('Are you sure you want to delete this expense?')) {
        const token = sessionStorage.getItem('jwt_token');
        
        if (!token) {
            // If no token, use session-based approach with direct form POST
            deleteExpenseViaForm(id);
            return;
        }
        
        fetch('/rest/expenses/' + id, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
            }
        })
        .then(response => response.json())
        .then(result => {
            if (result.status === 'success') {
                showNotification('Expense deleted successfully!', 'success');
                setTimeout(() => {
                    window.location.reload();
                }, 500);
            } else {
                showNotification('Error: ' + result.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showNotification('Failed to delete expense. Please try again.', 'error');
        });
    }
}

// Fallback to session-based form submission
function deleteExpenseViaForm(id) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/expenseHandler.cfm';
    
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'id';
    idInput.value = id;
    form.appendChild(idInput);
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'delete';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

// ============= CATEGORY FUNCTIONS =============

function openCategoryModal() {
    document.getElementById('categoryModalTitle').textContent = 'Add Category';
    document.getElementById('categoryForm').reset();
    document.getElementById('categoryId').value = '';
    document.getElementById('categoryAction').value = 'create';
    document.getElementById('categoryColor').value = '#FF8C55';
    
    document.getElementById('categoryModal').style.display = 'block';
    currentCategoryId = null;
}

function closeCategoryModal() {
    document.getElementById('categoryModal').style.display = 'none';
    currentCategoryId = null;
}

function editCategory(category) {
    document.getElementById('categoryModalTitle').textContent = 'Edit Category';
    document.getElementById('categoryId').value = category.id;
    document.getElementById('categoryAction').value = 'update';
    document.getElementById('categoryName').value = category.name;
    document.getElementById('categoryDescription').value = category.description || '';
    document.getElementById('categoryColor').value = category.color;
    
    document.getElementById('categoryModal').style.display = 'block';
    currentCategoryId = category.id;
}

// Read dataset from Edit button and open modal
function editCategoryFromElement(el) {
    const category = {
        id: parseInt(el.dataset.id, 10),
        name: el.dataset.name || '',
        description: el.dataset.description || '',
        color: el.dataset.color || '#FF8C55'
    };
    editCategory(category);
}

// Simplified category save - just prepare the form and let it submit naturally
function prepareCategory(event) {
    // No need to prevent default - let the form submit
    // Just ensure the action field is set correctly (already done in open/edit functions)
    
    // Optional: Show a loading indicator
    const submitBtn = event.target.querySelector('button[type="submit"]');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="icon icon-spinner"></span> Saving...';
    }
    
    // Allow form to submit
    return true;
}

// Keep the old function for reference but rename it
function saveCategoryOLD(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    const categoryData = {
        name: formData.get('name'),
        description: formData.get('description') || '',
        color: formData.get('color')
    };
    
    if (currentCategoryId) {
        // Update existing category
        categoryData.id = currentCategoryId;
        updateCategoryAPI(categoryData);
    } else {
        // Create new category
        createCategoryAPI(categoryData);
    }
}

function createCategoryAPI(data) {
    const token = sessionStorage.getItem('jwt_token');
    
    if (!token) {
        // If no token, use session-based approach with direct form POST
        createCategoryViaForm(data);
        return;
    }
    
    fetch('/rest/categories', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.status === 'success') {
            showNotification('Category created successfully!', 'success');
            closeCategoryModal();
            setTimeout(() => {
                window.location.reload();
            }, 500);
        } else {
            showNotification('Error: ' + result.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to create category. Please try again.', 'error');
    });
}

// Fallback to session-based form submission
function createCategoryViaForm(data) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/categoryHandler.cfm';
    
    for (const key in data) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = data[key];
        form.appendChild(input);
    }
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'create';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

function updateCategoryAPI(data) {
    const token = sessionStorage.getItem('jwt_token');
    
    if (!token) {
        // If no token, use session-based approach with direct form POST
        updateCategoryViaForm(data);
        return;
    }
    
    fetch('/rest/categories/' + data.id, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.status === 'success') {
            showNotification('Category updated successfully!', 'success');
            closeCategoryModal();
            setTimeout(() => {
                window.location.reload();
            }, 500);
        } else {
            showNotification('Error: ' + result.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to update category. Please try again.', 'error');
    });
}

// Fallback to session-based form submission
function updateCategoryViaForm(data) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/categoryHandler.cfm';
    
    for (const key in data) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = data[key];
        form.appendChild(input);
    }
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'update';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

function deleteCategory(id, name) {
    if (confirm(`Are you sure you want to delete the category "${name}"? This will remove the category reference from all associated expenses.`)) {
        const token = sessionStorage.getItem('jwt_token');
        
        if (!token) {
            // If no token, use session-based approach with direct form POST
            deleteCategoryViaForm(id);
            return;
        }
        
        fetch('/rest/categories/' + id, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
            }
        })
        .then(response => response.json())
        .then(result => {
            if (result.status === 'success') {
                showNotification('Category deleted successfully!', 'success');
                setTimeout(() => {
                    window.location.reload();
                }, 500);
            } else {
                showNotification('Error: ' + result.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showNotification('Failed to delete category. Please try again.', 'error');
        });
    }
}

// Fallback to session-based form submission
function deleteCategoryViaForm(id) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/controllers/categoryHandler.cfm';
    
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'id';
    idInput.value = id;
    form.appendChild(idInput);
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'delete';
    form.appendChild(actionInput);
    
    document.body.appendChild(form);
    form.submit();
}

// ============= FILTER FUNCTIONS =============

function applyFilters() {
    const searchTerm = document.getElementById('searchExpense').value.toLowerCase();
    const categoryFilter = document.getElementById('filterCategory').value;
    const startDate = document.getElementById('filterStartDate').value;
    const endDate = document.getElementById('filterEndDate').value;
    
    const rows = document.querySelectorAll('#expenseTableBody tr[data-expense-id]');
    
    rows.forEach(row => {
        let show = true;
        
        // Search filter
        if (searchTerm) {
            const text = row.textContent.toLowerCase();
            if (!text.includes(searchTerm)) {
                show = false;
            }
        }
        
        // Category filter
        if (categoryFilter && show) {
            const rowCategory = row.getAttribute('data-category');
            if (rowCategory !== categoryFilter) {
                show = false;
            }
        }
        
        // Date range filter
        if ((startDate || endDate) && show) {
            const rowDate = row.getAttribute('data-date');
            if (startDate && rowDate < startDate) {
                show = false;
            }
            if (endDate && rowDate > endDate) {
                show = false;
            }
        }
        
        row.style.display = show ? '' : 'none';
    });
}

function clearFilters() {
    document.getElementById('searchExpense').value = '';
    document.getElementById('filterCategory').value = '';
    document.getElementById('filterStartDate').value = '';
    document.getElementById('filterEndDate').value = '';
    
    // Show all rows
    document.querySelectorAll('#expenseTableBody tr').forEach(row => {
        row.style.display = '';
    });
}

// ============= REPORT FUNCTIONS =============

function loadReport(period) {
    // Remove active class from all period buttons
    document.querySelectorAll('.period-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Add active class to clicked button
    event.target.classList.add('active');
    
    // Show/hide custom range selector
    const customRangeSelector = document.getElementById('customRangeSelector');
    if (period === 'custom') {
        customRangeSelector.style.display = 'block';
        return;
    }
    customRangeSelector.style.display = 'none';

    const token = sessionStorage.getItem('jwt_token');
    if (!token) {
        showNotification('Please refresh the page or login again to view reports.', 'error');
        return;
    }

    const { start, end, label } = computeRange(period);
    fetchAndRenderReport(start, end, label);
}

// Compute date range for period
function computeRange(period) {
    const today = new Date();
    const end = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()));
    let start;
    let label = '';
    if (period === 'daily') {
        start = new Date(end);
        start.setUTCDate(end.getUTCDate() - 6); // last 7 days
        label = 'Last 7 Days';
    } else if (period === 'weekly') {
        // Last 12 weeks (inclusive)
        start = new Date(end);
        start.setUTCDate(end.getUTCDate() - (7 * 11));
        label = 'Last 12 Weeks';
    } else if (period === 'monthly') {
        // Last 12 months starting from current month
        start = new Date(Date.UTC(end.getUTCFullYear(), end.getUTCMonth() - 11, 1));
        label = 'Last 12 Months';
    } else {
        start = new Date(end);
        label = '';
    }
    return { start: toYMD(start), end: toYMD(end), label };
}

function toYMD(date) {
    const y = date.getUTCFullYear();
    const m = String(date.getUTCMonth() + 1).padStart(2, '0');
    const d = String(date.getUTCDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

async function fetchAndRenderReport(startDate, endDate, periodLabel) {
    try {
        showNotification('Loading report...', 'info');
        const token = sessionStorage.getItem('jwt_token');
        const headers = { 'Authorization': 'Bearer ' + token };

        // Fetch expenses for range and statistics
        const [rangeRes, statsRes] = await Promise.all([
            fetch(`/api/expenses/range?startDate=${startDate}&endDate=${endDate}`, { headers }),
            fetch(`/api/expenses/statistics?startDate=${startDate}&endDate=${endDate}`, { headers })
        ]);

        const rangeJson = await rangeRes.json();
        const statsJson = await statsRes.json();

        if (rangeJson.status !== 'success' || statsJson.status !== 'success') {
            showNotification('Failed to load report data', 'error');
            return;
        }

        const expenses = rangeJson.expenses || [];
        const stats = statsJson.statistics || statsJson; // depending on API shape

        // Build aggregates for chart and categories
        const aggregates = buildAggregates(expenses, startDate, endDate);

        // Render
        renderReportContent({ periodLabel, stats, aggregates });
    } catch (e) {
        console.error(e);
        showNotification('Error loading report', 'error');
    }
}

function buildAggregates(expenses, startDate, endDate) {
    // Group by date
    const byDate = new Map();
    expenses.forEach((e) => {
        const d = (e.expense_date || e.expenseDate || '').substring(0, 10);
        const amt = Number(e.amount) || 0;
        byDate.set(d, (byDate.get(d) || 0) + amt);
    });

    // Group by category
    const byCategory = new Map();
    expenses.forEach((e) => {
        const key = e.category_name || e.categoryName || 'Uncategorized';
        const color = e.category_color || '#FF8C55';
        const prev = byCategory.get(key) || { total: 0, color, count: 0 };
        prev.total += Number(e.amount) || 0;
        prev.count += 1;
        byCategory.set(key, prev);
    });

    return { byDate, byCategory };
}

function renderReportContent({ periodLabel, stats, aggregates }) {
    const container = document.getElementById('reportContent');
    if (!container) return;

    const totalAmount = Number(stats.totalAmount || stats.total_amount || 0);
    const totalCount = Number(stats.totalCount || stats.total_count || 0);
    const avgAmount = Number(stats.avgAmount || stats.avg_amount || 0);

    // Build category chart HTML
    const categoryItems = Array.from(aggregates.byCategory.entries())
        .sort((a, b) => b[1].total - a[1].total)
        .map(([name, info]) => {
            const percentage = totalAmount > 0 ? (info.total / totalAmount) * 100 : 0;
            return `
                <div class="category-bar-item">
                    <div class="category-bar-header">
                        <span class="category-name">
                            <span class="color-dot" style="background: ${info.color};"></span>
                            ${escapeHtml(name)}
                            <span class="category-count">(${info.count} expenses)</span>
                        </span>
                        <span class="category-amount">৳${formatAmount(info.total)} (${percentage.toFixed(1)}%)</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: ${percentage}%; background: ${info.color};"></div>
                    </div>
                </div>`;
        }).join('');

    // Build bar chart for daily totals across range
    const dates = enumerateDates(startDateFromLabel(periodLabel), endDateFromLabel());
    const bars = dates.map((d) => ({ date: d, value: aggregates.byDate.get(d) || 0 }));
    const maxVal = bars.reduce((m, b) => Math.max(m, b.value), 0);
    const barHtml = bars.map(b => {
        const h = maxVal > 0 ? (b.value / maxVal) * 100 : 0;
        return `
            <div class="bar-item">
                <div class="bar-wrapper">
                    <div class="bar" style="height: ${h}%;" title="৳${formatAmount(b.value)}"></div>
                </div>
                <div class="bar-label">${formatBarLabel(b.date, periodLabel)}</div>
                <div class="bar-value">৳${formatAmount(b.value)}</div>
            </div>`;
    }).join('');

    container.innerHTML = `
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="background: #FF6B6B;">
                    <span class="icon icon-calendar-week"></span>
                </div>
                <div class="stat-details">
                    <h3>${escapeHtml(periodLabel)}</h3>
                    <p class="stat-value">৳${formatAmount(totalAmount)}</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #4ECDC4;">
                    <span class="icon icon-calendar-alt"></span>
                </div>
                <div class="stat-details">
                    <h3>Total Expenses</h3>
                    <p class="stat-value">${totalCount}</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #45B7D1;">
                    <span class="icon icon-chart"></span>
                </div>
                <div class="stat-details">
                    <h3>Average Expense</h3>
                    <p class="stat-value">৳${formatAmount(avgAmount)}</p>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>Spending Over Time</h3>
            <div class="chart-container">
                <div class="bar-chart">${barHtml}</div>
            </div>
        </div>

        <div class="card">
            <h3>Category Breakdown</h3>
            <div class="category-chart">${categoryItems || '<p class="empty-state">No expenses in this period</p>'}</div>
        </div>
    `;
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function formatAmount(n) {
    return (Number(n) || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// Helpers for bar chart date enumeration
function enumerateDates(start, end) {
    const out = [];
    const s = new Date(start + 'T00:00:00Z');
    const e = new Date(end + 'T00:00:00Z');
    for (let d = new Date(s); d <= e; d.setUTCDate(d.getUTCDate() + 1)) {
        out.push(toYMD(d));
    }
    return out;
}

function startDateFromLabel(label) {
    // Not used; kept for clarity
    return '';
}

function endDateFromLabel() {
    const today = new Date();
    return toYMD(new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate())));
}

function formatBarLabel(ymd, periodLabel) {
    const [y, m, d] = ymd.split('-').map(Number);
    const date = new Date(Date.UTC(y, m - 1, d));
    if (periodLabel.indexOf('Weeks') !== -1) {
        // Show week number label
        const onejan = new Date(Date.UTC(date.getUTCFullYear(),0,1));
        const week = Math.ceil((((date - onejan) / 86400000) + onejan.getUTCDay()+1)/7);
        return 'W' + week;
    }
    if (periodLabel.indexOf('Months') !== -1) {
        return date.toLocaleString(undefined, { month: 'short' });
    }
    return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function generateCustomReport() {
    const startDate = document.getElementById('reportStartDate').value;
    const endDate = document.getElementById('reportEndDate').value;
    
    if (!startDate || !endDate) {
        showNotification('Please select both start and end dates', 'error');
        return;
    }
    
    if (startDate > endDate) {
        showNotification('Start date must be before end date', 'error');
        return;
    }
    
    showNotification('Generating custom report...', 'info');
    
    // In production, this would make an API call with date range
    // and update the report content dynamically
    setTimeout(() => {
        showNotification('Custom report functionality coming soon!', 'info');
    }, 500);
}

// ============= UTILITY FUNCTIONS =============

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Show notification
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Close modals when clicking outside
window.onclick = function(event) {
    const expenseModal = document.getElementById('expenseModal');
    const categoryModal = document.getElementById('categoryModal');
    
    if (event.target === expenseModal) {
        closeExpenseModal();
    }
    if (event.target === categoryModal) {
        closeCategoryModal();
    }
}

// Handle escape key to close modals
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeExpenseModal();
        closeCategoryModal();
    }
});

// Color picker preview
const colorInput = document.getElementById('categoryColor');
if (colorInput) {
    colorInput.addEventListener('input', function() {
        const preview = document.getElementById('colorPreview');
        if (preview) {
            preview.style.background = this.value;
        }
    });
}

// Search in real-time
const searchInput = document.getElementById('searchExpense');
if (searchInput) {
    searchInput.addEventListener('input', applyFilters);
}


