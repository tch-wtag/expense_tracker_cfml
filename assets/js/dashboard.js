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
    
    document.getElementById('expenseModal').style.display = 'block';
    currentExpenseId = null;
}

function closeExpenseModal() {
    document.getElementById('expenseModal').style.display = 'none';
    currentExpenseId = null;
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

// Fallback to session-based form submission

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