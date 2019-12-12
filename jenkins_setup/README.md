# steps for setting up the CSSS jenkins

```shell

# setup jenkins
docker run \
    -d \
    -v \
    /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/bin/docker \
    -v $(which docker-compose):/bin/docker-compose \
    -e VIRTUAL_HOST=jenkins.sfucsss.org \
    -p 8080:8080 \
    --name csss_jenkins \
    sfucsssorg/csss_jenkins


# copy nginx_configs/jenkins to /etc/nginx/sites-available/jenkins
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# verify chain cert with https://whatsmychaincert.com/?jenkins.sfucsss.org
```

## Create job to build wall_e
![Step 1](jenkins_setup/jenkins_build_wall-e_1.jpg)

![Step 2](jenkins_setup/jenkins_build_wall-e_2.jpg)

![Step 3](jenkins_setup/jenkins_build_wall-e_3.jpg)

## Create jobs to remove outdates branch and PRs based discord channels and containers

### Change security Settings on Jenkins to allow Github anonymous webhooks

![Step 1](jenkins_setup/jenkins_configure_security_1.jpg)

![Step 2](jenkins_setup/jenkins_configure_security_2.jpg)

![Step 3](jenkins_setup/jenkins_configure_security_3.jpg)

### Jenkins Jobs to create

#### wall-e-clean-branch

![Step 1](jenkins_setup/jenkins_wall-e-clean-branch_1.jpg)

![Step 2](jenkins_setup/jenkins_wall-e-clean-branch_2.jpg)

#### wall-e-clean-pr

![Step 1](jenkins_setup/jenkins_wall-e-clean-pr_1.jpg)

![Step 2](jenkins_setup/jenkins_wall-e-clean-pr_2.jpg)

### Github webhook to create

#### wall-e-clean-branch

![Step 1](jenkins_setup/github_wall-e-clean-branch.jpg)

Payload URL: `https://jenkins.sfucsss.org/job/wall-e-clean-branch/buildWithParameters?token=<token>`

#### wall-e-clean-pr

![Step 1](jenkins_setup/github_wall-e-clean-pr.jpg)

Payload URL: `https://jenkins.sfucsss.org/job/wall-e-clean-pr/buildWithParameters?token=<token>`
