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

echo "欢迎来到npc客户端";
echo "此客户端适用CentOS6/Debian8/Ubuntu16以上版本"
echo "请选择类型:";
echo "1:安装";
echo "2:卸载";
echo "3:修改配置";
echo "4:退出";

function npc_config()
{
    read -rp "请输入nps服务器IP地址或域名:" ipadd
    read -rp "请输入nps服务器端口号:" port
    read -rp "请输入唯一验证密钥:" vkey
    until [[ $type =~ (tcp|kcp) ]]; do
        read -rp "请选择传输类型(tcp|kcp): " -e type
    done

    chmod 777 /npc -R
    /npc/npc install -server=$ipadd:$port -vkey=$vkey -type=$type
    npc restart 
    echo "-------------";
    echo "配置完成";
    echo "-------------";
}

until [[ $npc =~ (1|2|3|4) ]]; do
    read -rp "请选择要下载的版本: " -e npc
done

if [[ $npc = "1" ]]
    then
        echo "1:npc_x86_64";
        echo "2:npc_x86_32";
        echo "3:npc_arm_64";
        echo "4:npc_arm_32";

        if [ ! -d "/npc" ]; then
            mkdir /npc
        else
            echo "检测到源文件，请选择[y]删除或[n]停止脚本";

            until [[ $rm =~ (y|n) ]]; do
                read -rp "请输入选择: " -e rm
            done

            if [[ $rm = "y" ]]
                then
                    rm -rf /root/linux_amd64_client*
                    rm -rf /root/linux_arm64_client*
                    rm -rf /root/linux_arm_v5_client*
                    rm -rf /usr/bin/npc*
                    /npc/npc stop
                    /npc/npc uninstall
                    rm -rf /npc
                    mkdir /npc

            else
                exit 1
            fi
            echo "卸载完成";
            # 存在则卸载
        fi
        # 判断文件是否存在

        until [[ $CONTINUE =~ (1|2|3|4) ]]; do
                read -rp "请输入1-4选择安装类型: " -e CONTINUE
        done

        echo "----------------";
        echo "1.国内";
        echo "2.海外";
        echo "----------------";

        until [[ $area =~ (1|2) ]]; do
                read -rp "请选择地区: " -e area
        done

        if [[ $area = "1" ]]
            then

                if [[ $CONTINUE = "1" ]]
                    then
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/958009/download/linux_amd64_client.tar.gz
                        tar -zxvf  /root/linux_amd64_client.tar.gz -C /npc
                elif [[ $CONTINUE = "2" ]]
                    then
                        echo "还没更新"
                elif [[ $CONTINUE = "3" ]]
                    then
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/958007/download/linux_arm64_client.tar.gz
                        tar -zxvf  /root/linux_arm64_client.tar.gz -C  /npc
                elif [[ $CONTINUE = "4" ]]
                    then
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/958008/download/linux_arm_v5_client.tar.gz
                        tar -zxvf  /root/linux_arm_v5_client.tar.gz -C  /npc
                else
                    echo "不符合条件，已退出。"
                    exit 1
                fi
                #国内
        elif [[ $area = "2" ]]
            then 
                if [[ $CONTINUE = "1" ]]
                    then
                        wget -P /root/ https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_amd64_client.tar.gz
                        tar -zxvf  /root/linux_amd64_client.tar.gz -C /npc
                elif [[ $CONTINUE = "2" ]]
                    then
                        echo "还没更新"
                elif [[ $CONTINUE = "3" ]]
                    then
                        wget -P /root/ https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_arm64_client.tar.gz
                        tar -zxvf  /root/linux_arm64_client.tar.gz -C  /npc
                elif [[ $CONTINUE = "4" ]]
                    then
                        wget -P /root/ https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_arm_v5_client.tar.gz
                        tar -zxvf  /root/linux_arm_v5_client.tar.gz -C  /npc
                else
                    echo "不符合条件，已退出。."
                    exit 1
                fi
            else
                echo "输入错误";
            fi
                #国外
        # 判断选择类型
        npc_config;


        # npc配置文件
elif [[ $npc = "2" ]]
    then
        until [[ $uninstall =~ (y|n) ]]; do
                read -rp "请输入(y|n)选择卸载: " -e uninstall
        done

        if [[ $uninstall = "y" ]]
            then
                rm -rf /root/linux_amd64_client*
                rm -rf /root/linux_arm64_client*
                rm -rf /root/linux_arm_v5_client*
                rm -rf /usr/bin/npc*
                /npc/npc stop
                /npc/npc uninstall
                rm -rf /npc

                echo "卸载完成";
        elif [[ $uninstall = "n" ]]
            then
                echo "exiting";
                exit 1    
        else
            echo "exiting";
            exit 1
        fi
        # 卸载npc相关文件

elif [[ $npc = "3" ]]
    then
        if [ ! -d "/npc" ]; then
            echo "未检测到 /npc 下安装 npc，请重新运行此脚本";
            exit 1
        else
            npc_config;
        fi
        # 修改配置文件
elif [[ $npc = "4" ]]
    then
        echo "Exit!"
        exit 1
else
    echo "不符合条件，退出.";
    exit 1
fi
# 选择不同操作
