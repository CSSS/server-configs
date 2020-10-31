# upgrading jenkins.sfucsss.org


## discord db
```shell
docker exec -it PRODUCTION_MASTER_wall_e_db ash
pg_dump -U postgres csss_discord_db > csss_discord_db.sql
docker cp PRODUCTION_MASTER_wall_e_db:/csss_discord_db.sql .
```

## passbolt db
[Backup Passbolt](https://help.passbolt.com/hosting/backup)  
[Update Passbolt](https://help.passbolt.com/hosting/update/install-scripts)

## jenkins stuff
`docker cp csss_jenkins:/var/jenkins_backups/ .`  
[Backup Jenkins](https://fitdevops.in/how-to-backup-jenkins-automatically/)
[Update Jenkins](https://medium.com/@jimkang/how-to-start-a-new-jenkins-container-and-update-jenkins-with-docker-cf628aa495e9)
