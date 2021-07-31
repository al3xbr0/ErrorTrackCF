<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Главная страница — ErrorTrackCF</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>

<body>
<div id="page_container">
    <h1>ErrorTrackCF</h1>
    <div class="top-menu">
        <ul>
        	<li class="topmenu"><a href="/">Главная</a></li>
            <li class="topmenu"><a href="/create">Создать ошибку</a></li>
            <li class="topmenu"><a href="/show">Просмотр ошибок</a></li>
            <li class="topmenu">
                <a>Пользователь</a>
                <ul class="submenu">
                    <li><a href="?logout">
                        <cfoutput>#GetAuthUser()#</cfoutput>
                        — выйти</a></li>
                    <li><a href="/usersettings">Настройки</a></li>
                    <li><a href="/userlist">Пользователи</a></li>
                </ul>
            </li>
        </ul>
    </div>
    <div class="page_description">
        <h2>ErrorTrackCF — </h2>
        <p>это система, предназначенная для отслеживания информации об ошибках на протяжении всего их жизненного цикла: от внесения при выявлении до закрытия в результате исправления проблемы.</p>
    </div>
    <p style="padding: 10px 20px 0px;">В системе реализован следующий функционал:</p>
    <ul class="list">
    	<li>
    		Регистрация и вход для неавторизованных пользователей (доступ без авторизации запрещен) 
    	</li>
    	<li>
    		Внесение информации о новой ошибке
    	</li>
        <li>
            Просмотра списка всех ошибок, сохраненных в системе
        </li>
        <li>
            Просмотр конкретной ошибки и ее истории изменений
        </li>
        <li>
            Пользовательские настройки: изменение личной информации и пароля 
        </li>
        <li>
            Список всех пользователей, зарегистрированных в системе
        </li>
    </ul>
</div>
</body>
</html>