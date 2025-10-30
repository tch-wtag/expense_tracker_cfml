<cftry>
    <!--- Validate Google OAuth Configuration --->
    <cfif NOT structKeyExists(application, "GOOGLECLIENTID") OR
          NOT structKeyExists(application, "GOOGLECLIENTSECRET") OR
          NOT structKeyExists(application, "GOOGLEREDIRECTURI") OR
          NOT structKeyExists(application, "SECRET_KEY")>
        <cfoutput>Google OAuth keys or secret key are not configured properly.</cfoutput>
        <cfabort>
    </cfif>

    <!--- Handle Authorization Code and State --->
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

    <!--- Encrypt tokens using AES --->
    <cfset accessTokenEncrypted  = encrypt(tokenData.access_token, application.env.SECRET_KEY, "AES/CBC/PKCS5Padding", "base64")>
    <cfset refreshTokenEncrypted = structKeyExists(tokenData, "refresh_token") ? encrypt(tokenData.refresh_token, application.env.SECRET_KEY, "AES/CBC/PKCS5Padding", "base64") : "">

    <!--- Fetch User Info from Google API --->
    <cfhttp url="https://www.googleapis.com/oauth2/v2/userinfo" method="get" result="userResponse">
        <cfhttpparam type="header" name="Authorization" value="Bearer #tokenData.access_token#">
    </cfhttp>

    <cfset userData = deserializeJSON(userResponse.fileContent)>

    <!--- Insert or Update User in Database --->
    <cfquery name="checkUser" datasource="mydsn">
        SELECT id, username, email
        FROM users
        WHERE google_id = <cfqueryparam value="#userData.id#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif checkUser.recordCount EQ 0>
        <!--- Create new user --->
        <cfquery name="createUser" datasource="mydsn" result="insertResult">
            INSERT INTO users (username, email, password, google_id, access_token, refresh_token)
            VALUES (
                <cfqueryparam value="#userData.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#userData.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="GOOGLE_USER" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#userData.id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#accessTokenEncrypted#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#refreshTokenEncrypted#" cfsqltype="cf_sql_longvarchar">
            )
        </cfquery>
        <cfset userId = insertResult.generatedKey>
    <cfelse>
        <!--- Update tokens for existing user --->
        <cfquery name="updateUser" datasource="mydsn">
            UPDATE users
            SET 
                access_token = <cfqueryparam value="#accessTokenEncrypted#" cfsqltype="cf_sql_longvarchar">,
                refresh_token = <cfqueryparam value="#refreshTokenEncrypted#" cfsqltype="cf_sql_longvarchar">,
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