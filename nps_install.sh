#!/bin/bash
if ! [ -x "$(command -v wget)" ]; then
    yuan=$(cat /etc/redhat-release)
    if [[ $yuan =~ "CentOS" ]]
    then
        yum install wget -y
    else
        apt update
        apt install wget -y
    fi
fi
#检测是否安装wget

echo "-----------------------------------------------------------"
echo "欢迎使用nps服务器一键安装脚本";
echo "此配置为基础配置,详细请编辑/etc/nps/conf/nps.conf文件"
echo "此客户端适用CentOS6/Debian8/Ubuntu16以上版本,依赖wget，请确保安装wget"
echo "成功安装后，你可以通过autonps命令来执行脚本"
echo "请选择类型:";
echo "1:安装";
echo "2:卸载";
echo "3:配置";
echo "4:退出";
echo "-----------------------------------------------------------"

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
server_ip="此服务器IP地址是$IP"
hainei=(https://gitee.com/zhang20021230/nps-domestic-package/attach_files/967435/download/linux_amd64_server.tar.gz https://gitee.com/zhang20021230/nps-domestic-package/attach_files/967437/download/linux_arm64_server.tar.gz https://gitee.com/zhang20021230/nps-domestic-package/attach_files/967436/download/linux_arm_v5_server.tar.gz)
haiwai=(https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_amd64_server.tar.gz https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_arm64_server.tar.gz https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_arm_v5_server.tar.gz)
#IP参数和链接

function out_config()
{

    echo $cat_nps_type_o
    echo $cat_nps_port_o
    echo "-------------------------桥参数----------------------------"
    echo $cat_nps_user_o
    echo $cat_nps_pass_o
    echo $cat_nps_web_o
    echo "-----------------------Web管理页面-------------------------"
    echo $cat_nps_users_o
    echo $cat_nps_register_o
    echo $cat_nps_user_name_o
    echo "------------------------多用户参数--------------------------"
    echo $server_ip
}
#输出参数

function cat_config()
{
    cat_nps_type=$(cat /etc/nps/conf/nps.conf | grep "bridge_type")
    cat_nps_type_o="客户端传输协议${cat_nps_type/bridge_type/}"
    #读取传输协议

    cat_nps_port=$(cat /etc/nps/conf/nps.conf | grep "bridge_port")
    cat_nps_port_o="客户端传输端口${cat_nps_port/bridge_port/}"
    #读取端口

    cat_nps_user=$(cat /etc/nps/conf/nps.conf | grep "web_username")
    cat_nps_user_o="管理页面用户名${cat_nps_user/web_username/}"
    #读取用户

    cat_nps_pass=$(cat /etc/nps/conf/nps.conf | grep "web_password")
    cat_nps_pass_o="管理页面密码${cat_nps_pass/web_password/}"
    #读取密码

    cat_nps_web=$(cat /etc/nps/conf/nps.conf | grep "web_port")
    cat_nps_web_o="管理页面端口${cat_nps_web/web_port/}"
    #读取管理端口

    cat_nps_users=$(cat /etc/nps/conf/nps.conf | grep "allow_user_login")
    cat_nps_users_o="管理页面多用户${cat_nps_users/allow_user_login/}"
    #读取是否开启多用户

    cat_nps_register=$(cat /etc/nps/conf/nps.conf | grep "allow_user_register")
    cat_nps_register_o="管理页面开放注册${cat_nps_register/allow_user_register/}"
    #读取是否开启注册

    cat_nps_user_name=$(cat /etc/nps/conf/nps.conf | grep "allow_user_change_username")
    cat_nps_user_name_o="管理页面允许用户修改用户名${cat_nps_user_name/allow_user_change_username/}"
    #读取是否允许用户修改用户名
}
#读取配置

function nps_config()
{   
    echo "1.查询"
    echo "2.修改"
    echo "-----------------------------------------------------------"

    read -rp "请输入:" -e conf_r_w

    if [[ $conf_r_w = "1" ]]
    then
        cat_config

        out_config
    elif [[ $conf_r_w = "2" ]]
    then
        cat_config
        until [[ $nps_type =~ (tcp|kcp) ]]; do
            read -rp "1.请选择服务器端通信传输协议类型(tcp|kcp): " -e nps_type
        done

        until [[ $nps_user =~ (true|false) ]]; do
            read -rp "1.是否允许多用户登录[y|n]: " -e nps_user
            if [[ $nps_user = "y" ]]
            then
                nps_user="true"
            elif [[ $nps_user = "n" ]]
            then
                nps_user="false"
            else
                nps_user="false"
            fi
        done

        until [[ $nps_useradd =~ (true|false) ]]; do
            read -rp "1.是否允许多用户注册[y|n]: " -e nps_useradd

            if [[ $nps_useradd = "y" ]]
            then
                nps_useradd="true"
            elif [[ $nps_useradd = "n" ]]
            then
                nps_useradd="false"
            else
                nps_useradd="false"
            fi
        done

        until [[ $nps_username =~ (true|false) ]]; do
            read -rp "1.是否允许用户可自行修改用户名[y|n]: " -e nps_username

            if [[ $nps_username = "y" ]]
            then
                nps_username="true"
            elif [[ $nps_username = "n" ]]
            then
                nps_username="false"
            else
                nps_username="false"
            fi
        done

        read -rp "2.请选择服务器端通信传输端口: " -e nps_port
        read -rp "3.web管理平台账号:" -e web_user
        read -rp "4.web管理平台密码:" -e web_pass
        read -rp "5.web管理平台端口:" -e web_port

        until [[ $right =~ (y|n) ]]; do
            read -rp "是否确认(y|n): " -e right
        done

        echo "-----------------------------------------------------------"

        if [[ $right = "y" ]]
        then

            sed -i "s/$cat_nps_type/bridge_type=$nps_type/g" `grep -rl "$cat_nps_type" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_users/allow_user_login=$nps_user/g" `grep -rl "$cat_nps_users" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_register/allow_user_register=$nps_useradd/g" `grep -rl "$cat_nps_register" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_user_name/allow_user_change_username=$nps_username/g" `grep -rl "$cat_nps_user_name" /etc/nps/conf/nps.conf`

            sed -i "s/$cat_nps_port/bridge_port=$nps_port/g" `grep -rl "$cat_nps_port" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_user/web_username=$web_user/g" `grep -rl "$cat_nps_user" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_pass/web_password=$web_pass/g" `grep -rl "$cat_nps_pass" /etc/nps/conf/nps.conf`
            sed -i "s/$cat_nps_web/web_port=$web_port/g" `grep -rl "$cat_nps_web" /etc/nps/conf/nps.conf`

            nps restart
            cat_config

            out_config

        elif [[ $right = "n" ]]
        then
            echo "已终止"
        else
            echo "输入错误"
        fi
    else
        echo "输入有误"
    fi
}
#配置

function nps_uninstall()
{
    nps stop
    nps uninstall
    rm -rf /opt/nps
    rm -rf /etc/nps
    rm -rf /usr/bin/autonps
    rm -rf /usr/bin/nps
    rm -rf /usr/bin/nps-update
}
#删除

read -rp "请输入选择:" -e xuanze

if [[ $xuanze = "1" ]]
then
    if [ ! -d "/etc/nps" ]; then
        echo "准备安装"
        mkdir -P /opt/nps/
    else
        echo "检测到源文件，请选择[y]删除或[n]停止脚本";
        
        until [[ $rm =~ (y|n) ]]; do
            read -rp "请输入选择: " -e rm
        done

        if [[ $rm = "y" ]]
        then
            nps_uninstall

            echo "卸载完成"
            echo "-----------------------------------------------------------"
        else
            exit 1
        # 存在则卸载
        fi
    fi
    # 判断文件是否存在

    echo "1:nps_x86_64";
    echo "2:nps_arm_64";
    echo "3:nps_arm_v5";

    read -rp "选择版本:" -e banben

    echo "1.国内"
    echo "2.海外"
    echo "-----------------------------------------------------------"
    until [[ $area =~ (1|2) ]]; do
        read -rp "选择地区: " -e area
    done
    echo "-----------------------------------------------------------"

    if [[ $area = "1" ]]
    then
        if [[ $banben = "1" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${hainei[0]}
            tar -zxvf  /opt/nps/linux_amd64_server.tar.gz -C /opt/nps/
        elif [[ $banben = "2" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${hainei[1]}
            tar -zxvf  /opt/nps/linux_arm64_server.tar.gz -C /opt/nps/
        elif [[ $banben = "3" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${hainei[2]}
            tar -zxvf  /opt/nps/linux_arm_v5_server.tar.gz -C /opt/nps/
        else
            echo "未找到版本"
        fi

        /opt/nps/nps install
        echo "-----------------------------------------------------------"
        echo "请修改默认配置"
        echo "-----------------------------------------------------------"
        nps_config
    elif [[ $area = "2" ]]
    then
        if [[ $banben = "1" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${haiwai[0]}
            tar -zxvf  /opt/nps/linux_amd64_server.tar.gz -C /opt/nps/
        elif [[ $banben = "2" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${haiwai[1]}
            tar -zxvf  /opt/nps/linux_arm64_server.tar.gz -C /opt/nps/
        elif [[ $banben = "3" ]]
        then
            mkdir -p /opt/nps
            wget -P /opt/nps ${haiwai[2]}
            tar -zxvf  /opt/nps/linux_arm_v5_server.tar.gz -C /opt/nps/
        else
            echo "未找到版本"
        fi

        /opt/nps/nps install
        echo "-----------------------------------------------------------"
        echo "请修改默认配置"
        echo "-----------------------------------------------------------"
        nps_config
    else
        exit 1
    fi

    BASE_PATH=$(cd `dirname $0`;pwd)
    cp "$BASE_PATH/nps_install.sh" /usr/bin/autonps
    chmod 777 /usr/bin/autonps

    echo "安装完成，你可以通过autonps命令来执行脚本"
    echo "-----------------------------------------------------------"
elif [[ $xuanze = "2" ]]
then
    until [[ $rm =~ (y|n) ]]; do
        read -rp "是否卸载nps内网穿透[y|n]: " -e rm
    done

    if [[ $rm = "y" ]]
    then
        nps_uninstall
    else
        exit 1
    # 存在则卸载
    fi
    # 判断文件是否存在
elif [[ $xuanze = "3" ]]
then
    if [ ! -d "/etc/nps/" ]; 
    then
        echo "未检测到 /etc/nps/ 下安装 nps，请重新运行此脚本并安装";
        exit 1
    else
        nps_config
    fi
elif [[ $xuanze = "4" ]]
then
    exit 1
else
    echo "错误"
    exit 1
fi
bash
