## Remote Git Setup
Setup a new remote git repository, was developped specifically to run on EC2 Instances

Run this script with ``` ruby -r rubygems remote-git-setup.rb "My Project" /var/www/ ```

### Structure

- ``` ./.git_repos/ ``` Contains the git repositories (created wherever the script is running)
- ``` ./.git_repos/my-project.git ``` This is the project repository
- ``` /usr/local/bin/my-project ``` This script handles committing the changes to the physical files

### Post Running
> These steps are specific to EC2 instances and must be performed after runnig the script

- Grant execution permissions to ``` hooks/post-receive ``` and ``` /usr/local/bin/my-project ```
- Create the working directory according to the passed arguments ``` /var/www/my-project ```
- Update ``` visudo ``` by commenting out ``` # Default requiretty ``` and adding:

```
	git     ALL=(root) NOPASSWD: /usr/local/bin/my-project
	git     ALL=(root) NOPASSWD: /bin/sh
	git     ALL=(root) NOPASSWD: /bin/sh /usr/local/bin/my-project
```
- Finally, in your local git repository ``` git remote add origin host:/home/ec2-user/.git_repos/my-project.git ```