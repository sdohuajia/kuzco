#!/bin/bash

# 脚本保存路径（如果需要使用，可以启用）
SCRIPT_PATH="$HOME/kuzco.sh"

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
        apt update -y
        apt install screen -y
    fi
}

# 检查并安装 curl 的函数
function check_and_install_curl() {
    if command -v curl >/dev/null 2>&1; then
        echo "curl 已经安装。"
    else
        echo "curl 未安装，正在安装..."
        apt update -y
        apt install curl -y
    fi
}

# 安装节点的函数
function install_node() {
    echo "正在更新软件包列表..."
    apt update -y

    echo "正在升级软件包..."
    apt upgrade -y

    echo "正在清理不再需要的软件包..."
    apt autoremove -y
    apt autoclean

    echo "检查并安装 screen..."
    check_and_install_screen

    echo "检查并安装 curl..."
    check_and_install_curl

    echo "正在执行远程安装脚本..."
    if ! curl -fsSL https://kuzco.xyz/install.sh | sh; then
        echo "远程安装脚本执行失败。"
        exit 1
    fi

    echo "正在执行远程升级脚本..."
    if ! curl -fsSL https://kuzco.xyz/upgrade.sh | sh; then
        echo "远程升级脚本执行失败。"
        exit 1
    fi

    echo "节点安装和升级完成！"
}

# 初始化并启动节点的函数
function init_and_start_node() {
    echo "正在初始化 Kuzco..."
    if ! kuzco init; then
        echo "Kuzco 初始化失败。"
        exit 1
    fi

    read -p "请输入 worker 名称: " worker
    read -p "请输入 code: " code

    echo "正在启动节点..."
    if kuzco worker start --background --worker "$worker" --code "$code"; then
        echo "节点已启动。"
    else
        echo "节点启动失败。"
        exit 1
    fi
}

# 检查工作状态的函数
function check_status() {
    echo "正在检查 Kuzco 工作的状态..."
    kuzco worker status
}

# 查看工作日志的函数
function view_logs() {
    echo "正在查看工作日志..."
    kuzco worker logs
}

# 停止删除节点的函数
function stop_node() {
    echo "正在停止节点..."
    kuzco worker stop
    read -p "确认删除 .kuzco 目录？此操作不可恢复 (y/n): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.kuzco"
        echo ".kuzco 目录已删除。"
    else
        echo "删除操作已取消。"
    fi
}

# 重启节点的函数
function restart_node() {
    echo "正在重启节点..."
    kuzco worker restart
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 安装、升级节点"
        echo "2) 初始化并启动节点"
        echo "3) 检查 Kuzco 工作状态"
        echo "4) 查看工作日志"
        echo "5) 停止并删除节点"
        echo "6) 重启节点"
        echo "7) 退出"

        read -p "请输入选项 [1-7]: " choice

        case $choice in
            1)
                install_node
                ;;
            2)
                check_systemd
                init_and_start_node
                ;;
            3)
                check_status
                ;;
            4)
                view_logs
                ;;
            5)
                stop_node
                ;;
            6)
                restart_node
                ;;
            7)
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
