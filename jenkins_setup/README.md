# steps for setting up the CSSS jenkins

## useful links

1. https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy
1. https://github.com/hughperkins/howto-jenkins-ssl/blob/master/letsencrypt.md
1. https://github.com/jenkinsci/docker/blob/master/README.md


## Create job to build wall_e
![Step 1](jenkins_build_wall-e_1.jpg)

![Step 2](jenkins_build_wall-e_2.jpg)

![Step 3](jenkins_build_wall-e_3.jpg)

## Create jobs to remove outdates branch and PRs based discord channels and containers

### Change security Settings on Jenkins to allow Github anonymous webhooks

![Step 1](jenkins_configure_security_1.jpg)

![Step 2](jenkins_configure_security_2.jpg)

![Step 3](jenkins_configure_security_3.jpg)

### Jenkins Jobs to create

#### wall-e-clean-branch

![Step 1](jenkins_wall-e-clean-branch_1.jpg)

![Step 2](jenkins_wall-e-clean-branch_2.jpg)

#### wall-e-clean-pr

![Step 1](jenkins_wall-e-clean-pr_1.jpg)

![Step 2](jenkins_wall-e-clean-pr_2.jpg)

### Github webhook to create

#### wall-e-clean-branch

![Step 1](github_wall-e-clean-branch.jpg)

Payload URL: `https://jenkins.sfucsss.org/job/wall-e-clean-branch/buildWithParameters?token=<token>`

#### wall-e-clean-pr

![Step 1](github_wall-e-clean-pr.jpg)

Payload URL: `https://jenkins.sfucsss.org/job/wall-e-clean-pr/buildWithParameters?token=<token>`

### disable csrf

https://unix.stackexchange.com/a/582764/328370
