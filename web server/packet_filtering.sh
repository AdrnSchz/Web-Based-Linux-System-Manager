#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)

if [ "$REQUEST_METHOD" == "POST" ]; then
    read -r QUERY_STRING
    IFS='&' read -ra params <<< "$QUERY_STRING"
    for param in "${params[@]}"; do
        IFS='=' read -r key value <<< "$param"
        case "$key" in
            option) option="$value" ;;
            table) table="$value" ;;
            protocol) protocol="$value" ;;
            source_ip) source_ip="$value" ;;
            dest_ip) dest_ip="$value" ;;
            port) port="$value" ;;
            action) action="$value" ;;
        esac
    done

    case $option in
        1)
            echo "Location: menu.sh?username=$username"
            logger -p user.info "$username went back to the main menu"
            ;;
        2)
            rule=""
            [ -n "$protocol" ] && rule="$rule -p $protocol"
            [ -n "$source_ip" ] && rule="$rule -s $source_ip"
            [ -n "$dest_ip" ] && rule="$rule -d $dest_ip"
            [ -n "$port" ] && rule="$rule --dport $port"
            [ -n "$action" ] && rule="$rule -j $action"
            case $table in
                filter)
                    sudo iptables -A INPUT $rule
                    ;;
                nat)
                    sudo iptables -t nat -A PREROUTING $rule
                    ;;
                mangle)
                    sudo iptables -t mangle -A INPUT $rule
                    ;;
            esac
            logger -p user.info "$username added iptables rule to $table table: $rule"
            ;;
    esac
fi

echo "Content-type: text/html"
echo ""
echo -e "
<html>
<head>
    <title>Packet Filtering</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        h2 {
                color: #555;
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
        pre {
            background-color: #f5f5f5;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <form class='back-button' method=\"post\">
        <button type=\"submit\" name=\"option\" value=\"1\">BACK</button>
    </form>
    <h1>Packet filtering</h1>

    <h2>Filter Table</h2>
    <pre>$(sudo iptables -L INPUT -n --line-numbers | sed '1d')</pre>
    <h2>NAT Table</h2>
    <pre>$(sudo iptables -t nat -L PREROUTING -n --line-numbers | sed '1d')</pre>
    <h2>Mangle Table</h2>
    <pre>$(sudo iptables -t mangle -L INPUT -n --line-numbers | sed '1d')</pre>
    <h2>Add Rule</h2>
    <form method=\"post\">
        <label for=\"table\">Select Table:</label>
        <select name=\"table\">
            <option value=\"filter\">Filter</option>
            <option value=\"nat\">NAT</option>
            <option value=\"mangle\">Mangle</option>
        </select>

        <label for=\"protocol\">Protocol:</label>
        <input type=\"text\" name=\"protocol\" placeholder=\"TCP/UDP/ICMP\">

        <label for=\"source_ip\">Source IP:</label>
        <input type=\"text\" name=\"source_ip\" placeholder=\"Source IP\">

        <label for=\"dest_ip\">Destination IP:</label>
        <input type=\"text\" name=\"dest_ip\" placeholder=\"Destination IP\">

        <label for=\"port\">Port:</label>
        <input type=\"text\" name=\"port\" placeholder=\"Port\">

        <label for=\"action\">Action:</label>
        <input type=\"text\" name=\"action\" placeholder=\"ACCEPT, DROP...\" required>
        <button type=\"submit\" name=\"option\" value=\"2\">Apply Rule</button>
    </form>
</body>
</html>
"