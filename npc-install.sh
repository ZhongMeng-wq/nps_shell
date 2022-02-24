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

function read_server()
{
    cat_npc_server=$(cat /npc/conf/npc.conf | grep "server_addr")
    cat_npc_server_o="服务器地址与端口：${cat_npc_server/server_addr=/}"

    cat_npc_key=$(cat /npc/conf/npc.conf | grep "vkey")
    cat_npc_key_o="密钥：${cat_npc_key/vkey=/}"

    cat_npc_type=$(cat /npc/conf/npc.conf | grep "conn_type")
    cat_npc_type_o="协议：${cat_npc_type/conn_type=/}"

    cat_npc_web_user=$(cat /npc/conf/npc.conf | grep "web_username")
    cat_npc_web_user_o="客户端web用户名:${cat_npc_web_user/web_username=/}"

    cat_npc_web_pass=$(cat /npc/conf/npc.conf | grep "web_password")
    cat_npc_web_pass_o="客户端web密码:${cat_npc_web_pass/web_password=/}"

    key_aaa_port=${cat_npc_key/vkey=/}
}
#读配置文件

function server_config()
{
    read_server
    #读取桥配置文件
    echo "----------------------------------------"
    echo "1.读取桥通信配置"
    echo "2.修改桥通信配置"
    echo "----------------------------------------"

    read -rp "请输入选择:" -e server_number
    echo "----------------------------------------"
    if [[ $server_number = "1" ]]
    then
        read_server
        echo $cat_npc_server_o
        echo $cat_npc_key_o
        echo $cat_npc_type_o
        if [[ ${cat_npc_web_user/web_username=/} != "#" ]] 
        then
            echo $cat_npc_web_user_o
        fi

        if [[ ${cat_npc_web_pass/web_password=/} != "#" ]] 
        then
            echo $cat_npc_web_pass_o
        fi
        echo "----------------------------------------"
    elif [[ $server_number = "2" ]]
    then
        read -rp "请输入服务器地址和端口号(例:127.0.0.1:80)：" -e server
        read -rp "请输入服务器唯一密钥:" -e server_key
        until [[ $npc_type =~ (tcp|kcp) ]]; do
            read -rp "请选择服务器端通信传输协议类型(tcp|kcp): " -e npc_type
        done

        until [[ $web_aaa =~ (y|n) ]]; do
            read -rp "是否需要配置web认证用户(y|n): " -e web_aaa
        done
        if [[ $web_aaa = "y" ]]
        then
            read -rp "请输入web端用户名:" -e web_user
            read -rp "请输入web端密码:" -e web_pass
        fi

        echo "----------------------------------------"
        echo "正在写入......"
        read_server

        sed -i "s/$cat_npc_server/server_addr=$server/g" `grep -rl "$cat_npc_server" /npc/conf/npc.conf`
        sed -i "s/$cat_npc_key/vkey=$server_key/g" `grep -rl "$cat_npc_key" /npc/conf/npc.conf`
        sed -i "s/$cat_npc_type/conn_type=$npc_type/g" `grep -rl "$cat_npc_type" /npc/conf/npc.conf`
        if [[ $web_aaa = "y" ]]
        then
            sed -i "s/$cat_npc_web_user/web_username=$web_user/g" `grep -rl "$cat_npc_web_user" /npc/conf/npc.conf`
            sed -i "s/$cat_npc_web_pass/web_password=$web_pass/g" `grep -rl "$cat_npc_web_pass" /npc/conf/npc.conf`
        else
            sed -i "s/$cat_npc_web_user/#web_username=/g" `grep -rl "$cat_npc_web_user" /npc/conf/npc.conf`
            sed -i "s/$cat_npc_web_pass/#web_password=/g" `grep -rl "$cat_npc_web_pass" /npc/conf/npc.conf`      
        fi
        read_server
        echo "完成"
        echo "----------------------------------------"
        echo $cat_npc_server_o
        echo $cat_npc_key_o
        echo $cat_npc_type_o
        if [[ ${cat_npc_web_user/web_username=/} != "#" ]] 
        then
            echo $cat_npc_web_user_o
        fi

        if [[ ${cat_npc_web_pass/web_password=/} != "#" ]] 
        then
            echo $cat_npc_web_pass_o
        fi
        echo "--------------------------------------"
    else
        echo "输入有误"
    fi

}
#写入桥配置

echo "欢迎来到npc客户端2.0";
echo "此次改为配置文件方式运行"
echo "此客户端适用CentOS6/Debian8/Ubuntu16以上版本"
echo "请选择类型:";
echo "1:安装";
echo "2:卸载";
echo "3:退出";

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
                    rm -rf /usr/bin/autonpc
                    /npc/npc stop
                    /npc/npc uninstall
                    rm -rf /npc

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
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/977545/download/linux_amd64_client.tar.gz
                        tar -zxvf  /root/linux_amd64_client.tar.gz -C /npc
                elif [[ $CONTINUE = "2" ]]
                    then
                        echo "还没更新"
                elif [[ $CONTINUE = "3" ]]
                    then
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/977544/download/linux_arm64_client.tar.gz
                        tar -zxvf  /root/linux_arm64_client.tar.gz -C  /npc
                elif [[ $CONTINUE = "4" ]]
                    then
                        wget -P /root/ https://gitee.com/zhang20021230/nps-domestic-package/attach_files/977546/download/linux_arm_v5_client.tar.gz
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
        wget -P /usr/bin/ http://nps.loline.top/shell/fx/autonpc

        rm -rf /npc/conf/npc.conf
        touch /npc/conf/npc.conf
        
        echo "#--common--" >> /npc/conf/npc.conf
        echo "[common]" >> /npc/conf/npc.conf
        echo "server_addr=" >> /npc/conf/npc.conf
        echo "conn_type=" >> /npc/conf/npc.conf
        echo "vkey=" >> /npc/conf/npc.conf
        echo "#web_username=" >> /npc/conf/npc.conf
        echo "#web_password=" >> /npc/conf/npc.conf
        echo "#--common--" >> /npc/conf/npc.conf

        

        read -rp "请输入服务器地址和端口号(例:127.0.0.1:80)：" -e server
        read -rp "请输入服务器唯一密钥:" -e server_key
        until [[ $npc_type =~ (tcp|kcp) ]]; do
            read -rp "请选择服务器端通信传输协议类型(tcp|kcp): " -e npc_type
        done

        until [[ $web_aaa =~ (y|n) ]]; do
            read -rp "是否需要配置web认证用户(y|n): " -e web_aaa
        done
        if [[ $web_aaa = "y" ]]
        then
            read -rp "请输入web端用户名:" -e web_user
            read -rp "请输入web端密码:" -e web_pass
        fi

        echo "----------------------------------------"
        echo "正在写入......"
        read_server

        sed -i "s/$cat_npc_server/server_addr=$server/g" `grep -rl "$cat_npc_server" /npc/conf/npc.conf`
        sed -i "s/$cat_npc_key/vkey=$server_key/g" `grep -rl "$cat_npc_key" /npc/conf/npc.conf`
        sed -i "s/$cat_npc_type/conn_type=$npc_type/g" `grep -rl "$cat_npc_type" /npc/conf/npc.conf`
        if [[ $web_aaa = "y" ]]
        then
            sed -i "s/$cat_npc_web_user/web_username=$web_user/g" `grep -rl "$cat_npc_web_user" /npc/conf/npc.conf`
            sed -i "s/$cat_npc_web_pass/web_password=$web_pass/g" `grep -rl "$cat_npc_web_pass" /npc/conf/npc.conf`
        else
            sed -i "s/$cat_npc_web_user/#web_username=/g" `grep -rl "$cat_npc_web_user" /npc/conf/npc.conf`
            sed -i "s/$cat_npc_web_pass/#web_password=/g" `grep -rl "$cat_npc_web_pass" /npc/conf/npc.conf`      
        fi
        read_server
        echo "完成"
        echo "----------------------------------------"
        echo $cat_npc_server_o
        echo $cat_npc_key_o
        echo $cat_npc_type_o
        if [[ ${cat_npc_web_user/web_username=/} != "#" ]] 
        then
            echo $cat_npc_web_user_o
        fi

        if [[ ${cat_npc_web_pass/web_password=/} != "#" ]] 
        then
            echo $cat_npc_web_pass_o
        fi
        echo "--------------------------------------"



        chmod 777 /usr/bin/autonpc
        /npc/npc install -config=/npc/conf/npc.conf
        npc restart -config=/npc/conf/npc.conf
        echo "安装完成，请通过autonpc命令进入面板"
        read -rp "输入任意键退出:" -e ry

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
                rm -rf /usr/bin/autonpc
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
        exit 1
else
    echo "不符合条件，退出.";
    exit 1
fi
# 选择不同操作
