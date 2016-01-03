FROM debian:jessie

RUN echo "APT::Install-Recommends              false;" >> /etc/apt/apt.conf.d/recommends.conf && \
    echo "APT::Install-Suggests                false;" >> /etc/apt/apt.conf.d/recommends.conf && \
    echo "APT::AutoRemove::RecommendsImportant false;" >> /etc/apt/apt.conf.d/recommends.conf && \
    echo "APT::AutoRemove::SuggestsImportant   false;" >> /etc/apt/apt.conf.d/recommends.conf && \
    apt-get update && \
    # actual dependencies
    apt-get install -y ca-certificates libpcre3 libssl1.0.0 zlib1g && \
    # build dependencies
    apt-get install -y build-essential git libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make wget && \
    git clone https://github.com/bobrik/ngx_openresty.git /tmp/openresty && \
    cd /tmp/openresty && \
    git checkout -f e3336aca0a7335833f19800a570d2a787f8280b3 && \
    ./util/mirror-tarballs && \
    cd ngx_openresty-* && \
    ./configure \
        # Copied from official debian packaging for nginx, "rules" file
        # http://nginx.org/packages/mainline/debian/pool/nginx/n/nginx/nginx_1.9.7-1~jessie.debian.tar.xz
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-ipv6 \
        # OpenResty stuff
        --with-luajit && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/openresty && \
    apt-get remove -y build-essential git libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --system nginx && \
    adduser \
        --system \
        --disabled-login \
        --ingroup nginx \
        --no-create-home \
        --home /nonexistent \
        --gecos "nginx user" \
        --shell /bin/false \
        nginx && \
    mkdir -p /var/cache/nginx && \
    chown nginx:nginx /var/cache/nginx

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
