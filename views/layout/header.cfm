<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Expense Tracker</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>

<header>
    <div class="navbar">
        <div class="logo">💸 Expense Tracker</div>
        <nav>
            <cfif structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
                <!--- Logged in user navigation --->
                <a href="/views/dashboard/index.cfm">Dashboard</a>
                <cfoutput>
                    <span style="color: white; margin: 0 12px; font-weight: 500;">Welcome, #session.username#!</span>
                </cfoutput>
                <a href="/views/auth/logout.cfm">Logout</a>
            <cfelse>
                <!--- Guest navigation --->
                <a href="/index.cfm">Home</a>
                <a href="/index.cfm##about">About</a>
                <a href="/views/auth/login.cfm">Login</a>
                <a href="/views/auth/signup.cfm">Register</a>
            </cfif>
        </nav>
    </div>
</header>
