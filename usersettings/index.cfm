<cflock scope="session" type="readonly" timeout=10>
    <cfset user_id = session.userId>
</cflock>
<cfquery name="userInfo">
	SELECT username, first_name, last_name FROM users WHERE id = #user_id#
</cfquery>

<cfif !structIsEmpty(form)>
    <cfif !isDefined("form.first_name") or !isDefined("form.last_name")>
    	<cfset errMsg = "Имя или фамилия обязательно должны быть указаны.">
    <cfelse>
        <cfset first_name = trim(form.first_name)>
        <cfset last_name = trim(form.last_name)>
        <cfif compare(first_name, userInfo.first_name) neq 0 or compare(last_name, userInfo.last_name) neq 0>
            <cfif !refind("^[\w-]+$", first_name) or !refind("^[\w-]+$", last_name)>
                <cfset errMsg = "Имя или фамилия указаны в некорректном формате.">
            <cfelse>
                <cfquery name="updateNames">
                	UPDATE users
                	SET first_name = <cfqueryparam value="#first_name#" cfsqltype="cf_sql_varchar">,
                	    last_name  = <cfqueryparam value="#last_name#" cfsqltype="cf_sql_varchar">
                    WHERE id = #user_id#
                </cfquery>
                <cfset updMsg="Личные данные обновлены.">
            </cfif>
        </cfif>
   
        <cfset password = Iif(isDefined("form.password"), Evaluate(DE("trim(form.password)")), DE(""))>
        <cfset new_password = Iif(isDefined("form.new_password"), Evaluate(DE("trim(form.new_password)")), DE(""))>
        <cfset new_password_repeat = Iif(isDefined("form.new_password_repeat"), Evaluate(DE("trim(form.new_password_repeat)")), DE(""))>
        <cfif password neq "" or new_password neq "" or new_password_repeat neq "">
        	<cfif password eq "" or new_password eq "" or new_password_repeat eq "">
            	<cfset errMsg = "Требуется заполнить все поля с паролями.">
            <cfelse>
                <cfif !refind("^[\w!@##$%^&*()+=,.<>\/?{}[\]|""';:`~-]+$", new_password) 
                    or !refind("^[\w!@##$%^&*()+=,.<>\/?{}[\]|""';:`~-]+$", new_password_repeat)>
                    <cfset errMsg = "Указан некорректный пароль.">
                <cfelse>
                    <cfif compare(new_password, new_password_repeat) neq 0>
                    	<cfset errMsg = "Указанные пароли должны совпадать.">
                    <cfelse>
                        <cfquery name="checkPass">
                        	SELECT crypt(<cfqueryparam value="#password#" cfsqltype="cf_sql_varchar">,
                                password_hash) = password_hash AS ok
                            FROM users WHERE id = #user_id#
                        </cfquery>
                        <cfif !checkPass.ok>
                        	<cfset errMsg = "Указан неверный текущий пароль.">
                        <cfelse>
                            <cfquery name="updatePass">
                            	UPDATE users
                            	SET password_hash = crypt(<cfqueryparam value="#new_password#" cfsqltype="cf_sql_varchar">, gen_salt('md5'))
                                WHERE id = #user_id#
                            </cfquery>
                            <cfset updMsg="Пароль успешно обновлен.">
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
</cfif>
<cfif !isDefined("first_name")>
	<cfset first_name = userInfo.first_name>
</cfif>
<cfif !isDefined("last_name")>
    <cfset last_name = userInfo.last_name>
</cfif>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Настройки — ErrorTrackCF</title>
    <link rel="stylesheet" type="text/css" href="/styles.css">
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
            <h2>Настройки аккаунта</h2>
        </div>
        <cfoutput>
            <form name="signup" id="signup" method="post">
                <ul>
                    <cfif isDefined("errMsg")>
                    	<li>
                    		<p class="error">#errMsg#</p>
                    	</li>
                    </cfif>
                    <cfif isDefined("updMsg")>
                        <li>
                            <p style="margin: 0 0 2px">#updMsg#</p>
                        </li>
                    </cfif>
                    <li>
                        <label class="description" for="username">Логин</label>
                        <div>
                            <input class="element text medium" name="username" type="text" id="username" value="#userInfo.username#" disabled>
                        </div>
                    </li>
                    <li>
                        <label class="description" for="first_name">Имя</label>
                        <div>
                            <input class="element text medium" name="first_name" type="text" id="first_name" value="#first_name#" required>
                        </div>
                    </li>
                    <li style="border-bottom: 1px dotted ##ccc">
                        <label class="description" for="last_name">Фамилия</label>
                        <div>
                            <input class="element text medium" name="last_name" type="text" id="last_name" value="#last_name#" required>
                        </div>
                    </li>
                    <h3>Изменение пароля</h3>
                    <li>
                        <label class="description" for="password">Текущий пароль</label>
                        <div>
                            <input class="element text medium" name="password" type="password" id="password">
                        </div>
                    </li>
                    <li>
                        <label class="description" for="password">Новый пароль</label>
                        <div>
                            <input class="element text medium" name="new_password" type="password" id="new_password">
                        </div>
                        <p class="guidelines"><small>Пароль Зависит от регистра. Должен состоять из латинских букв, цифр и
                            других символов.</small></p>
                    </li>
                    <li>
                        <label class="description" for="password_repeat">Повторите новый пароль</label>
                        <div>
                            <input class="element text medium" name="new_password_repeat" type="password" id="new_password_repeat">
                        </div>
                    </li>
                    
                    <li class="buttons">
                        <input class="button_text" name="send" type="submit" value="Обновить информацию">
                    </li>
                </ul>
            </form>
        </cfoutput>
    </div>
</body>
</html>