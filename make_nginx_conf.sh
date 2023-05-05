#!/bin/bash
# author:波哥（IT运维技术圈）
# 检查参数个数
if [ $# -lt 1 ]; then
  echo "Usage: $0 <domain> [no]"
  exit 1
fi

# 参数定义
domain=$1
base_path=/usr/local/openresty/nginx
overwrite=${2:-yes}  # 第二个参数默认为yes
config_path=${base_path}/conf
ssl_cert_path=${base_path}/ssl
access_log_path=${base_path}/log
error_log_path=${base_path}/log

# 获取域名的二级域名和一级域名
domain_name=$(echo $domain | awk -F. '{print $(NF-1)"."$NF}')
# 拼接生成 ssl_cert_file 和 ssl_key_file
ssl_cert_file="${domain_name}.crt"
ssl_key_file="${domain_name}.key"


# 配置文件名
config_file=${domain}.conf

# 检查是否存在同名文件
if [ -f "${config_path}/${config_file}" ] && [ "$overwrite" = "no" ]; then
  read -p "The configuration file already exists. Do you want to overwrite it? (yes/no)" choice
  case "$choice" in
    y|Y|yes|Yes|YES )
      ;;
    * )
      echo "Script aborted"
      exit 0
      ;;
  esac
fi

# 生成配置文件
cat > "${config_path}/${config_file}" <<EOF
server {
    listen 80;
    server_name ${domain};
    return 301 https://${domain}\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${domain};

    ssl_certificate     ${ssl_cert_path}/${ssl_cert_file};
    ssl_certificate_key ${ssl_cert_path}/${ssl_key_file};

    access_log ${access_log_path}/${domain}.log misc;
    error_log ${error_log_path}/${domain}.log;

    location / {
        # your logic
    }
}
EOF

echo "Configuration file generated: ${config_path}/${config_file}"

# ./creat_nginx.sh www.test.com no 