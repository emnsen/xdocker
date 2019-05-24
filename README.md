### Docker

If you do not have Docker installed in your environment, install the required docker [by clicking here](https://www.docker.com/community-edition).

#### Requirements

- Docker (I think Docker Edge has better disk performance than Docker)
- gem
- docker-sync

#### How to use with Symfony

##### New Project

You can create your new project with xDocker by running the following commands respectively.

```bash
$ composer create-project symfony/skeleton your-app
$ git remote add xdocker git@github.com:emnsen/xdocker.git
$ git pull xdocker master
$ ./start.sh # you may want to take a look at the alias, maybe you use the `rundockerrun` command
```

##### Included in the Existing Project

You can include the following commands in your current project by running them respectively.

```bash
$ git remote add xdocker git@github.com:emnsen/xdocker.git
$ git remote update
$ git pull xdocker master
```

> **Note:**
>
> If you have trouble with the `$ git pull xdocker master` command, add `--allow-unrelated-histories` to the end of the command and run it again.
>
> After using the above option one time, you can continue to use `$ git pull xdocker master`.
>
> Example; `$ git pull xdocker master --allow-unrelated-histories`

#### Setup

From the terminal, enter the main directory of the project.

If the following aliases are not available. Run the following code.

```bash
$ cat xdocker/aliases >> ~/.bash_aliases
```

> If the terminal you are using is not the default terminal, replace the .bash_aliases file with the appropriate file name for your terminal.
> Example;
>
> - oh-my-zshrc > ~/.zshrc
> - linux terminal > ~/.bash_aliases or ~/.bashrc
> - mac terminal > ~/.profile

After adding the above, you can work by typing `rundockerrun` in the main directory of your project.

> Installation on Linux may require root privileges. In such a case, run `sudo rundockerrun`.
> If you want to update the database parameters (host, user, password, etc.), please run with `--dpu` option. Example: `rundockerrun --dpu`

Below are the alias in the aliases file.

---

#### Xdebug

For installation, `xdocker/php-fpm/php-ini-overrides.ini` file is disabled in the following settings at the beginning of the `;`remove the character.

```
;zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so
;xdebug.remote_host=host.docker.internal
;xdebug.remote_enable=1
;xdebug.remote_handler=dbgp
;xdebug.remote_port=9001
;xdebug.remote_autostart=0
;xdebug.remote_connect_back=0
;xdebug.idekey=PHPSTORM
```

After making the above settings, click `Preferences> Languages & Frameworks> PHP` in PHPStorm.

1. Click the `Debug` menu and set the`Debug Port` at right side to `9001`. This should be the same as the value in php.ini.
2. Click on the `Servers` menu after the `Debug`, click `+` to open a new server. `Host: localhost`, `Port: 80`, set to `Debugger: Xdebug`.
   In the drop down area, click on 'Use path mappings' and set `Absolute path on the server` to the `application/application` field opposite your project directory.
3. Once you have the docker buildi, download the [Chrome Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc) plug-in, click on the plug-in, click on the debug option, and enjoy the debug.

> If you want to do without plug-in `xdebug.remote_autostart = 1` by setting the automatic connection to be able to provide continuous.

---

#### SSL

Make sure that the `443` port, which is the default SSL Port, is defined as `- 443:443` under `services > webserver > ports` in `docker-compose.yml`.

In below;

1. **[Certificate creation](#certificate-creation)**
2. **[Nginx](#nginx)**
3. **[MacOS](#macos)**

Do not forget to run `dc build && rundockerrun` in the directory of the project after performing the steps.

###### Creating certificates

To create SSL in your local development environment, run `cd xdocker/nginx/certs` from the terminal.
Create the required certificates by replacing `<domain>` in the following command with your local domain.

```bash
openssl req -x509 -out <domain>.local.crt -keyout <domain>.local.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=<domain>.local' -extensions EXT -config <( \
   printf "[dn]\nCN=<domain>.local\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:<domain>.local\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

###### Nginx

Activate certificate usage by removing `#` at the beginning of the lines in the file below.

`File: xdocker/nginx/nginx.conf.template`

```bash
#listen 443 ssl http2;
#listen [::]: 443 ssl http2;
#ssl on;
#ssl_certificate /etc/nginx/certs/${NGINX_HOST}.crt;
#ssl_certificate_key /etc/nginx/certs/${NGINX_HOST}.key;
```

###### MacOS

1. **Open Keychain Access**, click **System** under **Keychains** in the left menu.
2. Click `File> Import Items` from the menu above and select `<domain>.local.crt` which you created from the drop-down screen and click on `Add`. (Enter the password of your computer if you want a password.)
3. On the top right, search from `Search` in the form `<domain>.local` and find the certificate you imported and double click on it. Click the arrow of `Trust` in the window that opens and expand tab. `When using this certificate:` Choose `Always Trust` from the available options and close. You can start using `https://<domain>.local` with your local ssl certificate.

---

#### Aliases

```bash
alias dc='docker-compose'
alias dcu='dc up -d'
alias dck='dc kill $(docker ps -aq) &>/dev/null'
alias dcl='dc ps'
alias dcr='dc restart'
alias dcp='dc exec --privileged php-fpm'
alias dcn='dc exec --privileged nginx'
alias dcm='dc exec --privileged mysql'
alias dp='dcp php'
alias cmp='dcp composer'
alias ci='cmp install'
alias cu='cmp update'
alias cr='cmp require'
alias sc='dp bin/console'
alias sdsu='sc d:s:u --force'
alias scc='sc c:c --no-warmup'
alias rundockerrun='./start.sh'
alias rerundocker='dck || rundockerrun'
```
