/etc/docker/daemon.json 
{
	"insecure-registries":["192.168.100.239:5000"]  # 括号内增加这一行
}

 systemctl daemon-reload
 systemctl restart docker

curl http://192.168.100.239:5000/v2/_catalog
curl http://192.168.100.239:5000/v2/mysql/tags/list

curl http://192.168.100.239/registry/v2/_catalog
curl http://192.168.100.239/registry/v2/mysql/tags/list