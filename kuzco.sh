#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 检查是否安装了 systemd
function check_systemd() {
    if [ -d /run/systemd/system ]; then
        echo "系统正在使用 systemd。"
    else
        echo "警告: 系统未使用 systemd，可能会影响某些服务的管理。"
    fi
}

# 检查并安装 screen 的函数
function check_and_install_screen() {
    if command -v screen >/dev/null 2>&1; then
        echo "screen 已经安装。"
    else
        echo "screen 未安装，正在安装..."
        apt-get install screen -y
    fi
}

# 安装节点的函数
function install_node() {
    echo "正在更新软件包列表..."
    apt-get update

    echo "正在升级软件包..."
    apt-get upgrade -y

    echo "正在清理不再需要的软件包..."
    apt-get autoremove -y
    apt-get autoclean

    echo "检查并安装 screen..."
    check_and_install_screen

    echo "正在执行远程安装脚本..."
    curl -fsSL https://kuzco.xyz/install.sh | sh
    echo "远程安装脚本完成。"
    
    echo "正在执行升级脚本..."
    kuzco upgrade
    echo "升级脚本完成。"
    
    # 返回主菜单
    echo "节点安装完成，返回主菜单..."
    sleep 3
}

# 启动节点的函数
function start_node() {
    echo "初始化节点..."
    
    # 启动一个名为 'kuzco' 的新 screen 会话，并在后台运行
    screen -S kuzco -dm
    
    # 在 screen 会话中执行 'kuzco init'
    screen -S kuzco -X stuff "kuzco init\n"
    sleep 5  # 等待 'kuzco init' 完成启动，确保初始化脚本已开始运行

    # 输入电子邮件
    read -p "请输入电子邮件: " email
    screen -S kuzco -X stuff "$email\n"
    sleep 1  # 等待1秒，确保电子邮件已输入

    # 输入密码
    read -sp "请输入密码: " password
    echo  # 打印一个换行符以结束密码输入
    screen -S kuzco -X stuff "$password\n"
    sleep 1  # 等待1秒，确保密码已输入

    # 输入工人名称
    read -p "请输入工人的名称 (例如 'Sam's Laptop'): " worker_name
    screen -S kuzco -X stuff "$worker_name\n"
    sleep 1  # 等待1秒，确保工人名称已输入

    # 选择 "Yes" 选项
    screen -S kuzco -X stuff "\n"  # 按 Enter 键选择 "Yes"
    
    echo "节点初始化完成！"
}

# 查看工作日志的函数
function view_logs() {
    echo "正在查看工作日志..."
    screen -r kuzco
}

# 停止删除节点的函数
function stop_node() {
    echo "正在停止节点..."
    kuzco worker stop
    cd
    rm -rf .kuzco
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 安装、升级并启动节点"
        echo "2) 启动节点"
        echo "3) 查看工作日志"
        echo "4) 停止删除节点"
        echo "5) 退出"

        read -p "请输入选项 [1-5]: " choice

        case $choice in
            1)
                check_systemd
                install_node
                ;;
            2)
                start_node
                ;;
            3)
                view_logs
                ;;
            4)
                stop_node
                ;;
            5)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效的选项，请重新选择。"
                ;;
        esac

        read -p "按 Enter 键返回主菜单..."
    done
}

# 运行主菜单
main_menu
