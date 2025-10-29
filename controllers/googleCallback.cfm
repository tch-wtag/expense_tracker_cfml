<cftry>
    <!--- Validate Google OAuth Configuration --->
    <cfif NOT structKeyExists(application, "GOOGLECLIENTID") OR
          NOT structKeyExists(application, "GOOGLECLIENTSECRET") OR
          NOT structKeyExists(application, "GOOGLEREDIRECTURI")>
        <cfoutput>Google OAuth keys are not configured properly.</cfoutput>
        <cfabort>
    </cfif>

    <!--- Handle Authorization Code and State  --->
    <cfparam name="url.code" default="">
    <cfparam name="url.state" default="">

    <cfif NOT structKeyExists(session, "googleOAuthState") OR url.state NEQ session.googleOAuthState>
        <cfoutput>Invalid OAuth state.</cfoutput>
        <cfabort>
    </cfif>

    <!--- Exchange Authorization Code for Tokens --->
    <cfhttp url="https://oauth2.googleapis.com/token" method="post" result="tokenResponse">
        <cfhttpparam type="formField" name="code" value="#url.code#">
        <cfhttpparam type="formField" name="client_id" value="#application.GOOGLECLIENTID#">
        <cfhttpparam type="formField" name="client_secret" value="#application.GOOGLECLIENTSECRET#">
        <cfhttpparam type="formField" name="redirect_uri" value="#application.GOOGLEREDIRECTURI#">
        <cfhttpparam type="formField" name="grant_type" value="authorization_code">
    </cfhttp>

    <cfset tokenData = deserializeJSON(tokenResponse.fileContent)>

    <cfif NOT structKeyExists(tokenData, "access_token")>
        <cfoutput>
            Google Callback Error: 
            #structKeyExists(tokenData, "error") ? tokenData.error & " - " & tokenData.error_description : "No access token returned"#
        </cfoutput>
        <cfabort>
    </cfif>

    <cfset accessToken  = tokenData.access_token>
    <cfset refreshToken = structKeyExists(tokenData, "refresh_token") ? tokenData.refresh_token : "">

    <!--- Fetch User Info from Google API --->
    <cfhttp url="https://www.googleapis.com/oauth2/v2/userinfo" method="get" result="userResponse">
        <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
    </cfhttp>

    <cfset userData = deserializeJSON(userResponse.fileContent)>

    <!--- Insert or Update User in Database --->
    <cfquery name="checkUser" datasource="mydsn">
        SELECT id, username, email
        FROM users
        WHERE google_id = <cfqueryparam value="#userData.id#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif checkUser.recordCount EQ 0>
        <!--- Create new user and capture generated ID --->
        <cfquery name="createUser" datasource="mydsn" result="insertResult">
            INSERT INTO users (username, email, password, google_id, access_token, refresh_token)
            VALUES (
                <cfqueryparam value="#userData.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#userData.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="GOOGLE_USER" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#userData.id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#accessToken#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#refreshToken#" cfsqltype="cf_sql_longvarchar">
            )
        </cfquery>

        <!--- Capture the new user's ID properly --->
        <cfset userId = insertResult.generatedKey>

    <cfelse>
        <!--- Update tokens for existing user --->
        <cfquery name="updateUser" datasource="mydsn">
            UPDATE users
            SET 
                access_token = <cfqueryparam value="#accessToken#" cfsqltype="cf_sql_longvarchar">,
                refresh_token = <cfqueryparam value="#refreshToken#" cfsqltype="cf_sql_longvarchar">,
                updated_at = NOW()
            WHERE google_id = <cfqueryparam value="#userData.id#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfset userId = checkUser.id>
    </cfif>

    <!--- Initialize Session and Redirect --->
    <cfset session.isLoggedIn = true>
    <cfset session.userId = userId>
    <cfset session.username = userData.name>
    <cfset session.email = userData.email>

    <cflocation url="/views/dashboard/index.cfm" addtoken="false">

<cfcatch type="any">
    <cfoutput>
        <h2>Google Callback Error</h2>
        <p>#cfcatch.message#</p>
        <p>Please try again or contact support.</p>
    </cfoutput>

    <cflog file="oauth_errors" type="error" text="[#now()#] Google Callback Error: #cfcatch.message# | Detail: #cfcatch.detail#">
</cfcatch>
</cftry>