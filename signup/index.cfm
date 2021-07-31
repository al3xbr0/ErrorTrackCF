<cfif isDefined("form.username") and isDefined("form.password") and isDefined("form.password_repeat")
and isDefined("form.first_name") and isDefined("form.last_name")>
    <cfset username = lCase(trim(form.username))>
    <cfset password = trim(form.password)>
    <cfset password_repeat = trim(form.password_repeat)>
    <cfset first_name = trim(form.first_name)>
    <cfset last_name = trim(form.last_name)>
    
    <cfif !refind("^[\w-]+$", username)>
        <cfset errMsg = "Указан некорректный логин.">
    <cfelse>
        <cfif !refind("^[\w!@##$%^&*()+=,.<>\/?{}[\]|""';:`~-]+$", password)>
            <cfset errMsg = "Указан некорректный пароль.">
        <cfelse>
            <cfif !refind("^[\w-]+$", first_name) or !refind("^[\w-]+$", last_name)>
                <cfset errMsg = "Имя или фамилия указаны в некорректном формате.">
            <cfelse>
                <cfquery name="userExistence">
                    SELECT username FROM users WHERE username =
                    <cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfif userExistence.RecordCount neq 0>
                    <cfset errMsg = "Пользователь с таким логином уже существует.">
                <cfelse>
                    <cfif compare(password, password_repeat) neq 0>
                        <cfset errMsg = "Указанные пароли должны совпадать.">
                    <cfelse>
                        <cfquery name="newUser">
                            INSERT INTO users (username, password_hash, first_name, last_name) VALUES
                            (<cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">,
                        crypt(<cfqueryparam value="#password#" cfsqltype="cf_sql_varchar">, gen_salt('md5')),
                            <cfqueryparam value="#first_name#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#last_name#" cfsqltype="cf_sql_varchar">) RETURNING id
                        </cfquery>
                        <cflogin>
                            <cfloginuser name="#username#" password="#password#" roles="">
                        </cflogin>
                        <cflock scope="session" type="exclusive" timeout=10>
                            <cfset session.userId = newUser.id>
                        </cflock>
                        <cflocation url="/" addtoken="false">
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
</cfif>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Регистрация — ErrorTrackCF</title>
    <link rel="stylesheet" type="text/css" href="/styles.css">
</head>

<body>
<div id="page_container">
    <h1>ErrorTrackCF</h1>
    <div class="page_description">
        <h2>Регистрация нового пользователя</h2>
        <p><a href="/login">Вернуться ко входу</a></p>
</div>
<form name="signup" id="signup" method="post">
<ul>
<cfoutput>
    <cfif isDefined("errMsg")>
        <li>
        	<p class="error">#errMsg#</p>
        </li>
    </cfif>
        <li>
            <label class="description" for="username">Логин</label>
            <div>
                <input class="element text medium" name="username" type="text" id="username" 
                <cfif isDefined("username")>value="#username#"</cfif>
                	required>
            </div>
            <p class="guidelines"><small>Не зависит от регистра. Должен состоять из латинских букв,
                цифр, нижних подчеркиваний и дефисов.</small></p>
        </li>
        <li>
            <label class="description" for="password">Пароль</label>
            <div>
                <input class="element text medium" name="password" type="password" id="password"
                <cfif isDefined("password")>value="#password#"</cfif>
                required>
            </div>
            <p class="guidelines"><small>Зависит от регистра. Должен состоять из латинских букв, цифр и
                других символов.</small></p>
        </li>
        <li>
            <label class="description" for="password_repeat">Повторите пароль</label>
            <div>
                <input class="element text medium" name="password_repeat" type="password" id="password_repeat"
                <cfif isDefined("password_repeat")>value="#password_repeat#"</cfif>
                required>
            </div>
        </li>
        <li>
            <label class="description" for="first_name">Имя</label>
            <div>
                <input class="element text medium" name="first_name" type="text" id="first_name"
                <cfif isDefined("first_name")>value="#first_name#"</cfif>
                required>
            </div>
        </li>
        <li>
            <label class="description" for="last_name">Фамилия</label>
            <div>
                <input class="element text medium" name="last_name" type="text" id="last_name"
                <cfif isDefined("last_name")>value="#last_name#"</cfif>
                required>
            </div>
        </li>
        <li class="buttons">
            <input class="button_text" name="send" type="submit" value="Зарегистрироваться">
        </li>
    </cfoutput>
</ul>
</form>
</div>
</body>
</html>