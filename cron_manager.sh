#!/bin/bash


scheduled_jobs_file="scheduled_jobs.conf"


show_menu() {
    echo "1) 查看已配置的定时任务"
    echo "2) 添加新的定时程序"
    echo "3) 删除现有定时程序"
    echo "4) 退出"
    echo -n "请选择一个选项："
}


list_scheduled_jobs() {
    echo "所有的定时任务："

    crontab -l | nl -v 0 | awk '{print "[" $1 "] " $2, $3, $4, $5, $6, $7, $8, $9, $10}'

    if [ ! -f $scheduled_jobs_file ]; then
        echo "当前没有用户添加的任务。"
        return
    fi

    echo "用户添加的定时任务："

    cat $scheduled_jobs_file | nl -v 0 | awk '{print "[" $1 "] " $2}'
}


add_new_job() {
    echo -n "请输入程序的完整路径："
    read program_path
    echo -n "请输入定时任务的表达式（例如，每天晚上8点： '0 20 * * *'）："
    read cron_expression
    echo "$cron_expression $program_path" >> $scheduled_jobs_file
    new_cron_job="$cron_expression $program_path"
    (crontab -l 2>/dev/null; echo "$new_cron_job") | crontab -
    echo "新的定时程序已添加。"
}


delete_job() {
    echo "现有的全体任务列表："
    local tasks=$(crontab -l)
    echo "$tasks" | nl -v 0 | awk '{print "[" $1 "] " $2, $3, $4, $5, $6, $7, $8, $9, $10}'

    if [ -f $scheduled_jobs_file ]; then
        echo "用户添加的定时任务列表："
        cat $scheduled_jobs_file | nl -v 0 | awk '{print "[" $1 "] " $2}'
    else
        echo "当前没有用户添加的任务。"
    fi


    echo -n "请输入要删除的任务的行号："
    read line_number


    ((line_number++))


    local selected_task=$(echo "$tasks" | sed -n "${line_number}p")
    

    if [ -z "$selected_task" ]; then
        echo "选定的任务不存在，请重试。"
        return
    fi


    echo "你选择删除的任务为：[$line_number] $selected_task"
    echo "是否确定删除选定的这项任务？[y/N]"
    read confirmation
    if [[ "$confirmation" = "y" || "$confirmation" = "Y" ]]; then

        if [ -f $scheduled_jobs_file ]; then

            local adjusted_line_number=$((line_number-1))
            sed -i "${adjusted_line_number}d" $scheduled_jobs_file
        fi

        (crontab -l | sed "${line_number}d") | crontab -
        echo "任务已删除。"
    else
        echo "操作已取消。"
    fi
}


while true; do
    show_menu
    read choice
    case "$choice" in
        1)
            list_scheduled_jobs
            ;;
        2)
            add_new_job
            ;;
        3)
            delete_job
            ;;
        4)
            break
            ;;
        *)
            echo "未知选项。"
    esac
done
