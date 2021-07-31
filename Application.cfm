<cfapplication sessionmanagement="yes" setclientcookies="yes" loginstorage="session" name="ErrorTrackCF" sessiontimeout="#CreateTimeSpan(1, 0, 0, 0)#" datasource="postgres">

<cfif isDefined("url.logout")>
    <cflogout>
</cfif>
<cflogin idletimeout="3600" allowconcurrent="false">
    <cfif NOT IsDefined("cflogin")>
        <cflocation url="/login" addtoken="false">
    <cfelse>
        <cfset username = lCase(trim(cflogin.name))>
        <cfset password = trim(cflogin.password)>
        <cfif username eq "" or password eq "">
            <cflocation url="/login?fail" addtoken="false">
        <cfelse>
            <cfquery name="authResult">
                SELECT id FROM users WHERE
                username = <cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">
                AND
                crypt(<cfqueryparam value="#password#" cfsqltype="cf_sql_varchar">,
                password_hash) = password_hash
            </cfquery>
            <cfif authResult.RecordCount eq 1>
                <cfloginuser name="#username#" password="#password#" roles="user">
                <cflock scope="session" type="exclusive" timeout=10>
                    <cfset session.userId = authResult.id>
                </cflock>
            <cfelse>
                <cflocation url="/login?fail" addtoken="false">
            </cfif>
        </cfif>
    </cfif>
</cflogin>