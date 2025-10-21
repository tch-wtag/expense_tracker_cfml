<cfif NOT structKeyExists(session, "isLoggedIn") OR session.isLoggedIn EQ false>
    <cflocation url="/views/auth/login.cfm">
</cfif>

<cfscript>
    // Get repositories
    expenseRepo = new repositories.ExpenseRepository();
    categoryRepo = new repositories.CategoryRepository();
    
    // Get current month date range
    currentDate = now();
    startOfMonth = createDate(year(currentDate), month(currentDate), 1);
    endOfMonth = createDate(year(currentDate), month(currentDate), daysInMonth(currentDate));
    
    // Get all expenses
    allExpenses = expenseRepo.findByUserId(session.userId);
    
    // Get all categories
    categories = categoryRepo.findByUserId(session.userId);
    
    // Convert to arrays for easier handling
    expensesArray = expenseRepo.queryToArray(allExpenses);
    categoriesArray = categoryRepo.queryToArray(categories);
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Expense Tracker</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>

<cfinclude template="/views/layout/header.cfm">

<div class="dashboard-container">
    <!-- Sidebar Navigation -->
    <aside class="dashboard-sidebar">
        <div class="sidebar-menu">
            <a href="#overview" class="menu-item active" onclick="showSection('overview')">
                <span class="icon icon-chart"></span> Overview
            </a>
            <a href="#expenses" class="menu-item" onclick="showSection('expenses')">
                <span class="icon icon-receipt"></span> Expenses
            </a>
            <a href="#categories" class="menu-item" onclick="showSection('categories')">
                <span class="icon icon-tags"></span> Categories
            </a>
            <a href="#reports" class="menu-item" onclick="showSection('reports')">
                <span class="icon icon-chart-bar"></span> Reports
            </a>
            <a href="/views/auth/logout.cfm" class="menu-item">
                <span class="icon icon-logout"></span> Logout
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="dashboard-main">
        <div class="dashboard-header">
            <h1>Welcome back, <cfoutput>#session.username#</cfoutput>!</h1>
            <p class="dashboard-subtitle">Here's your expense summary for <cfoutput>#dateFormat(currentDate, "mmmm yyyy")#</cfoutput></p>
        </div>

        <!--- Display success/error messages --->
        <cfif structKeyExists(session, "successMessage")>
            <div class="alert alert-success" id="sessionAlert">
                <cfoutput>#session.successMessage#</cfoutput>
            </div>
            <cfset structDelete(session, "successMessage")>
        </cfif>
        
        <cfif structKeyExists(session, "errorMessage")>
            <div class="alert alert-error" id="sessionAlert">
                <cfoutput>#session.errorMessage#</cfoutput>
            </div>
            <cfset structDelete(session, "errorMessage")>
        </cfif>

        
        <!-- Expenses Section -->
        <cfinclude template="/views/dashboard/expenses.cfm">

        <!-- Categories Section -->
        <cfinclude template="/views/dashboard/categories.cfm">

        <!-- Reports Section -->
        <cfinclude template="/views/dashboard/reports.cfm">
    </main>
</div>

<script src="/assets/js/dashboard.js"></script>

</body>
</html>
