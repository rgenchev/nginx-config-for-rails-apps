server {
  server_name example.com www.example.com;

  if ($host = www.example.com) {
    return 301 https://example.com$request_uri;
  }

  access_log  /var/log/nginx/example.access.log;

  location / {
    root /home/example-app/apps/example/current/public;
    passenger_enabled on;
    passenger_min_instances 3;
    rails_env production;

    client_max_body_size 11m;

    location ~* ^/(assets|fonts|favicon.ico) {
      allow all;
      expires 365d;
      gzip_http_version 1.0;
      add_header Cache-Control public;
      break;
    }
  }

  listen [::]:443 ssl ipv6only=on; # managed by Certbot
  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  server_name example.com www.example.com;
  listen 80;
  listen [::]:80;

  return 301 https://example.com$request_uri;

  access_log off;
  return 404;
}
