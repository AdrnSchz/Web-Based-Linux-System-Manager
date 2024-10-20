#!/bin/bash

username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" == "POST" ]; then
    echo "Location: menu.sh?username=$username"
    #echo "$(date '+%Y-%m-%d %H:%M:%S') User went back to main menu" >> "/var/log/httpd/actions.log"
    logger -p user.info "'$username' went back to main menu"
fi
echo "Content-type: text/html"
echo ""
echo -e "
<html>
    <head>
        <title>Monitoring</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
            }
            h1 {
                color: #333;
            }
            h2 {
                color: #555;
            }
            pre {
                background-color: #f5f5f5;
                padding: 10px;
                border-radius: 5px;
                overflow-x: auto;
            }
            .back-button {
                position: absolute;
                top: 10px;
                right: 10px;
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
        <h1>Server Monitoring</h1>
        <h2>Server Resources:</h2>
        <pre>$(uptime)</pre>
        <pre>$(free -h)</pre>
        <pre>$(df -h)</pre>
        <h2>Last 10 Server Accesses:</h2>
        <pre>$(grep 'log' /var/log/httpd/actions.log | tail -n 10)</pre>
        <h2>System information:</h2>
        <pre>$(uname -a)</pre>
    </body>
</html>
"
