<cfif structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
    <cflocation url="/views/dashboard/index.cfm">
</cfif>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Expense Tracker</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <!-- Header -->
    <cfinclude template="/views/layout/header.cfm">

    <!-- Hero Section -->
    <section class="hero">
        <h1>Welcome to Expense Tracker</h1>
        <p>Track your daily, weekly, and monthly expenses effortlessly.</p>
        <a href="/views/auth/signup.cfm" class="btn">Get Started</a>
    </section>

    <!-- About Section -->
    <section id="about">
        <h2>About Expense Tracker</h2>
        <p>Manage your finances smartly with an intuitive dashboard that helps you stay on top of your spending.</p>

        <div class="features">
            <div class="feature-card">
                <h3>📅 Weekly Summary</h3>
                <p>See your total spending every week and identify your most active spending categories.</p>
            </div>

            <div class="feature-card">
                <h3>📊 Monthly Insights</h3>
                <p>Track your monthly trends and breakdowns by category.</p>
            </div>

            <div class="feature-card">
                <h3>📈 Yearly Overview</h3>
                <p>Get an annual summary to plan ahead and improve your financial health.</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <cfinclude template="/views/layout/footer.cfm">

</body>
</html>
