#!/bin/bash
echo "********************Script written by wxy**********************"
echo "vpn test，docker-ce(Logging=journald),docker-compose"
ping -c 1 10.2.10.1 >>/dev/null 2>&1
if [ $? -eq 0 ];then
	echo "vpn success!"
else
	echo "vpn fail!"
fi
read -p "centos7?(yes or no)" a
if [ $a = yes ];then	
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_back >>/dev/null 2>&1
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >>/dev/null 2>&1
	if [ $? -ne 0 ];then
		sudo yum clean all >>/dev/null 2>&1
		sudo yum makecachesudo >>/dev/null 2>&1
		if [ $? -eq 0 ];then
        		echo "Mirror source replaced!!"
		else
			echo "Mirror source replaced error!"
        	fi
	fi
	echo "install docker-ce......"
	sudo yum install -y epel-release yum-utils device-mapper-persistent-data lvm2 curl wget unzip vim mtr tcpdump net-tools  >>/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "-----------[1/6]"
		sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo  >>/dev/null 2>&1
		if [ $? -eq 0 ];then
			echo "-----------[2/6]"
			sudo yum makecache fast >>/dev/null 2>&1
			if [ $? -eq 0 ];then
				echo "-----------[3/6]"
				sudo yum list docker-ce --showduplicates|sort -r >>/dev/null 2>&1
				if [ $? -eq 0 ];then
					echo "-----------[4/6]"
					sudo yum install docker >>/dev/null 2>&1
					if [ $? -eq 0 ];then
						echo "-----------[5/6]"
						systemctl enable docker >>/dev/null 2>&1
						if [ $? -eq 0 ];then
							echo -e "-----------[6/6]\n docker-ce install success!"
						fi
					else
						exit
					fi
				else
					exit
				fi
			else
				exit
			fi
		else
			exit
		fi
	else
		echo "first one yum install error"
		exit
	fi
	
	echo "change docker usergroup"
	docker info >>/dev/null 2>&1
	if [ $? -eq 0];then
		sudo usermod -a -G docker genee >>/dev/null 2>&1
		newgrp docker >>/dev/null 2>&1
		echo "change docker usergroup success!!"
	else
		echo "error"
		exit
	fi
	echo "install  daemon.json"
	echo '{
        "log-driver": "journald",
        "bip":"172.17.42.1/24",
        "dns":[
                "172.17.42.1",
                "114.114.114.114"],
        "registry-mirrors":[
                "https://reg-mirror.qiniu.com",
                "https://hub-mirror.c.163.com",
                "https://registry.aliyuncs.com"]
}' > /etc/docker/daemon.json
	echo "daemon success!"
	echo "install docker-compose....."
	sudo curl -L https://github.com/docker/compose/releases/download/2.2.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >>/dev/null 2>&1
	if [ $? -eq 0 ];then
		sudo chmod +x /usr/local/bin/docker-compose
		echo "install docker-compose success!"
	else
       		echo "install docker-compose fail1"
	fi
	docker info | sed -n '15p;21p'
	docker-compose -v

fi
