<cftry>
    <!--- Ensure Google OAuth keys exist --->
    <cfif NOT structKeyExists(application,"GOOGLECLIENTID") OR
          NOT structKeyExists(application,"GOOGLECLIENTSECRET") OR
          NOT structKeyExists(application,"GOOGLEREDIRECTURI")>
        <cfoutput>
            Google OAuth keys are not configured properly.
        </cfoutput>
        <cfabort>
    </cfif>

    <cfset clientId     = application.GOOGLECLIENTID>
    <cfset redirectUri  = application.GOOGLEREDIRECTURI>
    <cfset scope        = "openid email profile">
    <cfset state        = createUUID()>

    <!--- Store state in session to validate callback --->
    <cfset session.googleOAuthState = state>

    <!--- Build Google OAuth URL --->
    <cfset oauthUrl = "https://accounts.google.com/o/oauth2/v2/auth" &
        "?response_type=code" &
        "&client_id=" & clientId &
        "&redirect_uri=" & URLEncodedFormat(redirectUri) &
        "&scope=" & URLEncodedFormat(scope) &
        "&state=" & state &
        "&access_type=online" &
        "&prompt=select_account">

    <!--- Redirect user to Google --->
    <cflocation url="#oauthUrl#" addtoken="false">

<cfcatch>
    <cfoutput>
        Google Login Error: #cfcatch.message#
    </cfoutput>
</cfcatch>
</cftry>
