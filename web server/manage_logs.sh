#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" == "POST" ]; then
    echo "Location: menu.sh?username=$username"
    #echo "$(date '+%Y-%m-%d %H:%M:%S') User went back to main menu" >> "/var/log/httpd/actions.log"
    logger -p user.info "'$username' went back to main menu"
fi

CONTENTS=$(grep "apache" "/var/log/httpd/actions.log")

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Manage logs</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .scroll-pane {
            overflow-y: scroll;
            height: 70%;
            width: 80%;
            border: 1px solid #ccc;
            padding: 10px;
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
    <h1>Manage logs</h1>
    <div class=\"scroll-pane\">
        <pre>$CONTENTS</pre>
    </div>
</body>
</html>
"
