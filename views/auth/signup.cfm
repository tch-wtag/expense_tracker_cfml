<cfinclude template="/views/layout/header.cfm">

<section class="auth-section">
    <div class="auth-container">
        <!--- Show error message if any --->
        <cfif structKeyExists(variables, "errorMessage") AND len(trim(errorMessage))>
            <cfoutput>
                <div class="error-message">#errorMessage#</div>
            </cfoutput>
        </cfif>

        <!--- Show success message if any --->
        <cfif structKeyExists(variables, "successMessage") AND len(trim(successMessage))>
            <cfoutput>
                <div class="success-message">#successMessage#</div>
                <script>
                    setTimeout(function(){
                        window.location.href = "/views/auth/login.cfm";
                    }, 3000);
                </script>
            </cfoutput>
        </cfif>

        <h2>Sign Up</h2>

        <form id="signupForm" action="/controllers/signupHandler.cfm" method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" id="password" required>
            <input type="password" name="confirmPassword" placeholder="Confirm Password" id="confirmPassword" required>
            <button type="submit" class="btn">Sign Up</button>
        </form>

        <p>Already have an account? <a href="/views/auth/login.cfm">Login here</a></p>

        <!--- Google Signup Button --->
        <div class="google-auth">
            <p>or</p>
            <a href="/controllers/googleSignup.cfm" class="btn">
                <img src="https://developers.google.com/identity/images/g-logo.png" alt="Google logo">
                Sign up with Google
            </a>
        </div>
    </div>
</section>

<script>
document.getElementById('signupForm').addEventListener('submit', function(e) {
    const pwd = document.getElementById('password').value;
    const confirmPwd = document.getElementById('confirmPassword').value;

    if (pwd !== confirmPwd) {
        e.preventDefault();
        alert("Passwords do not match. Please try again.");
    }
});
</script>

<cfinclude template="/views/layout/footer.cfm">
