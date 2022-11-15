install_depend() {
   for i in "perl autoconf automake libtool curl-devel pcre-devel openssl-devel zlib-devel gcc-c++ unzip ipset python-devel curl wget ntpdate"
   do
     rpm -q $i &> /dev/null || yum install $i -y 2&>/dev/null 
   done

    \cp -rp ${WORD_DIR}/epel.repo /etc/yum.repos.d/

    yum install -y python-pip 2&>/dev/null || true
    if [[ `yum list installed  | grep python2-pip` == "" ]]; then
        sed -i 's#mirrors.aliyun.com#mirrors.tuna.tsinghua.edu.cn#' /etc/yum.repos.d/epel.repo
        yum install -y python-pip 2&>/dev/null
    fi


   
}


sync_time(){
    /usr/sbin/ntpdate -u pool.ntp.org  || true
    ! grep -q "/usr/sbin/ntpdate -u pool.ntp.org" /var/spool/cron/root > /dev/null 2>&1 && echo '*/10 * * * * /usr/sbin/ntpdate -u pool.ntp.org > /dev/null 2>&1 || (date_str=`curl -s update.cdnwaf.cn/common/datetime` && timedatectl set-ntp false && echo $date_str && timedatectl set-time "$date_str" )' >> /var/spool/cron/root
    
    ! grep -q "wget http://geolite.maxmind.com" /var/spool/cron/root > /dev/null 2>&1 && echo "01 01 01 * 01 wget 'https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=Z0TctMxsLgJPPQzi&suffix=tar.gz' -O /opt/geoip/GeoLite2-Country.mmdb.gz -O /opt/geoip/GeoLite2-Country.mmdb.gz;gunzip -f /opt/geoip/GeoLite2-Country.mmdb.gz" >> /var/spool/cron/root

    service crond restart  2>/dev/null

    # 时区
    rm -f /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    if /sbin/hwclock -w;then
        return
    fi
    

}




# 开始安装
install_geoip() {
    tar xf ${WORD_DIR}/cdnfly-agent-v5.1.16-centos-7.tar.gz -C  /opt
    cd /opt && rm -rf cdnfly
    mv cdnfly-agent-v5.1.16  cdnfly

    mkdir -p /opt/geoip && \cp -rp ${WORD_DIR}/GeoLite2-Country.mmdb /opt/geoip
}



# 安装pip模块
install_pip_module() {
    cd ${WORD_DIR}
    tar xf pymodule-agent-20211114.tar.gz
    cd pymodule-agent-20211114

    # 系统环境安装
    ## pip
    pip install pip-20.1.1-py2.py3-none-any.whl
    ## setuptools
    pip install setuptools-30.1.0-py2.py3-none-any.whl
    ## supervisor
    pip install supervisor-4.2.0-py2.py3-none-any.whl
    ## virtualenv
    pip install configparser-4.0.2-py2.py3-none-any.whl
    pip install scandir-1.10.0.tar.gz
    pip install typing-3.7.4.1-py2-none-any.whl
    pip install contextlib2-0.6.0.post1-py2.py3-none-any.whl
    pip install zipp-1.2.0-py2.py3-none-any.whl
    pip install six-1.15.0-py2.py3-none-any.whl
    pip install singledispatch-3.4.0.3-py2.py3-none-any.whl
    pip install distlib-0.3.0.zip
    pip install pathlib2-2.3.5-py2.py3-none-any.whl
    pip install importlib_metadata-1.6.1-py2.py3-none-any.whl
    pip install appdirs-1.4.4-py2.py3-none-any.whl
    pip install filelock-3.0.12.tar.gz
    pip install importlib_resources-2.0.1-py2.py3-none-any.whl
    pip install virtualenv-20.0.25-py2.py3-none-any.whl

    # 创建虚拟环境
    cd /opt
    python -m virtualenv -vv --extra-search-dir /tmp/.cdnwaf/pymodule-agent-20211114 --no-download --no-periodic-update venv
    ## 激活环境
    source /opt/venv/bin/activate

    # 虚拟环境安装
    cd /tmp/.cdnwaf/pymodule-agent-20211114

    ## Flask
    pip install click-7.1.2-py2.py3-none-any.whl
    pip install itsdangerous-1.1.0-py2.py3-none-any.whl
    pip install Werkzeug-1.0.1-py2.py3-none-any.whl
    pip install MarkupSafe-1.1.1-cp27-cp27mu-manylinux1_x86_64.whl
    pip install Jinja2-2.11.2-py2.py3-none-any.whl
    pip install Flask-1.1.1-py2.py3-none-any.whl
    ## psutil
    #pip install psutil-5.7.0.tar.gz
    pip install psutil-5.8.0-cp27-cp27mu-manylinux2010_x86_64.whl
    ## bcrypt
    pip install pycparser-2.20-py2.py3-none-any.whl
    pip install cffi-1.14.0-cp27-cp27mu-manylinux1_x86_64.whl
    pip install six-1.15.0-py2.py3-none-any.whl
    pip install bcrypt-3.1.7-cp27-cp27mu-manylinux1_x86_64.whl
    ## requests
    pip install certifi-2020.4.5.2-py2.py3-none-any.whl
    pip install idna-2.9-py2.py3-none-any.whl
    pip install chardet-3.0.4-py2.py3-none-any.whl
    pip install urllib3-1.25.9-py2.py3-none-any.whl
    pip install requests-2.24.0-py2.py3-none-any.whl
    ## requests_unixsocket
    pip install requests_unixsocket-0.2.0-py2.py3-none-any.whl
    ## pyOpenSSL
    pip install ipaddress-1.0.23-py2.py3-none-any.whl
    pip install enum34-1.1.10-py2-none-any.whl
    pip install cryptography-2.9.2-cp27-cp27mu-manylinux2010_x86_64.whl
    pip install pyOpenSSL-19.1.0-py2.py3-none-any.whl
    ## python_dateutil
    pip install python_dateutil-2.8.1-py2.py3-none-any.whl
    ## APScheduler
    pip install funcsigs-1.0.2-py2.py3-none-any.whl
    pip install futures-3.3.0-py2-none-any.whl
    pip install pytz-2020.1-py2.py3-none-any.whl
    pip install tzlocal-2.1-py2.py3-none-any.whl
    pip install APScheduler-3.6.3-py2.py3-none-any.whl
    ## gunicorn
    pip install gunicorn-19.10.0-py2.py3-none-any.whl
    ## gevent
    pip install zope.event-4.4-py2.py3-none-any.whl
    pip install greenlet-0.4.16-cp27-cp27mu-manylinux1_x86_64.whl
    pip install zope.interface-5.1.0-cp27-cp27mu-manylinux2010_x86_64.whl
    pip install gevent-20.6.2-cp27-cp27mu-manylinux2010_x86_64.whl
    ## requests_toolbelt
    pip install requests_toolbelt-0.9.1-py2.py3-none-any.whl
    ## python_daemon
    pip install docutils-0.16-py2.py3-none-any.whl
    pip install lockfile-0.12.2-py2.py3-none-any.whl
    pip install python_daemon-2.2.4-py2.py3-none-any.whl

    ## redis
    pip install redis-3.5.3-py2.py3-none-any.whl

    ## Flask-Compress
    pip install Brotli-1.0.9-cp27-cp27mu-manylinux1_x86_64.whl
    pip install Flask-Compress-1.8.0.tar.gz

    deactivate
}


install_openresty() {
    if [[ ! -d "/usr/local/openresty" ]]; then
        # openresty
        tar xf ${WORD_DIR}/openresty-centos-7-20220305.tar.gz -C  /usr/local
        mkdir -p /data/nginx/cache
        mkdir -p /var/log/cdnfly/
        start_on_boot "ulimit -n 51200 && /usr/local/openresty/nginx/sbin/nginx"

        echo "/usr/local/openresty/libmaxminddb/lib/" > /etc/ld.so.conf.d/libmaxminddb.conf
        ldconfig

        # 下载spider_ip.json
        mkdir -p /usr/local/openresty/nginx/conf/vhost/
        touch /usr/local/openresty/nginx/conf/vhost/0-9999999999-removing.conf
        \cp -rp ${WORD_DIR}/spider_ip.json  /usr/local/openresty/nginx/conf/vhost/
    fi

    # 下载rotate.tar.gz到/opt/cdnfly/nginx/conf，并解压
    tar xf ${WORD_DIR}/rotate.tar.gz -C /opt/cdnfly/nginx/conf

}



install_redis() {
    if [[ ! -d "/usr/local/redis" ]]; then
        tar xf ${WORD_DIR}/redis-centos-7-20200714.tar.gz -C  /usr/local
    fi
}


install_filebeat() {
    if [[ ! -d /etc/filebeat/ ]]; then
        yum install -y ${WORD_DIR}/filebeat-7.10.0-x86_64.rpm && mkdir -p /var/log/cdnfly/

    fi

    # 修改配置
    sed -i "s/192.168.0.30/$MA_IP/" /opt/cdnfly/agent/conf/filebeat.yml
    sed -i "s/ES_PWD/$ES_PASS/" /opt/cdnfly/agent/conf/filebeat.yml
    chmod 600 /opt/cdnfly/agent/conf/filebeat.yml

}


install_rsyslog() {
# rsyslog
cat > /etc/rsyslog.d/cdnfly.conf <<'EOF'

    $ModLoad imudp
    $UDPServerRun 514
    $Umask 0000
    :msg,contains,"[cdnfly" /var/log/cdnfly.log
    $Umask 0022
    $EscapeControlCharactersOnReceive off
EOF

service rsyslog restart 2&>/dev/null|| true

mkdir -p /var/log/cdnfly/

}


config() {
    sed -i "s/127.0.0.1/$MA_IP/" /opt/cdnfly/agent/conf/config.py
    sed -i "s/192.168.0.30/$MA_IP/" /opt/cdnfly/agent/conf/config.py
    sed -i "s/ES_PWD =.*/ES_PWD = \"$ES_PASS\"/" /opt/cdnfly/agent/conf/config.py
}


start_on_boot(){
    local cmd="$1"
    if [[ -f "/etc/rc.local" ]]; then
        sed -i '/exit 0/d' /etc/rc.local
        if [[ `grep "${cmd}" /etc/rc.local` == "" ]];then
            echo "${cmd}" >> /etc/rc.local
        fi
        chmod +x /etc/rc.local
    fi


    if [[ -f "/etc/rc.d/rc.local" ]]; then
        sed -i '/exit 0/d' /etc/rc.d/rc.local
        if [[ `grep "${cmd}" /etc/rc.d/rc.local` == "" ]];then
            echo "${cmd}" >> /etc/rc.d/rc.local
        fi
        chmod +x /etc/rc.d/rc.local
    fi
}


start() {
    start_on_boot "supervisord -c /opt/cdnfly/agent/conf/supervisord.conf"
    if ! supervisord -c /opt/cdnfly/agent/conf/supervisord.conf > /dev/null 2>&1;then
        supervisorctl -c /opt/cdnfly/agent/conf/supervisord.conf reload 
    fi

    rm -rf /opt/cdnfly/master
    chmod +x /opt/cdnfly/agent/sh/*.sh

    # 关闭防火墙
        systemctl stop firewalld.service || true
        systemctl disable firewalld.service || true

    # 添加cdnfly ipset
    if ! ipset list cdnfly > /dev/null 2>&1; then
        ipset -N cdnfly iphash maxelem 10000000 timeout 3600
    fi

    if ! ipset list cdnfly_white > /dev/null 2>&1; then
        ipset -N cdnfly_white iphash maxelem 10000000 timeout 0
    fi

    if ! ipset list cdnfly_black > /dev/null 2>&1; then
        ipset -N cdnfly_black iphash maxelem 10000000 timeout 0
    fi

    # 添加iptables
    if [[ $(iptables -t filter -S INPUT 1 | grep -- '-A INPUT -m set --match-set cdnfly_white src -j ACCEPT') == "" ]];then
        iptables -D INPUT -m set --match-set cdnfly src -j DROP 2&>/dev/null || true
        iptables -D INPUT -m set --match-set cdnfly_black src -j DROP 2&>/dev/null || true
        iptables -D INPUT -m set --match-set cdnfly_white src -j ACCEPT 2&>/dev/null || true


        iptables -I INPUT -m set --match-set cdnfly src -j DROP || true
        iptables -I INPUT -m set --match-set cdnfly_black src -j DROP || true
        iptables -I INPUT -m set --match-set cdnfly_white src -j ACCEPT || true
    fi

    # 添加cdnfly ipset ipv6
    if ! ipset list cdnfly_v6 > /dev/null 2>&1; then
        ipset create cdnfly_v6 hash:net family inet6 maxelem 10000000 timeout 3600
    fi

    if ! ipset list cdnfly_white_v6 > /dev/null 2>&1; then
        ipset create cdnfly_white_v6 hash:net family inet6 maxelem 10000000 timeout 0
    fi

    if ! ipset list cdnfly_black_v6 > /dev/null 2>&1; then
        ipset create cdnfly_black_v6 hash:net family inet6 maxelem 10000000 timeout 0
    fi

    # 添加iptables v6
    if [[ $(ip6tables -t filter -S INPUT 1 | grep -- '-A INPUT -m set --match-set cdnfly_white_v6 src -j ACCEPT') == "" ]];then
        ip6tables -D INPUT -m set --match-set cdnfly_v6 src -j DROP 2&>/dev/null || true
        ip6tables -D INPUT -m set --match-set cdnfly_black_v6 src -j DROP 2&>/dev/null || true
        ip6tables -D INPUT -m set --match-set cdnfly_white_v6 src -j ACCEPT 2&>/dev/null || true


        ip6tables -I INPUT -m set --match-set cdnfly_v6 src -j DROP || true
        ip6tables -I INPUT -m set --match-set cdnfly_black_v6 src -j DROP || true
        ip6tables -I INPUT -m set --match-set cdnfly_white_v6 src -j ACCEPT || true
    fi

    ulimit -n 51200 && /usr/local/openresty/nginx/sbin/nginx || true
}


install_end() {
    sleep 10
    ss -pantul |grep -wq 5000 && echo "ok" >/tmp/.stauts || echo "no" >/tmp/.stauts

    if [ "$(cat /tmp/.stauts)" == "ok" ]; then
       echo -e "\n安装节点成功！"
       rm -rf $WORD_DIR && rm -rf /opt/es_pwd
       echo "iptables enable port: 80 443 5000  allow:$MA_IP"
    else
      echo -e "\n安装节点失败!!"
      rm -rf $WORD_DIR && rm -rf /opt/es_pwd && rm -rf /opt/venv && rm -rf /opt/geoip
    fi
}



trap 'onCtrlC' INT
function onCtrlC () {
        #捕获CTRL+C，当脚本被ctrl+c的形式终止时同时终止程序的后台进程
        kill -9 ${do_sth_pid} ${progress_pid}
        echo
        echo 'Ctrl+C is captured'
        exit 1
}



progress () {
        #进度条程序
        local main_pid=$1
        local length=20
        local ratio=1
        while [ "$(ps -p ${main_pid} | wc -l)" -ne "1" ] ; do
                mark='>'
                progress_bar=
                for i in $(seq 1 "${length}"); do
                        if [ "$i" -gt "${ratio}" ] ; then
                                mark='-'
                        fi
                        progress_bar="${progress_bar}${mark}"
                done
                printf "执行中 : ${progress_bar}\r" 
                ratio=$((ratio+1))
                #ratio=`expr ${ratio} + 1`
                if [ "${ratio}" -gt "${length}" ] ; then
                        ratio=1
                fi
                sleep 0.1
        done
}


shell_bar () {
       do_sth_pid=$(jobs -p | tail -1)
       
       progress "${do_sth_pid}" &
       progress_pid=$(jobs -p | tail -1)
       
       wait "${do_sth_pid}"
}



####### start install ###########
echo -e "\n安装依赖和时间同步" 
install_depend >/dev/null | tee -a /tmp/cdnwaf.log && sync_time >/dev/null | tee -a /tmp/cdnwaf.log &     
shell_bar && printf "完成 \n"


echo -e "\n安装组件" 
install_geoip >/dev/null | tee -a /tmp/cdnwaf.log            &&\
install_pip_module 2&>/dev/null | tee -a /tmp/cdnwaf.log     &&\
install_openresty >/dev/null | tee -a /tmp/cdnwaf.log        &&\
install_redis >/dev/null | tee -a /tmp/cdnwaf.log            &&\
install_filebeat >/dev/null  | tee -a /tmp/cdnwaf.log        &&\
install_rsyslog >/dev/null | tee -a /tmp/cdnwaf.log          &
shell_bar && printf "完成 \n"

echo -e "\n配置和启动服务" 
config >/dev/null | tee -a /tmp/cdnwaf.log && start | tee -a /tmp/cdnwaf.log &    
shell_bar && printf "完成 \n"

install_end

