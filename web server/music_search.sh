#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" == "POST" ]; then
    echo "Location: menu.sh?username=$username"
    logger -p user.info "$username went back to main menu"
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Music Search</title>
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
    <h1>Music search</h1>
    <div>
        <h2>Song paths</h2>
        <pre>$(cat /mnt/songs.txt)</pre>
    </div>
</body>
</html>
"
