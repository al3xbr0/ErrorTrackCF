<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Создание ошибки — ErrorTrackCF</title>
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
    	<h2>Создание новой ошибки</h2>
    </div>
    
    <cfif isDefined("form.short_description") and isDefined("form.detailed_description")
and isDefined("form.error_urgency") and isDefined("form.error_criticality")>
    <cfset short_description = trim(form.short_description)>
    <cfset detailed_description = trim(form.detailed_description)>
    <cfset error_urgency = trim(form.error_urgency)>
    <cfset error_criticality = trim(form.error_criticality)>
    <cfquery name="paramsCheck">
        SELECT ((SELECT id FROM error_urgency WHERE id = <cfqueryparam value="#error_urgency#" cfsqltype="cf_sql_integer">) IS NOT NULL
            AND (SELECT id FROM error_criticality WHERE id = <cfqueryparam value="#error_criticality#" cfsqltype="cf_sql_integer">) IS NOT NULL)
                AS ok
    </cfquery>
    <cfif short_description eq "" or detailed_description eq "" or !paramsCheck.ok>
        <cfset errMsg="Не все поля заполнены правильно.">
    <cfelse>
    <cflock scope="session" type="readonly" timeout=10>
        <cfset user_id = session.userId>
    </cflock>
        <cfquery name="newError">
            INSERT INTO errors (date, short_description, detailed_description, user_id, urgency_id, criticality_id) VALUES
            (#now()#,
            <cfqueryparam value="#short_description#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#detailed_description#" cfsqltype="cf_sql_varchar">,
            #user_id#,
            <cfqueryparam value="#error_urgency#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#error_criticality#" cfsqltype="cf_sql_integer">) RETURNING id
        </cfquery>
        <cfquery name="newHistory">   
            INSERT INTO error_history (date, edit_comment, user_id, error_id, new_status)
            SELECT date, 'Внесена информация о новой ошибке.', user_id, id, status_id
            FROM errors
            WHERE id = #newError.id#;
        </cfquery>
        <cfoutput>
        	<p>Ошибка создана. Перейдите по <a href="/show?id=#newError.id#">ссылке</a>, чтобы просмотреть.</p>
        </cfoutput>
    </cfif>
    <cfelse>
    <form name="create_error" id="create_error" method="post">
    <ul>
    	<cfif isDefined("errMsg")>
    		<cfoutput>
    			<li>
    				<p class="error">#errMsg#</p>
    			</li>
    		</cfoutput>
    	</cfif>
        <li>
            <label class="description" for="short_description">Краткое описание</label>
            <div>
                <input class="element text medium" name="short_description" type="text" id="short_description" required>
            </div>
        </li>
        <li>
            <label class="description" for="detailed_description">Подробное описание</label>
            <div>
                <textarea class="textarea medium" name="detailed_description" type="text" id="detailed_description" required></textarea>
            </div>
        </li>
        <li>
            <label class="description" for="error_urgency">Срочность</label>
            <div>
                <select class="select medium" name="error_urgency" id="error_urgency" required>
                	<cfquery name="error_urgency">
                		SELECT id, name FROM error_urgency
                	</cfquery>
                	<cfoutput query="error_urgency">
                		<option value="#id#">#name#</option>
                	</cfoutput>
                </select>
            </div>
        </li>
        <li>
            <label class="description" for="error_criticality">Критичность</label>
            <div>
                <select class="select medium" name="error_criticality" id="error_criticality" required>
                    <cfquery name="error_criticality">
                        SELECT id, name FROM error_criticality
                    </cfquery>
                    <cfoutput query="error_criticality">
                        <option value="#id#">#name#</option>
                    </cfoutput>
                </select>
            </div>
        </li>
        <li class="buttons">
            <input class="button_text" name="send" type="submit" value="Создать">
        </li>
    </ul>
</form>
</cfif>
</div>
</body>
</html>