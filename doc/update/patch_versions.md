# Universal update guide for patch versions
*Make sure you view this [upgrade guide](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/patch_versions.md) from the `master` branch for the most up to date instructions.*

For example from 6.2.0 to 6.2.1, also see the [semantic versioning specification](http://semver.org/).

### 0. Backup

It's useful to make a backup just in case things go south:
(With MySQL, this may require granting "LOCK TABLES" privileges to the GitLab user on the database version)

```bash
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

### 1. Stop server

    sudo service gitlab stop

### 2. Get latest code for the stable branch

```bash
cd /home/git/gitlab
sudo -u git -H git fetch --all
sudo -u git -H git checkout -- Gemfile.lock db/schema.rb
sudo -u git -H git checkout LATEST_TAG
```

Replace LATEST_TAG with the latest GitLab tag you want to upgrade to, for example `v6.6.3`.

### 3. Update gitlab-shell to the corresponding version

```bash
cd /home/git/gitlab-shell
sudo -u git -H git fetch
sudo -u git -H git checkout v`cat /home/git/gitlab/GITLAB_SHELL_VERSION`
```

### 4. Install libs, migrations, etc.

```bash
cd /home/git/gitlab

#PostgreSQL
sudo -u git -H bundle install --without development test mysql --deployment

# MySQL
sudo -u git -H bundle install --without development test postgres --deployment

sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
sudo -u git -H bundle exec rake assets:clean RAILS_ENV=production
sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production
sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
```

### 5. Start application

    sudo service gitlab start
    sudo service nginx restart

### 6. Check application status

Check if GitLab and its environment are configured correctly:

    sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production

To make sure you didn't miss anything run a more thorough check with:

    sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

If all items are green, then congratulations upgrade complete!
