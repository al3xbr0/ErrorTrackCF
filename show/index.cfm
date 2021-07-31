<cfif isDefined("url.id") and isDefined("form.edit_comment") 
    and isDefined("form.error_status") and isDefined("form.error_urgency") and isDefined("form.error_criticality")>
    <cfset error_id = url.id>
    <cfset edit_comment = trim(form.edit_comment)>
    <cfset error_status = trim(form.error_status)>
    <cfset error_urgency = trim(form.error_urgency)>
    <cfset error_criticality = trim(form.error_criticality)>
    <cfquery name="paramsCheck">
            SELECT ((SELECT id FROM error_status WHERE id = <cfqueryparam value="#error_status#" cfsqltype="cf_sql_integer">) IS NOT NULL
                AND (SELECT id FROM error_urgency WHERE id = <cfqueryparam value="#error_urgency#" cfsqltype="cf_sql_integer">) IS NOT NULL
                AND (SELECT id FROM error_criticality WHERE id = <cfqueryparam value="#error_criticality#" cfsqltype="cf_sql_integer">) IS NOT NULL
                AND (SELECT to_id
                    FROM status_change_rules rl
                        JOIN errors ON errors.status_id = rl.from_id
                    WHERE errors.id = <cfqueryparam value="#error_id#" cfsqltype="cf_sql_integer">
                        AND rl.to_id = <cfqueryparam value="#error_status#" cfsqltype="cf_sql_integer">) IS NOT NULL) AS ok
    </cfquery>
    <cfif error_id eq "" or edit_comment eq "" or error_status eq "" or error_urgency eq "" or error_criticality eq "" or !paramsCheck.ok>
        <cfset errMsg = "Не все поля заполнены правильно.">
    <cfelse>
        <cflock scope="session" type="readonly" timeout=10>
            <cfset user_id = session.userId>
        </cflock>
        <cfquery name="editError">
            UPDATE errors
            SET status_id      = <cfqueryparam value="#error_status#" cfsqltype="cf_sql_integer">,
                urgency_id     = <cfqueryparam value="#error_urgency#" cfsqltype="cf_sql_integer">,
                criticality_id = <cfqueryparam value="#error_criticality#" cfsqltype="cf_sql_integer">
            WHERE id = <cfqueryparam value="#error_id#" cfsqltype="cf_sql_integer">;
            
            INSERT INTO error_history (date, edit_comment, user_id, error_id, new_status)
            VALUES (#now()#,
                <cfqueryparam value="#edit_comment#" cfsqltype="cf_sql_varchar">,
                #user_id#, 
                <cfqueryparam value="#error_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#error_status#" cfsqltype="cf_sql_integer">)
        </cfquery>
        <cfset editOk = true>
    </cfif>
</cfif>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>
    	<cfif !isDefined("url.id")>
    	   Ошибки — ErrorTrackCF
    	<cfelse>
    	   <cfset id = url.id>
    	   <cfoutput>
    	       Ошибка ###id# — ErrorTrackCF
    	   </cfoutput>
    	</cfif>
    	</title>
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
    <cfif !isDefined("id")>
        <div class="page_description">
            <h2>Список ошибок</h2>
        </div>
        <cfquery name="errors">
    SELECT errors.id,
           date,
           short_description,
           detailed_description,
           usr.first_name || ' ' || usr.last_name AS author,
           stat.name                              AS status,
           urg.name                               AS urgency,
           crit.name                              AS criticality
    FROM errors
             JOIN users usr ON user_id = usr.id
             JOIN error_status stat ON status_id = stat.id
             JOIN error_urgency urg ON urgency_id = urg.id
             JOIN error_criticality crit ON criticality_id = crit.id
    ORDER BY date DESC
        </cfquery>
        <cfif errors.RecordCount gt 0>
            <div class="table_list">
            	<cftable query="errors" colheaders="true" colspacing="10" htmltable border>
                	<cfcol header="Дата создания" text="<a href='?id=#id#'>#dateTimeFormat(date, 'd.mm.YYYY H:n:ss')#</a>" align="center">
                	<cfcol header="Краткое описание" text="#encodeForHTML(short_description)#" align="center">
                	<cfcol header="Автор" text="#author#" align="center">
                	<cfcol header="Статус" text="#status#" align="center">
                	<cfcol header="Срочность" text="#urgency#" align="center">
                	<cfcol header="Критичность" text="#criticality#" align="center">
                </cftable>
            </div>
        <cfelse>
            <cfoutput>
            	<p>В системе пока не сохранено ни одной ошибки.</p>
            </cfoutput>
        </cfif>
    <cfelse>
        <cfquery name="error">
            SELECT errors.id,
                   date,
                   short_description,
                   detailed_description,
                   usr.first_name || ' ' || usr.last_name AS author,
                   status_id,
                   stat.name                              AS status,
                   urgency_id,
                   urg.name                               AS urgency,
                   criticality_id,
                   crit.name                              AS criticality
            FROM errors
                     JOIN users usr ON user_id = usr.id
                     JOIN error_status stat ON status_id = stat.id
                     JOIN error_urgency urg ON urgency_id = urg.id
                     JOIN error_criticality crit ON criticality_id = crit.id
            WHERE errors.id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer" null="#id eq ''#">
        </cfquery>
        <cfif error.RecordCount eq 0>
            <cflocation url="/show" addtoken="false">
        </cfif>
        
        <cfquery name="errorHistory">
            SELECT date, es.name AS status, edit_comment, usr.first_name || ' ' || usr.last_name AS author
            FROM error_history
                JOIN error_status es ON new_status = es.id
                JOIN users usr ON user_id = usr.id
            WHERE error_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            ORDER BY date DESC
        </cfquery>
        <cffunction name="printHistory" access="private">
            <cfif errorHistory.RecordCount gt 0>
                <div class="table_list">
                    <cftable query="errorHistory" colheaders="true" colspacing="10" htmltable border>
                        <cfcol header="Дата изменения" text="#dateTimeFormat(date, 'd.mm.YYYY H:n:ss')#" align="center">
                        <cfcol header="Изменение статуса" text="#status#" align="center">
                        <cfcol header="Комментарий" text="#encodeForHTML(edit_comment)#" align="center">
                        <cfcol header="Пользователь" text="#author#" align="center">
                    </cftable>
                </div>
            <cfelse>
                <cfoutput>
                    <p>У ошибки нет истории.</p>
                </cfoutput>
            </cfif>
        </cffunction>
        
        <cfif !isDefined("url.edit")>
        	<cfoutput query="error">
                <div class="page_description">
                    <h2>Просмотр ошибки ###id#</h2>
                    <p><a href="/show">Вернуться к списку</a></p>
                </div>
        		<p><a href="#cgi.CONTEXT_PATH#?#cgi.QUERY_STRING#&edit">Редактировать</a></p>
            	<table>
            		<colgroup>
                    <col style="width: 20%">
                    <col style="width: 80%">
                </colgroup>
            		<tr>
            			<th>Дата создания</th>
            			<td>#dateTimeFormat(date, "dd.mm.YYYY H:n:ss")#</td>
            		</tr>
            		<tr>
                        <th>Краткое описание</th>
                        <td>#encodeForHTML(short_description)#</td>
                    </tr>
                    <tr>
                        <th>Подробное описание</th>
                        <td>#encodeForHTML(detailed_description)#</td>
                    </tr>
                    <tr>
                        <th>Автор</th>
                        <td>#author#</td>
                    </tr>
                    <tr>
                        <th>Статус</th>
                        <td>#status#</td>
                    </tr>
                    <tr>
                        <th>Срочность</th>
                        <td>#urgency#</td>
                    </tr>
                    <tr>
                        <th>Критичность</th>
                        <td>#criticality#</td>
                    </tr>
            	</table>
            	#printHistory()#
        	</cfoutput>
        <cfelse>
            <cfoutput>
                <div class="page_description">
                    <h2>Редактирование ошибки ###id#</h2>
                    <p><a href="/show?id=#id#">Вернуться к просмотру</a></p>
                </div>
            </cfoutput>
            <cfif !isDefined("editOk")>
                    <form name="edit_error" id="edit_error" method="post">
                        <cfif isDefined("errMsg")>
                        	<cfoutput>
                        		<p class="error">#errMsg#</p>
                        	</cfoutput>
                        </cfif>
                        <table>
                            <colgroup>
                                <col style="width: 20%">
                                <col style="width: 80%">
                            </colgroup>
                            <tr>
                                <th>Статус</th>
                                <td>
                                    <cfquery name="available_statuses">
                                        SELECT to_id, name
                                        FROM status_change_rules
                                            JOIN error_status ON to_id = id
                                        WHERE from_id = #error.status_id#
                                    </cfquery>
                                    <select class="select medium" name="error_status" id="error_status" required>
                                        <cfoutput query="available_statuses">
                                            <option value="#to_id#" <cfif id eq error.status_id>selected</cfif> >#name#</option>
                                        </cfoutput>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th>Срочность</th>
                                <td>
                                    <select class="select medium" name="error_urgency" id="error_urgency" required>
                                        <cfquery name="error_urgency">
                                           SELECT id, name FROM error_urgency
                                        </cfquery>
                                        <cfoutput query="error_urgency">
                                            <option value="#id#" <cfif id eq error.urgency_id>selected</cfif> >#name#</option>
                                        </cfoutput>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th>Критичность</th>
                                <td>
                                    <select class="select medium" name="error_criticality" id="error_criticality" required>
                                        <cfquery name="error_criticality">
                                           SELECT id, name FROM error_criticality
                                        </cfquery>
                                        <cfoutput query="error_criticality">
                                            <option value="#id#" <cfif id eq error.criticality_id>selected</cfif> >#name#</option>
                                        </cfoutput>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th>Комментарий</th>
                                <td><textarea class="textarea medium" name="edit_comment" type="text"
                                id="edit_comment" required></textarea></td>
                            </tr>
                        </table>
                        <div class="buttons">
                            <input class="button_text" name="send" type="submit" value="Отправить">
                        </div>
                    </form>
                    <cfoutput>
                    	#printHistory()#
                    </cfoutput>
            <cfelse>
                <cfif editOk>
                	<p>Ошибка отредактирована.</p>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
</div>
</body>
</html>