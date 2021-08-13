#!/usr/bin/bash
set -x
sudo apt update -y
sudo apt -y upgrade
sudo apt install nginx -y
sudo ufw allow 'Nginx HTTP'


sudo mkdir /tmp/nginx_files




echo ${input_tags} | sed 's| |\n|'g | awk '{sub(/:/," ")}1' | tee /tmp/input_tags.data && \
cat << EOF > /tmp/nginx.py
#!/usr/bin/python
import json

def get_tags() -> dict:
    filename = "/tmp/input_tags.data"

    with open(filename) as f:
        content = f.readlines()

    tags = {}

    for w in content:
        key = w.split(" ")[0]
        value = w.split(" ")[1]
        tags[key] = value.replace("\n","")

    f.close()

    return tags



def genrate_files(tags) -> None:

    for value, key in tags.items():
        page_string = "{s}".format(s = key)
        page_name = "/tmp/nginx_files/{n}.html".format(n = value)
        with open(page_name, "w+") as file:
            file.write(page_string)
            file.close()
    with open("/tmp/nginx_files/index.html", "w+") as file:
        file.write("flugel")
        file.close()
    return



if __name__ =="__main__":
    tags = get_tags()
    genrate_files(tags)
EOF

sudo cat << EOF > /tmp/default
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                try_files \$uri \$uri.html \$uri/index.html index.html =404;
        }
}
EOF

sudo chmod +x /tmp/nginx.py
sudo python3 /tmp/nginx.py

yes | sudo cp /tmp/nginx_files/* /var/www/html
yes | sudo cp /tmp/nginx_files/index.html /var/www/html/index.nginx-debian.html
while [ ! -f /etc/nginx/sites-available/default ]; do sleep 1; done
yes | sudo cp /tmp/default /etc/nginx/sites-available


sudo systemctl restart nginx

set +x




