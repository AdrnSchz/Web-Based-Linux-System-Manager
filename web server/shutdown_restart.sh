#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" = "POST" ]; then
    read -r QUERY_STRING
    IFS='&' read -ra params <<< "$QUERY_STRING"
    for param in "${params[@]}"; do
        IFS='=' read -r key value <<< "$param"
        case "$key" in
            action)
                case "$value" in
                    shutdown)
                        /etc/rc.d/init.d/httpd stop
                        #echo "$(date '+%Y-%m-%d %H:%M:%S') User shutdowned the server" >> "/var/log/httpd/actions.log"
                        logger -p user.info "'$username' shutdowned the server"
                        ;;
                    restart)
                        /etc/rc.d/init.d/httpd restart
                        #echo "$(date '+%Y-%m-%d %H:%M:%S') User restearted the server" >> "/var/log/httpd/actions.log"
                        logger -p user.info "'$username' restearted the server"
                        ;;
                    back)
                        echo "Location: menu.sh?username=$username"
                        #echo "$(date '+%Y-%m-%d %H:%M:%S') User went back to main menu" >> "/var/log/httpd/actions.log"
                        logger -p user.info "'$username' went back to main menu"
                esac
                ;;
        esac
    done
fi
echo "Content-type: text/html"
echo ""
echo -e "
<html>
    <head>
        <title>Shutdown & Restart</title>
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
        <form class='back-button' action=\"shutdown_restart.sh?username=$username\" method=\"post\">
            <button type=\"submit\" name=\"action\" value=\"back\">BACK</button>
        </form>
        <h1>Shutdown & Restart</h1>
        <form action=\"shutdown_restart.sh?username=$username\" method=\"post\">
            <button type=\"submit\" name=\"action\" value=\"shutdown\">Shutdown</button>
            <button type=\"submit\" name=\"action\" value=\"restart\">Restart</button>
        </form>
    </body>
</html>"
