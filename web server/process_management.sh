#!/bin/bash
username=$(echo "$QUERY_STRING" | grep -o 'username=[^&]*' | cut -d= -f2)


table_content=""
status_output=""
pid_param=""
action_param=""
seconds_param=""

generate_html() {
    echo "Content-type: text/html"
    echo ""
    echo -e "
    <html>
    <head>
        <title>Process Management</title>
        <style>
            body {
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            #form-container {
                margin-top: 20px;
            }
            #columns {
                display: flex;
                flex-direction: row;
                align-items: center;
                width: 80%;
            }
            #left-column, #right-column {
                width: 48%;
                margin: 10px;
            }
            #right-column {
                display: flex;
                flex-direction: column;
                align-self: flex-start;
            }
            table {
                border-collapse: collapse;
                width: 100%;
                margin-top: 20px;
            }
            th, td {
                border: 1px solid #dddddd;
                text-align: left;
                padding: 8px;
            }
            th {
                background-color: #f2f2f2;
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
        <form class='back-button' action=\"process_management.sh?username=$username\" method=\"post\">
            <button type=\"submit\" name=\"pid\" value=\"back\">BACK</button>
        </form>
        <h1>Process Management</h1>
        <div id=\"form-container\">
            <form action=\"process_management.sh?username=$username\" method=\"post\">
                <label for=\"pid\">Enter PID:</label>
                <input type=\"text\" id=\"pid\" name=\"pid\" placeholder=\"Enter PID\" value=\"$pid_param\" required>

                <label for=\"action\">Select Action:</label>
                <select id=\"action\" name=\"action\" required>
                    <option value=\"status\">Get Status</option>
                    <option value=\"interrupt\">Interrupt</option>
                    <option value=\"remove\">Remove Process</option>
                </select>

                <label for=\"seconds\" id=\"seconds-label\" style=\"display: none;\">Seconds:</label>
                <input type=\"number\" id=\"seconds\" name=\"seconds\" min=\"1\" style=\"display: none;\">

                <input type=\"submit\" value=\"Submit\">
            </form>
        </div>
        <div id=\"columns\">
            <div id="left-column">
                <h2>Processes</h2>
                <table>
                    <tr>
                        <th>PID</th>
                        <th>Process</th>
                    </tr>
                    $table_content
                </table>
            </div>
            <div id="right-column">
                <h2>Process Status:</h2>
                <pre>$status_output</pre>
            </div>
        </div>
        <script>
            document.getElementById('action').addEventListener('change', function () {
                const secondsLabel = document.getElementById('seconds-label');
                const secondsInput = document.getElementById('seconds');

                if (this.value === 'interrupt') {
                    secondsLabel.style.display = 'inline-block';
                    secondsInput.style.display = 'inline-block';
                } else {
                    secondsLabel.style.display = 'none';
                    secondsInput.style.display = 'none';
                }
            });
        </script>
    </body>
    </html>
    "
}

generate_process_row() {
    local pid=$1
    local command=$2

    echo -e "
            <tr>
                <td>$pid</td>
                <td>$command</td>
            </tr>
    "
}

get_process_status() {
    local pid=$1

    if [ -n "$pid" ]; then
        status_output=$(ps -p $pid)
    fi
}

interrupt_process() {
    local pid=$1
    local seconds=$2

    kill -STOP $pid
    sleep "$seconds"s
    kill -CONT $pid
}

remove_process() {
    local pid=$1
    kill -9 $pid
}

if [ "$REQUEST_METHOD" = "POST" ]; then
   read -r QUERY_STRING
   IFS='&' read -ra params <<< "$QUERY_STRING"
   for param in "${params[@]}"; do
       IFS='=' read -r key value <<< "$param"
       case "$key" in
           pid) pid_param="$value" ;;
           action) action_param="$value" ;;
           seconds) seconds_param="$value" ;;
       esac
   done

   if [ "$pid_param" == "back" ]; then
        echo "Location: menu.sh?username=$username"
        #echo "$(date '+%Y-%m-%d %H:%M:%S') User went back to main menu" >> "/var/log/httpd/actions.log"
        logger -p user.info "'$username' went back to main menu"
   fi
   if [ "$action_param" == "status" ]; then
        get_process_status "$pid_param"
        #echo "$(date '+%Y-%m-%d %H:%M:%S') User got the state of the process with PID: $pid_param" >> "/var/log/httpd/actions.log"
        logger -p user.info "'$username' got the state of the process with PID: $pid_param"
   fi
   if [ "$action_param" == "interrupt" ]; then
        interrupt_process "$pid_param" "$seconds_param"
        #echo "$(date '+%Y-%m-%d %H:%M:%S') User interrupted during $seconds_param seconds the process with PID: $pid_param" >> "/var/log/httpd/actions.log"
        logger -p user.info "'$username' interrupted during $seconds_param seconds the process with PID: $pid_param"
   fi
   if [ "$action_param" == "remove" ]; then
        remove_process "$pid_param"
        #echo "$(date '+%Y-%m-%d %H:%M:%S') User removed process with PID: $pid_param" >> "/var/log/httpd/actions.log"
        logger -p user.info "'$username' removed process with PID: $pid_param"
   fi
fi

while read -r pid command; do
    table_content+=$(generate_process_row "$pid" "$command")
done < <(ps -eo pid,comm --no-headers)

generate_html
