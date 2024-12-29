if [ ! -d /data/softether ];then
mkdir -p /data/softether
fi

cat << EOF > /data/softether/docker-compose.yaml
services:
  softether:
    image: softethervpn/vpnserver:stable
    container_name: softether
    cap_add:
      - NET_ADMIN
    restart: always
    ports:
      - 53:53
      - 4430:443
      - 992:992
      - 1194:1194/udp
      - 5555:5555
      - 500:500/udp
      - 4500:4500/udp
      - 1701:1701/udp
    volumes:
      - "/etc/localtime:/etc/localtime:ro"
      - "/etc/timezone:/etc/timezone:ro"
      - "./softether_data:/mnt"
      - "./softether_log:/root/server_log"
      - "./softether_packetlog:/root/packet_log"
      - "./softether_securitylog:/root/security_log"
      # - "./adminip.txt:/usr/local/bin/adminip.txt:ro"
EOF
cd /data/softether && docker-compose up -d

###################################################################

https://198.18.200.119:5555/ 默认用户名和密码是空

docker exec -it softether vpncmd

vpncmd command - SoftEther VPN Command Line Management Utility
SoftEther VPN Command Line Management Utility (vpncmd command)
Version 4.41 Build 9787   (English)
Compiled 2023/03/14 10:40:41 by buildsan at crosswin with OpenSSL 3.1.4
Copyright (c) 2012-2023 SoftEther VPN Project. All Rights Reserved.

By using vpncmd program, the following can be achieved. 

1. Management of VPN Server or VPN Bridge 
2. Management of VPN Client
3. Use of VPN Tools (certificate creation and Network Traffic Speed Test Tool)

Select 1, 2 or 3: 1

Specify the host name or IP address of the computer that the destination VPN Server or VPN Bridge is operating on. 
By specifying according to the format 'host name:port number', you can also specify the port number. 
(When the port number is unspecified, 443 is used.)
If nothing is input and the Enter key is pressed, the connection will be made to the port number 8888 of localhost (this computer).
Hostname of IP Address of Destination: 127.0.0.1

If connecting to the server by Virtual Hub Admin Mode, please input the Virtual Hub name. 
If connecting by server admin mode, please press Enter without inputting anything.
Specify Virtual Hub Name: 
Connection has been established with VPN Server "127.0.0.1" (port 443).

You have administrator privileges for the entire VPN Server.
#1.密码
VPN Server>ServerPasswordSet
ServerPasswordSet command - Set VPN Server Administrator Password
Please enter the password. To cancel press the Ctrl+D key.

Password: *********
Confirm input: *********


The command completed successfully.
#.查看hub
VPN Server>hublist
HubList command - Get List of Virtual Hubs
Item              |Value
------------------+-------------------
Virtual Hub Name  |DEFAULT
Status            |Online
Type              |Standalone
Users             |0
Groups            |0
Sessions          |0
MAC Tables        |0
IP Tables         |0
Num Logins        |0
Last Login        |2024-12-27 14:51:55
Last Communication|2024-12-27 14:51:55
Transfer Bytes    |0
Transfer Packets  |0
The command completed successfully.
#删除默认hub
VPN Server>hubdelete DEFAULT
HubDelete command - Delete Virtual Hub
The command completed successfully.

VPN Server>hublist
HubList command - Get List of Virtual Hubs
Item|Value
----+-----
The command completed successfully.
#创建新hub
VPN Server>hubcreate hub0
HubCreate command - Create New Virtual Hub
Please enter the password. To cancel press the Ctrl+D key.

Password: *********
Confirm input: *********


The command completed successfully.


VPN Server>hublist
HubList command - Get List of Virtual Hubs
Item              |Value
------------------+-------------------
Virtual Hub Name  |hub0
Status            |Online
Type              |Standalone
Users             |0
Groups            |0
Sessions          |0
MAC Tables        |0
IP Tables         |0
Num Logins        |0
Last Login        |2024-12-27 15:08:06
Last Communication|2024-12-27 15:08:06
Transfer Bytes    |0
Transfer Packets  |0
The command completed successfully.

#连接hub
VPN Server>hub hub0
Hub command - Select Virtual Hub to Manage
The Virtual Hub "hub0" has been selected.
The command completed successfully.

#创建用户
VPN Server/hub0>usercreate hub0-user1
UserCreate command - Create User 
Assigned Group Name: 

User Full Name: 

User Description: 

The command completed successfully.

VPN Server/hub0>userpasswordset hub0-user1
UserPasswordSet command - Set Password Authentication for User Auth Type and Set Password
Please enter the password. To cancel press the Ctrl+D key.

Password: ********
Confirm input: ********


The command completed successfully.



