#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" == "POST" ]; then
    read -n $CONTENT_LENGTH post_data
    selected_option=$(echo "$post_data" | cut -d'=' -f2)

    case $selected_option in
        1)
            echo "Location: process_management.sh?username=$username"
            logger -p user.info "'$username' went to the process management page"
        ;;
        2)
            echo "Location: monitoring.sh?username=$username"
            logger -p user.info "'$username' went to the monitoring page"
        ;;
        3)
             echo "Location: shutdown_restart.sh?username=$username"
             logger -p user.info "'$username' went to the shutdown & restart page"
        ;;
        4)
            echo "Location: manage_logs.sh?username=$username"
            logger -p user.info "'$username' went to the logs page"
        ;;
        5)
            echo "Location: user_management.sh?username=$username"
            logger -p user.info "'$username' went to the management page"
        ;;
        6)
            echo "Location: packet_filtering.sh?username=$username"
            logger -p user.info "'$username' went to the packet filtering page"
        ;;
        7)
            echo "Location: manage_tasks.sh?username=$username"
            logger -p user.info "'$username' went to the task management page"
        ;;
        8)
            echo "Location: music_search.sh?username=$username"
            logger -p user.info "'$username' went to the music search page"
        ;;
    esac
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Main menu</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 20px;
        }
        h1 {
            color: #3498db;
        }
        h2 {
            color: #6C757D;
        }
        button {
            background-color: #4CAF50;
            color: white;
            padding: 12px 24px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 10px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h1>Welcome $username!</h1>
    <h2>Main menu</h2>
    <form method="post">
    <button type="submit" name="option" value="1">Process Management</button>
    <button type="submit" name="option" value="2">Monitoring</button>
    <button type="submit" name="option" value="3">Shut down & Restart</button>
    <button type="submit" name="option" value="4">Manage Logs</button>
    <button type="submit" name="option" value="5">User Management</button>
    <button type="submit" name="option" value="6">Packet Filtering</button>
    <button type="submit" name="option" value="7">Manage Tasks</button>
    <button type="submit" name="option" value="8">Music Search</button>
    </form>
</body>
</html>"
