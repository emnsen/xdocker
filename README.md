### Docker

Çalışma ortamınızda Docker kurulu değilse, [buraya tıklayarak](https://www.docker.com/community-edition) gerekli docker kurulumunu gerçekleştiriniz.

#### Mevcut Projeye Dahil Etme

Aşağıdaki komutları sırasıyla çalıştırarak mevcut projenizin içerisine dahil edebilirsiniz.

```bash
$ git remote add xdocker git@github.com:emnsen/xdocker.git
$ git remote update
$ git pull xdocker master
```

> **Not:**
>
> Eğer `$ git pull xdocker master` komutunda sorun yaşıyorsanız, komutun sonuna `--allow-unrelated-histories` ekleyip tekrar çalıştırınız.
>
> Yukarıdaki opsiyonel seçeneği tek sefer kullandıktan sonra `$ git pull xdocker master` şeklinde kullanmaya devam edebilirsiniz.
>
> Örnek; `$ git pull xdocker master --allow-unrelated-histories`

#### Kurulum

Terminalden projenin ana dizinine girin.

Eğer aşağıdaki aliaseslar mevcut değilse. Aşağıdaki kodu çalıştırın.

```bash
$ cat xdocker/aliases >> ~/.bash_aliases
```

> Kullandığınız terminal, varsayılan terminal değilse .bash_aliases dosyasını terminalinize uygun olan dosya adıyla değiştirin.
> Örnek;
>
> - oh-my-zshrc > ~/.zshrc
> - linux terminal > ~/.bash_aliases veya ~/.bashrc
> - mac terminal > ~/.profile

Yukarıda ki aliasesları ekledikten sonra terminalden projenizin ana dizininde `rundockerrun` yazarak çalıştarabilirsiniz.

> Linux üzerindeki kurulumlarda root yetkisi gerekebilir. Böyle bir durumda `sudo rundockerrun` şeklinde çalıştırınız.
> Eğer veritabanı parametrelerini(host, kullanıcı, şifre, vs..) güncellemek istiyorsanız `--dpu` opsiyonu ile çalıştırınız. Örnek: `rundockerrun --dpu`

Aşağıda aliases dosyası içerisindeki aliaslar yer almaktadır.

---

#### Xdebug
Kurulum için `xdocker/php-fpm/php-ini-overrides.ini` dosyasında yer alan devre dışı bırakılmış aşağıda yer alan ayarların başında bulunan `;` karakterini kaldırınız.
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

Yukarıdaki ayarları yaptıktan sonra PHPStorm'da `Preferences > Languages & Frameworks > PHP` tıklayınız. 
1) `Debug` menüsüne tıklayın, sağ tarafta yer alan `Debug Port` değerini `9001` olarak ayarlayınız. Burası php.ini içerisindeki değerle aynı olmalıdır.
2) `Debug` sonra yer alan `Servers` menüsüne tıklayın, açılan ekran `+`'ya tıklayarak yeni bir server ekleyiniz. `Host: localhost`, `Port: 80`, `Debugger: Xdebug` olacak şekilde ayarlayın.
Hemen altında yer alan `Use path mappings`'e tıklayın açılan alanda `Project files` hemen altında yer alan proje dizininizin karşısında yer alan `Absolute path on the server` değerini `/application` olacak şekilde ayarlayın.
3) Tekrar docker buildi aldıktan sonra [Chrome Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc) eklentisini indirin eklentiye tıklayıp debug seçeneğine tıklayın ve keyifli debuglar.

> Eğer eklentisiz yapmak istiyorsanız `xdebug.remote_autostart=1` şeklinde ayarlayarak otomatik olarak sürekli bağlanmayı sağlayabilirsiniz.

---

#### SSL
Varsayılan SSL Portu olan `443` portunun `docker-compose.yml` dosyasında bulunan `services > webserver > ports` altında `- 443:443` şeklinde tanımlandığından emin olun.

Aşağıda yer alan;
1) **[Sertifika oluşturma](#sertifika-oluşturma)**
2) **[Nginx](#nginx)**
3) **[MacOS](#macos)**

adımlarını yaptıktan sonra projenin dizininde `dc build && rundockerrun` komutu çalıştırmayı unutmayınız.

###### Sertifika oluşturma
Local geliştirme ortamınızda SSL oluşturmak için terminalden `cd xdocker/nginx/certs` komutunu çalıştırın.
Aşağıdaki komutta bulunan `<domain>`'i local domaininiz ile değiştirerek gerekli sertifikaları oluşturun.
```bash
openssl req -x509 -out <domain>.local.crt -keyout <domain>.local.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=<domain>.local' -extensions EXT -config <( \
   printf "[dn]\nCN=<domain>.local\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:<domain>.local\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

###### Nginx
Aşağıdaki dosyada yer alan satırların başındaki `#` karakterini kaldırarak sertifika kullanımını aktif hale getiriniz.

`File: xdocker/nginx/nginx.conf.template`
```bash
#listen 443 ssl http2;
#listen [::]:443 ssl http2;
#ssl on;
#ssl_certificate /etc/nginx/certs/${NGINX_HOST}.crt;
#ssl_certificate_key /etc/nginx/certs/${NGINX_HOST}.key;
```

###### MacOS
1) **Keychain Access**'i açın, sol menüde yer alan **Keychains** altında yer alan **System**'e tıklayın. 
2) Yukarıdaki menüden `File > Import Items` seçeneğine tıklayın ve açılan ekrandan oluşturduğunuz `<domain>.local.crt` dosyasını seçip `Add` seçeneğine tıklayın. (Şifre istenmesi durumunda bilgisayarınızın şifresini girin.)
3) Sağ üstte yer alan `Search` kısmından `<domain>.local` şeklinde arama yapıp import ettiğiniz sertifikayı bulun ve üzerine çift tıklayın. Açılan pencerede `> Trust` yazısının okuna tıklayıp tab'ı genişletin. `When using this certificate:` karşısında bulunan seçeneklerden `Always Trust` seçeneğini seçin ve kapatın. `https://<domain>.local` şeklinde local ssl sertifikanız ile kullanmaya başlayabilirsiniz.

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
