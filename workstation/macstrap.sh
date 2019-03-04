docker run -h dev -e TZ=UTC -p 3222:3222 -p 60000:60000 -p 60001:60001 -p 60002:60002 -p 60003:60003 -p 60004:60004 -p 60005:60005 -p 60006:60006 -p 60007:60007 -p 60008:60008 -p 60009:60009 -p 60010:60010 --rm \⏎
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/devbox/code:/root/code \
  -v ~/devbox/secrets:/root/secrets \
  -v ~/devbox/id_rsa:/root/.ssh/github_rsa \
  -v ~/devbox/id_rsa:/root/.ssh/id_rsa \
  -v ~/devbox/zhistory:/root/.zsh_history \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  --privileged --name devbox kitch/devbox:latest
