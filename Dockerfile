FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl zip

ADD uploading_templates.bash /
ADD ./Meta /Meta

ENTRYPOINT ["sh", "-c", "/bin/bash uploading_templates.bash https://api-te-s7-nc.dev.caas.epaas.s7.aero/ 1b359d7b-de3d-4909-903b-89699ce19446"]