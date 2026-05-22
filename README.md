# DevOps-Practice-1-Infrastructure
This repository contains all the Dockerfile and Docker Compose files that I used during my DevOps practice. If you are looking for the practice repository, you can find it [here](https://github.com/FaridG7/DevOps-Practice-1) 
The compose file contains service defenitions for a gitlab instance, a gitlab runner, an apache and an alpine that has rsync setup and a shared volume with the apache.

## How to bring up the setup
### on Linux
1. Create the .env.
```sh
cp example.env .env
```
2. (optional) Change the tags or hostnames.
```sh
vim .env
```
3. Bring up the compose file
```sh
docker compose up [-d]
```
4. (optional) Make sure the compose is healthy
See if any of the cotainers are restarting.
```sh
docker compose ps
```
5. Add the gitlab hostname to the hosts file
```sh
sudo echo "127.0.0.1 <gitlab hostname>" >> /etc/hosts
# Example:
sudo echo "127.0.0.1 gitlab.local" >> /etc/hosts
```
6. Register the runner if you want to use CI

## How to config & register the runner
1. Get the gitlab root user password
```sh
docker compose exec gitlab cat /etc/gitlab/initial_root_password
```
2. Access the gitlab UI from the browser
3. Login with root username and the password from step 1
4. Follow [these](https://docs.gitlab.com/ci/runners/runners_scope/#create-an-instance-runner-with-a-runner-authentication-token) instructions
5. Config the runner
**Important:** Because we used a compose file, we need to also tell the runner to attach the created images to the `gitlab_net` network so that they can reach the gitlab and you can do this by adding a line to the configuration file of the runner.
```sh
docker compose exec runner1 echo 'network_mode = "infrastructure_gitlab_net"'
```
6. (optional) Add docker hub helper image
If you don't have access to the registry.gitlab.com like me (because I'm in Iran) then you need to specify a helper image for the runner that is in an available registry (e.g. Docker Hub)
```sh
docker compose exec runner1 echo 'helper_image = "gitlab/gitlab-runner-helper:<your architecture type>-<gitlab runner version/tag>"'
# Example
docker compose exec runner1 echo 'helper_image = "gitlab/gitlab-runner-helper:x86_64-v18.11.3"'
```
