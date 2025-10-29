<cfinclude template="/views/layout/header.cfm">

<section class="auth-section">
    <div class="auth-container">
        <h2>Login</h2>
        <form action="/controllers/loginHandler.cfm" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="btn">Login</button>
        </form>
        <p>Don't have an account? <a href="/views/auth/signup.cfm">Sign up here</a></p>

        <!-- Google Login Button -->
        <div class="google-auth">
            <p>or</p>
            <a href="/controllers/googleLogin.cfm" class="btn">
                <img src="https://developers.google.com/identity/images/g-logo.png" alt="Google logo">
                Login with Google
            </a>
        </div>
    </div>
</section>

<cfinclude template="/views/layout/footer.cfm">
