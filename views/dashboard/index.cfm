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
    
    // --- Fetch Data ---
    allExpenses = expenseRepo.findByUserId(session.userId);
    monthExpenses = expenseRepo.findByDateRange(session.userId, startOfMonth, endOfMonth);
    monthStats = expenseRepo.getStatistics(session.userId, startOfMonth, endOfMonth);
    categorySummary = expenseRepo.getTotalByCategory(session.userId, startOfMonth, endOfMonth);
    categories = categoryRepo.findByUserId(session.userId);

    // --- Convert to arrays ---
    expensesArray = expenseRepo.queryToArray(allExpenses);
    categoriesArray = categoryRepo.queryToArray(categories);

    // --- LAST 7 DAYS CHART DATA ---
    endDate = now();
    startDate = dateAdd("d", -6, endDate);

    try {
        dailyTotalsRaw = expenseRepo.getDailyTotals(session.userId, startDate, endDate);
    } catch(any e) {
        dailyTotalsRaw = "";
    }

    /// --- Normalize Query ---
    dailyTotals = queryNew("expense_date,daily_total", "date,numeric");
    totalsMap = structNew();

    if (isQuery(dailyTotalsRaw) && dailyTotalsRaw.recordCount gt 0) {
        for (i=1; i <= dailyTotalsRaw.recordCount; i++) {
            // Convert to date safely
            d = dateFormat(dailyTotalsRaw.expense_date[i], "yyyy-mm-dd");
            totalsMap[d] = dailyTotalsRaw.daily_total[i];
        }
    }

    for (offset=0; offset <= 6; offset++) {
        dObj = dateAdd("d", offset, startDate);
        key = dateFormat(dObj, "yyyy-mm-dd");
        value = structKeyExists(totalsMap, key) ? totalsMap[key] : 0;

        queryAddRow(dailyTotals, 1);
        querySetCell(dailyTotals, "expense_date", dObj, dailyTotals.recordCount);
        querySetCell(dailyTotals, "daily_total", value, dailyTotals.recordCount);
    }



    // --- Generate Chart ---
    chartService = new controllers.ChartService();
    chartPath = expandPath("/assets/images/daily-spending.png");

    chartService.generateDailySpendingChart(
        dailyTotals = dailyTotals,
        outputPath = chartPath
    );

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

        <!-- Overview Section -->
        <section id="overview" class="dashboard-section active">
            <!-- Welcome Header - Only shows in Overview -->
            <div class="dashboard-welcome">
                <h1>Welcome back, <cfoutput>#session.username#</cfoutput>! 👋</h1>
                <p class="dashboard-subtitle">Here's your expense summary for <cfoutput>#dateFormat(currentDate, "mmmm yyyy")#</cfoutput></p>
            </div>

            <div class="modern-stats-grid">
                <div class="stat-card">
                    <div class="stat-left">
                        <h3 class="stat-title">Total Spending</h3>
                        <p class="stat-subtitle">This Month</p>
                    </div>
                    <cfoutput><p class="stat-value">৳#numberFormat(monthStats.totalAmount, "9,999.99")#</p></cfoutput>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <h3 class="stat-title">Total Expenses</h3>
                        <p class="stat-subtitle">Transactions</p>
                    </div>
                    <cfoutput><p class="stat-value">#monthStats.totalCount#</p></cfoutput>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <h3 class="stat-title">Average Expense</h3>
                        <p class="stat-subtitle">Per Transaction</p>
                    </div>
                    <cfoutput><p class="stat-value">৳#numberFormat(monthStats.avgAmount, "9,999.99")#</p></cfoutput>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <h3 class="stat-title">Active Categories</h3>
                        <p class="stat-subtitle">Categories Created</p>
                    </div>
                    <cfoutput><p class="stat-value">#categories.recordCount#</p></cfoutput>
                </div>
            </div>



        </section>
        
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
