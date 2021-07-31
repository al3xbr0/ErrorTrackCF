<cfapplication name="ErrorTrackCF" sessionmanagement="yes" setclientcookies="yes" loginstorage="session">

<cfif isUserLoggedIn()>
    <cflocation url="/" addtoken="false">
</cfif>