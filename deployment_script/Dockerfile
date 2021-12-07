FROM centos:8

ENV NODE_VERSION=14.17.6
RUN yum install -y curl git python3 python3-pip tar gzip bzip2
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

Run python3 -m pip install --upgrade pip
Run python3 -m pip install psycopg2-binary

WORKDIR /panasonic

# Copy SSH key for git private repos
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa # Use git with SSH instead of https
RUN echo "[url \"git@github.com:\"] insteadOf = https://github.com/" >> /root/.gitconfig # Skip Host verification for git
RUN echo "StrictHostKeyChecking no " > /root/.ssh/config

RUN npm install -g --silent @angular/cli
RUN npm install -g --silent pm2
RUN npm install -g --silent dotenv

COPY .env .env
COPY create_db.py create_db.py
COPY create_admin.js create_admin.js
COPY run.sh run.sh
RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]


# Build prod
#RUN ng build --watch


# ----------------------------------
# Prepare production environment
FROM nginx:alpine
# ----------------------------------


# Copy dist
#COPY --from=builder /build/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html

# Permission
RUN chown root /usr/share/nginx/html/*
RUN chmod 755 /usr/share/nginx/html/*

# Expose port
EXPOSE 2000

# Start
CMD ["nginx", "-g", "daemon off;"]
