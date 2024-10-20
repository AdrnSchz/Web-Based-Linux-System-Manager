#!/bin/bash

username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)
minute=""
hour=""
day=""
month=""
weekday=""
encoded_task=""
task_id=""
task=""

if [ "$REQUEST_METHOD" == "POST" ]; then
    option=$(echo "$QUERY_STRING" | grep -o 'option=[^&]*' | cut -d= -f2)
    read -r QUERY_STRING
    IFS='&' read -ra params <<< "$QUERY_STRING"
    for param in "${params[@]}"; do
        IFS='=' read -r key value <<< "$param"
        case "$key" in
            option) option="$value" ;;
            minute) minute="$value" ;;
            hour) hour="$value" ;;
            day) day="$value" ;;
            month) month="$value" ;;
            weekday) weekday="$value" ;;
            task) encoded_task="$value" ;;
        esac
    done
    case $option in
        1)
            echo "Location: menu.sh?username=$username"
            logger -p user.info "'$username' went back to the main menu"
            ;;
        2)
            task=$(echo -e "$encoded_task" | sed 's/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g')
            cron_expression="$minute $hour $day $month $weekday"
            (sudo -u $username fcrontab -l ; echo "$cron_expression $task") | sudo -u $username fcrontab -
            logger -p user.info "'$username' added the task: '$task' scheduled each $minutem minute, each $hour hour, each $day day and each $month month(weekday: $weekday)"
            ;;
        3)
            task=$(echo -e "$encoded_task" | sed 's/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g')
            cron_expression="$minute $hour $day $month $weekday"
            logger -p user.info "'$username' removed the task $task scheduled each $minutem minute, each $hour hour, each $day day and each $month month(weekday: $weekday)"
            sudo -u $username fcrontab -l | grep -v -F "$cron_expression $task" | sudo -u $username fcrontab -
            logger -p user.info "'$username' removed the task $task scheduled each $minutem minute, each $hour hour, each $day day and each $month month(weekday: $weekday)"
            ;;
    esac
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Manage Tasks</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        .back-button {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        .scroll-pane {
            overflow-y: scroll;
            height: 20%;
            width: 80%;
            border: 1px solid #ccc;
            padding: 10px;
        }
        label {
            display: block;
            margin-bottom: 4px;
            color: #333;
        }
        input {
            width: 100%;
            padding: 10px;
            margin-bottom: 4px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #4caf50;
            color: #fff;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <form class='back-button' method=\"post\">
        <button type=\"submit\" name=\"option\" value=\"1\">BACK</button>
    </form>
    <h1>Manage tasks</h1>

    <h2>Preprogrammed Tasks:</h2>
    <div class=\"scroll-pane\">
        $(sudo -u $username fcrontab -l | grep -v '^#' | sed '/^\s*$/d' | sed 's/\s\s*/ /g' | awk '{print "<li>" $0 "</li>"}')
    </div>

    <h2>Add/Remove Task:</h2>
    <form method=\"post\">
        <label for=\"minute\">Minute:</label>
        <input type=\"text\" id=\"minute\" name=\"minute\" placeholder=\"*\" required>

        <label for=\"hour\">Hour:</label>
        <input type=\"text\" id=\"hour\" name=\"hour\" placeholder=\"*\" required>

        <label for=\"day\">Day:</label>
        <input type=\"text\" id=\"day\" name=\"day\" placeholder=\"*\" required>

        <label for=\"month\">Month:</label>
        <input type=\"text\" id=\"month\" name=\"month\" placeholder=\"*\" required>

        <label for=\"weekday\">Weekday:</label>
        <input type=\"text\" id=\"weekday\" name=\"weekday\" placeholder=\"*\" required>

        <label for=\"task\">Task Command:</label>
        <input type=\"text\" id=\"task\" name=\"task\" placeholder=\"/path/to/command\" required>

        <button type=\"submit\" name=\"option\" value=\"2\">Add Task</button>
        <button type=\"submit\" name=\"option\" value=\"3\">Remove Task</button>
    </form>
</body>
</html>
"
