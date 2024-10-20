#!/bin/bash

if [ "$REQUEST_METHOD" = "POST" ]; then
    read -r POST_DATA

    username=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | cut -d= -f2)
    password=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | cut -d= -f2)

    if grep -q "^$username:" /etc/passwd; then
        hashed_password=$(sudo grep "^$username:" /etc/shadow | cut -d':' -f2)

        salt=$(sudo grep "^$username:" /etc/shadow | cut -d'$' -f3)
        entered_hashed_password=$(sudo openssl passwd -1 -salt "$salt" "$password")

        if [ "$hashed_password" == "$entered_hashed_password" ]; then
            echo "Location: menu.sh?username=$username"
            #echo "$(date '+%Y-%m-%d %H:%M:%S') User '$username' successfully logged in" >> "/var/log/httpd/actions.log"
            logger -p user.info "'$username' successfully logged in"
        else
            echo "Location: index.sh"
            #echo "$(date '+%Y-%m-%d %H:%M:%S') User '$username' failed to log in" >> "/var/log/httpd/actions.log"
            logger -p user.info "'$username' failed to log in"
        fi
    else
        logger -p user.info "'$username' failed to log in"
        echo "Location: index.sh "
    fi
    echo ""
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Login Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .login-container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 300px;
            text-align: center;
        }

        .login-container h2 {
            margin-bottom: 20px;
        }

        .login-container label {
            display: block;
            margin-bottom: 8px;
        }

        .login-container input {
            width: 100%;
            padding: 8px;
            margin-bottom: 16px;
            box-sizing: border-box;
        }

        .login-container button {
            background-color: #4caf50;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>

<div class=\"login-container\">
    <h2>Login</h2>
    <form action=\"#\" method=\"post\">
        <label for=\"username\">Username:</label>
        <input type=\"text\" id=\"username\" name=\"username\" required>

        <label for=\"password\">Password:</label>
        <input type=\"password\" id=\"password\" name=\"password\" required>

        <button type=\"submit\">Login</button>
    </form>
</div>
</body>
</html>
"