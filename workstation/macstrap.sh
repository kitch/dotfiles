docker run -h dev -e TZ=UTC -p 3222:3222 --rm \                                                                                            ⏎
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/devbox/code:/root/code \
  -v ~/devbox/secrets:/root/secrets \
  -v ~/devbox/id_rsa:/root/.ssh/github_rsa \
  -v ~/devbox/id_rsa:/root/.ssh/id_rsa \
  -v ~/devbox/zhistory:/root/.zsh_history \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  --privileged --name devbox kitch/devbox:latest
