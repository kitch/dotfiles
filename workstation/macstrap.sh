docker run -d -h dev -e TZ=UTC -p 3222:3222 -p 60000:60000/udp -p 60001:60001/udp -p 60002:60002/udp -p 60003:60003/udp -p 60004:60004/udp -p 60005:60005/udp -p 60006:60006/udp -p 60007:60007/udp -p 60008:60008/udp -p 60009:60009/udp -p 60010:60010/udp --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/devbox/code:/root/code \
  -v ~/devbox/secrets:/root/secrets \
  -v ~/devbox/id_rsa:/root/.ssh/github_rsa \
  -v ~/devbox/id_rsa:/root/.ssh/id_rsa \
  -v ~/devbox/zhistory:/root/.zsh_history \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  --privileged --name devbox kitch/devbox:latest
