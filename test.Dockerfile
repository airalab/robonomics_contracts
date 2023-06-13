FROM node:16.20.0

COPY ./ /

RUN npm install -g truffle

ENTRYPOINT [ "/run_tests.sh" ]