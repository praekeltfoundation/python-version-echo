ARG PYTHON_VERSION=3.6
FROM praekeltfoundation/python-base:${PYTHON_VERSION}

# Create the user and working directories first as they shouldn't change often.
# Specify the UID/GIDs so that they do not change somehow and mess with the
# ownership of external volumes.
RUN set -ex; \
    addgroup --system --gid 107 apistar; \
    adduser --system --uid 104 --ingroup apistar apistar; \
    \
    mkdir /var/run/gunicorn; \
    chown apistar:apistar /var/run/gunicorn


# Install a modern Nginx and configure
ENV NGINX_VERSION 1.12.2-1~jessie
ENV NGINX_GPG_KEY 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN set -ex; \
    apt-get-install.sh wget; \
    wget -O- https://nginx.org/keys/nginx_signing.key | apt-key add -; \
    apt-key adv --fingerprint "$NGINX_GPG_KEY"; \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' > /etc/apt/sources.list.d/nginx.list; \
    apt-get-purge.sh wget; \
    apt-get-install.sh "nginx=$NGINX_VERSION"; \
    rm /etc/nginx/conf.d/default.conf; \
# Add nginx user to apistar group so that Nginx can read/write to gunicorn socket
    adduser nginx apistar
COPY scripts/nginx/ /etc/nginx/

# Install gunicorn and pipenv
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

EXPOSE 8000
WORKDIR /app

COPY scripts/entrypoint.sh  /scripts/
ENTRYPOINT ["tini", "--", "entrypoint.sh"]

COPY src /app
COPY Pipfile* /
RUN pipenv install --system --deploy

CMD ["app:app"]