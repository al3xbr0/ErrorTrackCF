<cfapplication name="ErrorTrackCF" sessionmanagement="yes" setclientcookies="yes" loginstorage="session" datasource="postgres">

<cfif IsUserLoggedIn()>
    <cflocation url="/" addtoken="false">
</cfif>