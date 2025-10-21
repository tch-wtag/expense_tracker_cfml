<cfset sessionInvalidate()>
<cfheader name="Cache-Control" value="no-store, no-cache, must-revalidate">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Expires" value="0">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logout - Expense Tracker</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <header>
        <div class="navbar">
            <div class="logo">💸 Expense Tracker</div>
            <nav>
                <a href="/index.cfm">Home</a>
                <a href="/views/auth/login.cfm">Login</a>
                <a href="/views/auth/signup.cfm">Register</a>
            </nav>
        </div>
    </header>

    <section class="hero">
        <h1>✅ Logged Out Successfully</h1>
        <p>You have been logged out. Redirecting to login page...</p>
        <p><a href="/views/auth/login.cfm" class="btn">Go to Login Now</a></p>
    </section>

    <script>
        setTimeout(function(){
            window.location.href = "/views/auth/login.cfm";
        }, 3000);
    </script>
</body>
</html>
