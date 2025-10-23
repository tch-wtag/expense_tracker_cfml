// Global variables
let currentExpenseId = null;
let currentCategoryId = null;

function showSection(sectionId) {
    document.querySelectorAll('.dashboard-section').forEach(section => {
        section.classList.remove('active');
    });
    
    document.querySelectorAll('.menu-item').forEach(item => {
        item.classList.remove('active');
    });
    
    document.getElementById(sectionId).classList.add('active');
    event.target.closest('.menu-item').classList.add('active');
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
    
    document.querySelector('input[name="categoryType"][value="existing"]').checked = true;
    toggleCategoryInput();
    
    document.getElementById('expenseModal').style.display = 'block';
    currentExpenseId = null;
}

function toggleCategoryInput() {
    const categoryType = document.querySelector('input[name="categoryType"]:checked').value;
    const selectElement = document.getElementById('expenseCategory');
    const textInput = document.getElementById('customCategoryName');
    
    if (categoryType === 'existing') {
        selectElement.style.display = 'block';
        selectElement.required = true;
        textInput.style.display = 'none';
        textInput.required = false;
        textInput.value = '';
    } else {
        selectElement.style.display = 'none';
        selectElement.required = false;
        selectElement.value = '';
        textInput.style.display = 'block';
        textInput.required = true;
    }
}

function closeExpenseModal() {
    document.getElementById('expenseModal').style.display = 'none';
    currentExpenseId = null;
}

function editExpense(expense) {
    document.getElementById('expenseModalTitle').textContent = 'Edit Expense';
    document.getElementById('expenseId').value = expense.id;
    document.getElementById('expenseAmount').value = expense.amount;
    document.getElementById('expenseDate').value = expense.expenseDate;
    document.getElementById('expenseDescription').value = expense.description || '';
    
    if (expense.categoryId && expense.categoryId !== '' && expense.categoryId !== 'null') {
        document.querySelector('input[name="categoryType"][value="existing"]').checked = true;
        document.getElementById('expenseCategory').value = expense.categoryId;
    } else {
        document.querySelector('input[name="categoryType"][value="custom"]').checked = true;
        document.getElementById('customCategoryName').value = expense.categoryName || '';
    }
    toggleCategoryInput();
    
    document.getElementById('expenseModal').style.display = 'block';
    currentExpenseId = expense.id;
}


function editExpenseFromData(button) {
    const categoryId = button.getAttribute('data-category-id');
    const expense = {
        id: button.getAttribute('data-id'),
        categoryId: (categoryId && categoryId !== 'null' && categoryId !== '') ? categoryId : '',
        categoryName: button.getAttribute('data-category-name'),
        amount: button.getAttribute('data-amount'),
        expenseDate: button.getAttribute('data-expense-date'),
        description: button.getAttribute('data-description') || ''
    };
    
    console.log('Editing expense:', expense); 
    editExpense(expense);
}

function saveExpense(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    // Determine category type
    const categoryType = document.querySelector('input[name="categoryType"]:checked').value;
    let categoryId, categoryName;
    
    if (categoryType === 'existing') {
        const categorySelect = document.getElementById('expenseCategory');
        const selectedOption = categorySelect.options[categorySelect.selectedIndex];
        
        if (!selectedOption.value || selectedOption.value === '') {
            showNotification('Please select a category', 'error');
            return;
        }
        
        categoryId = selectedOption.value;
        categoryName = selectedOption.getAttribute('data-name') || selectedOption.text;
    } else {
        // Using a custom category name
        categoryId = 0;
        categoryName = document.getElementById('customCategoryName').value.trim();
        
        if (!categoryName) {
            showNotification('Please enter a category name', 'error');
            return;
        }
    }
    
    const expenseId = currentExpenseId || formData.get('expenseId');
    
    const expenseData = {
        categoryId: categoryId,
        categoryName: categoryName,
        amount: parseFloat(formData.get('amount')),
        expenseDate: formData.get('expenseDate'),
        description: formData.get('description') || ''
    };
    
    console.log('Saving expense with data:', expenseData); 
    
    if (expenseId) {
        expenseData.id = expenseId;
        updateExpenseAPI(expenseData);
    }else {
        createExpenseAPI(expenseData);
    }
}

function createExpenseAPI(data) {
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
        input.value = data[key] !== null && data[key] !== undefined ? data[key] : '';
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
        input.value = data[key] !== null && data[key] !== undefined ? data[key] : '';
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

function prepareCategory(event) {
    const submitBtn = event.target.querySelector('button[type="submit"]');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="icon icon-spinner"></span> Saving...';
    }
    
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


// ============= UTILITY FUNCTIONS =============
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