<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Пользователи — ErrorTrackCF</title>
    <link rel="stylesheet" type="text/css" href="/styles.css">
    <script type="text/javascript" src="/tablesort.js"></script>
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
                    <li><a href="?logout"><cfoutput>#GetAuthUser()#</cfoutput> — выйти</a></li>
                    <li><a href="/usersettings">Настройки</a></li>
                    <li><a href="/userlist">Пользователи</a></li>
                </ul>
            </li>
        </ul>
    </div>
    <div class="page_description">
    	<h2>Список пользователей системы</h2>
    </div>
    <cfquery name="users">
    	SELECT username, first_name, last_name FROM users
    </cfquery>
    <div class="table_list">
        <cftable query="users" colheaders="true" htmltable border>
            <cfcol header="Логин" text="#username#" align="center">
            <cfcol header="Имя" text="#first_name#" align="center">
            <cfcol header="Фамилия" text="#last_name#" align="center">
        </cftable>
    </div>
 </div>
 </body>