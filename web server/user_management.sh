#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)
user=""
pass=""

if [ "$REQUEST_METHOD" == "POST" ]; then
    read -r QUERY_STRING
    IFS='&' read -ra params <<< "$QUERY_STRING"
    for param in "${params[@]}"; do
        IFS='=' read -r key value <<< "$param"
        case "$key" in
            option) option="$value" ;;
            username) user="$value" ;;
            password) pass="$value" ;;
        esac
    done

    case $option in
        1)
            echo "Location: menu.sh?username=$username"
            logger -p user.info "$username went back to main menu"
            ;;
        2)
            if [ -n "$user" ] && [ -n "$pass" ]; then
                sudo useradd "$user" -m

                if [ $? == 0 ]; then
                    echo "$user:$pass" | sudo chpasswd
                    logger -p user.info "'$username' successfully added $user"
                else
                    logger -p user.info "'$username' tried to add $user, but failed"
                fi
            fi
            ;;
        3)
            if grep -q "^$user:" /etc/passwd; then
                hashed_password=$(sudo grep "^$user:" /etc/shadow | cut -d':' -f2)

                salt=$(sudo grep "^$user:" /etc/shadow | cut -d'$' -f3)
                hashed_pass=$(sudo openssl passwd -1 -salt "$salt" "$pass")

                if [ "$hashed_password" == "$hashed_pass" ]; then
                    sudo userdel -r "$user"
                    echo "Location: user_management.sh?username=$username"
                    logger -p user.info "'$username' successfully deleted $user"
                else
                    echo "Location: user_management.sh?username=$username"
                    logger -p user.info "'$username' tried to remove $user, but password didn't match"
                fi
            else
                echo "Location: user_management.sh?username=$username"
                logger -p user.info "'$username' tried to remove a non existing user: $user"
            fi
            ;;
    esac
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>User Management</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        h1 {
            color: #333;
        }
        .back-button {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        #columns {
            display: flex;
            flex-direction: row;
            align-items: center;
            width: 80%;
        }
        #left-column, #right-column {
            width: 48%;
            margin: 50px;
        }
        #right-column {
            display: flex;
            flex-direction: column;
            align-self: flex-start;
        }
        #left-column {
            margin-top: 5.6%;
        }
        #scroll-pane {
            overflow-y: scroll;
            height: 70%;
            width: 80%;
            border: 1px solid #ccc;
            padding: 10px;
        }
        #form-container {
            margin-top: 20px;
            max-width: 400px;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
        }
        input {
            width: 100%;
            padding: 10px;
            margin-bottom: 16px;
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
    <h1>User management</h1>
    <div id=\"columns\">
        <div id="left-column">
            <div class='form-container'>
                <form method=\"post\">
                    <label for=\"username\">Username:</label>
                    <input type=\"text\" id=\"username\" name=\"username\" required>

                    <label for=\"password\">Password:</label>
                    <input type=\"password\" id=\"password\" name=\"password\" required>

                    <button type=\"submit\" name=\"option\" value=\"2\">Add User</button>
                    <button type=\"submit\" name=\"option\" value=\"3\">Remove User</button>
                </form>
            </div>
        </div>
        <div id="right-column">
            <h3>Users:</h3>
            <div class=\"scroll-pane\">
                <pre>$(awk -F':' '$NF ~ /(\/bin\/bash|\/bin\/sh)$/ {print "<li>" $1 "</li>"}' /etc/passwd)</pre>
            </div>
        </div>
    </div>
</body>
</html>
"
