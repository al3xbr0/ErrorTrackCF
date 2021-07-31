<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Авторизация — ErrorTrackCF</title>
    <link rel="stylesheet" type="text/css" href="/styles.css">
</head>

<body>
<div id="page_container">
    <h1>ErrorTrackCF</h1>
    <div class="page_description">
        <h2>Авторизация</h2>
        <p>Если нет аккаунта, необходимо <a href="/signup">зарегистрироваться</a>.</p>
</div>
<form name="login" id="login" action="/" method="post">
<ul>
<cfif isDefined("url.fail")>
        <li>
            <p class="error">Неверный логин или пароль.</p>
        </li>
</cfif>
    <li>
        <label class="description" for="username">Логин</label>
        <div>
            <input class="element text medium" name="j_username" type="text" id="username" required>
        </div>
    </li>
    <li>
        <label class="description" for="password">Пароль</label>
        <div>
            <input class="element text medium" name="j_password" type="password" id="password" required>
        </div>
    </li>
    <li class="buttons">
        <input class="button_text" name="send" type="submit" value="Войти">
    </li>
</ul>
</form>
</div>
</body>
</html>