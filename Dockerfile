FROM mcr.microsoft.com/playwright:v1.61.0-jammy

RUN npm install -g netlify-cli@20.1.1
RUN apt update && apt install -y jq