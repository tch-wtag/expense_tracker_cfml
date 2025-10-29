<section id="reports" class="dashboard-section">
    <div class="section-header">
        <h2>Reports & Analytics</h2>
    </div>

    <!-- Custom Date Range Selector -->
    <div class="card">
        <h3 style="margin-bottom: 15px;">Generate Custom Report</h3>
        <div class="filter-group">
            <input type="date" id="reportStartDate" class="form-input" placeholder="Start Date">
            <input type="date" id="reportEndDate" class="form-input" placeholder="End Date">
            <button class="btn btn-primary" onclick="generateCustomReport()">
                <span class="icon icon-chart"></span> Generate Report
            </button>
        </div>
    </div>

    <!-- Report Content -->
    <div id="reportContent">
        <cfscript>
            isCustomRange = structKeyExists(url, "reportStart") AND structKeyExists(url, "reportEnd");
            
            if (isCustomRange) {
                try {
                    customStart = parseDateTime(url.reportStart);
                    customEnd = parseDateTime(url.reportEnd);
                    reportLabel = dateFormat(customStart, "mmm dd, yyyy") & " - " & dateFormat(customEnd, "mmm dd, yyyy");
                    
                    // Get custom range statistics
                    customStats = expenseRepo.getStatistics(session.userId, customStart, customEnd);
                    customCategorySummary = expenseRepo.getTotalByCategory(session.userId, customStart, customEnd);
                    customExpenses = expenseRepo.findByDateRange(session.userId, customStart, customEnd);
                    customDaysDiff = dateDiff("d", customStart, customEnd) + 1;
                } catch (any e) {
                    isCustomRange = false;
                }
            }
            
            if (NOT isCustomRange) {
                // Get last 7 days 
                endDate = createDate(year(now()), month(now()), day(now()));
                startDate = dateAdd("d", -6, endDate);
                
                // Get daily totals
                dailyTotals = expenseRepo.getDailyTotals(session.userId, startDate, endDate);
                
                // Get last 30 days statistics
                last30Days = dateAdd("d", -29, endDate);
                last30Stats = expenseRepo.getStatistics(session.userId, last30Days, endDate);
            }
        </cfscript>

        <cfif isCustomRange>
            <!--- CUSTOM RANGE REPORT --->
            <div style="text-align: center; margin-bottom: 30px;">
                <cfoutput>
                    <h2 style="color: ##333; margin-bottom: 5px;">Custom Report</h2>
                    <p style="color: ##666; font-size: 1.1rem; margin-bottom: 15px;">#reportLabel#</p>
                </cfoutput>
                <button class="btn btn-outline" onclick="window.location.href='/views/dashboard/index.cfm#reports'">
                    <span class="icon icon-close"></span> Clear Custom Range
                </button>
            </div>

            <!-- Custom Range Summary Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: #9B59B6;">
                        <span class="icon icon-money"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Total Spending</h3>
                        <cfoutput><p class="stat-value">৳#numberFormat(customStats.totalAmount, "9,999.99")#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #E74C3C;">
                        <span class="icon icon-receipt"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Total Expenses</h3>
                        <cfoutput><p class="stat-value">#customStats.totalCount#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #3498DB;">
                        <span class="icon icon-chart"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Average Expense</h3>
                        <cfoutput><p class="stat-value">৳#numberFormat(customStats.avgAmount, "9,999.99")#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #27AE60;">
                        <span class="icon icon-calendar-alt"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Period Length</h3>
                        <cfoutput><p class="stat-value">#customDaysDiff# days</p></cfoutput>
                    </div>
                </div>
            </div>

        <cfelse>
            <!--- DEFAULT REPORTS --->
            <!-- Summary Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: #FF6B6B;">
                        <span class="icon icon-calendar-week"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Last 7 Days</h3>
                        <cfset weekTotal = expenseRepo.getTotalSpending(session.userId, startDate, endDate)>
                        <cfoutput><p class="stat-value">৳#numberFormat(weekTotal, "9,999.99")#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #4ECDC4;">
                        <span class="icon icon-calendar-alt"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Last 30 Days</h3>
                        <cfoutput><p class="stat-value">৳#numberFormat(last30Stats.totalAmount, "9,999.99")#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #45B7D1;">
                        <span class="icon icon-chart"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Daily Average (30d)</h3>
                        <cfset dailyAvg = last30Stats.totalAmount / 30>
                        <cfoutput><p class="stat-value">৳#numberFormat(dailyAvg, "9,999.99")#</p></cfoutput>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #FFA07A;">
                        <span class="icon icon-receipt"></span>
                    </div>
                    <div class="stat-details">
                        <h3>Total Expenses (30d)</h3>
                        <cfoutput><p class="stat-value">#last30Stats.totalCount#</p></cfoutput>
                    </div>
                </div>
            </div> 
            
            <!-- Daily Spending Chart -->
            <div class="card">
                <h3>Daily Spending (Last 7 Days)</h3>
                <img src="/assets/images/daily-spending.png" alt="Daily Spending Chart">
            </div>
        </cfif>
    </div>
</section>