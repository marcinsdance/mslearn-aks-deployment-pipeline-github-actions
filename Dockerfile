# Use a multi-stage build for a smaller final image
FROM node:16-bullseye as builder

# Install Hugo
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v0.92.2/hugo_extended_0.92.2_Linux-64bit.deb -o hugo.deb \
    && dpkg -i hugo.deb \
    && rm hugo.deb

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y git \
    && npm install -g postcss-cli autoprefixer

# Clone the repository and set up the website
WORKDIR /contoso-website
RUN git clone https://github.com/MicrosoftDocs/mslearn-aks-deployment-pipeline-github-actions . \
    && cd src \
    && git submodule update --init themes/introduction \
    && hugo

# Use Nginx for serving the static files
FROM nginx:1.22

# Copy the built static files from the builder stage
COPY --from=builder /contoso-website/src/public /usr/share/nginx/html

EXPOSE 80
