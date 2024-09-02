url=`cat /etc/apk/repositories|egrep -v "#"|awk -F "/" '{print $3}'|uniq`;for i in $url;do sed -i "s/$i/mirrors.ustc.edu.cn/g" /etc/apk/repositories;done \ 
&& apk --no-cache update \
&& apk --no-cache upgrade \
&& apk --no-cache add bash certbot certbot-dns-cloudflare nginx openssl \
&& mkdir /etc/nginx/conf.d \
&& rm -rf /etc/nginx/http.d/default.conf \
&& rm -rf /var/www/* \
&& rm -rf /var/cache/apk/* 