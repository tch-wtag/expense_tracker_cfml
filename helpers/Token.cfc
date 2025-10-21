<cfcomponent output="false" hint="JWT helper for token generation and verification">

    <!--- Generate JWT token --->
    <cffunction name="generateToken" access="public" returnType="string" output="false">
        <cfargument name="userId" type="numeric" required="true">
        <cfargument name="username" type="string" required="true">
        <cfargument name="role" type="string" required="false" default="user">

        <cfscript>
            // Header
            header = serializeJSON({alg="HS256", typ="JWT"});

            // Payload with epoch times
            iat = dateDiff("s", createDate(1970,1,1), now());
            exp = iat + 7200; // 2 hours expiry

            payload = serializeJSON({
                sub = arguments.userId,
                username = arguments.username,
                role = arguments.role,
                iat = iat,
                exp = exp
            });

            // Base64 encode
            base64Header = encodeBase64(header);
            base64Payload = encodeBase64(payload);

            // Signature
            secret = "supersecretkey";
            signature = hmac(base64Header & "." & base64Payload, secret, "HmacSHA256");

            return base64Header & "." & base64Payload & "." & signature;
        </cfscript>
    </cffunction>

    <!--- Verify JWT token --->
    <cffunction name="verifyToken" access="public" returnType="struct" output="false">
        <cfargument name="token" type="string" required="true">

        <cfscript>
            secret = "supersecretkey";
            parts = listToArray(arguments.token, ".");

            if (arrayLen(parts) neq 3) throw(type="InvalidToken", message="Malformed token");

            signature = hmac(parts[1] & "." & parts[2], secret, "HmacSHA256");
            if (signature neq parts[3]) throw(type="InvalidToken", message="Invalid signature");

            return deserializeJSON(decodeBase64(parts[2]));
        </cfscript>
    </cffunction>

    <!--- Base64 encode helper --->
    <cffunction name="encodeBase64" access="private" returnType="string" output="false">
        <cfargument name="str" type="string" required="true">
        <cfscript>
            var b = charsetEncode(arguments.str, "utf-8");
            return binaryEncode(b, "base64");
        </cfscript>
    </cffunction>

    <!--- Base64 decode helper --->
    <cffunction name="decodeBase64" access="private" returnType="string" output="false">
        <cfargument name="str" type="string" required="true">
        <cfscript>
            var b = binaryDecode(arguments.str, "base64");
            return charsetDecode(b, "utf-8");
        </cfscript>
    </cffunction>

</cfcomponent>
