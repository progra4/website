#Instalando las cosas

Necesitamos instalar: la versión 1.9.3 del lenguaje de programación
ruby. Una forma de instalar librerías de ruby:
[rubygems](http://rubygems.org/) y git para control de versiones. Vamos
paso a paso.

##1. Instalando git

Necesitamos git para todo en esta clase, así que instalémoslo:

    sudo apt-get install git-core


Para manejar nuestros proyectos en git, usaremos <http://github.com>.
Así que entrá ahí y creá una cuenta, yo espero.

Una vez creada una cuenta, necesitamos crear una llave pública para que
cuando subamos código desde nuestra máquina a github, éste pueda confiar
en nosotros. Con este comando:

    ssh-keygen -t rsa -C "your_email@youremail.com"

Una vez que creés tu cuenta, mirá qué contiene tu llave pública
ejecutando

    cat ~/.ssh/id_rsa.pub

Copiá eso y pegalo acá: <https://github.com/account/ssh>



(Más info acá <http://help.github.com/linux-set-up-git/>)

##2. Instalando ruby

Quizá ya tengás ruby instalado en tu sistema, probá escribir

     ruby -v

Y quizá veás algo como

    ruby 1.9.3p125 (2012-02-16 revision 34643) [x86_64-darwin11.3.0]

(o algo mucho más corto, lo importante es ver la versión). Lo más
probable es que tengás la versión `1.8.7`. En esta clase usaremos la
versión 1.9 del lenguaje, que tiene algunas diferencias sintácticas. 
Podríamos meternos al rollo de cambiar la versión de ruby del sistema,
eliminando el ruby viejo y compilando ruby 1.9 [a
mano](http://www.ruby-lang.org/en/downloads/).

Pero no nos vamos a complicar tanto, vamos a usar
[rvm](http://beginrescueend.com/), un proyecto que permite manejar
varias versiones de ruby en la misma máquina sin morir en el intento.

Antes de instalarlo, vas a tener que instalar unas cuantas librerías de las cuales depende ruby

	  sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

Para [instalarlo](http://beginrescueend.com/rvm/install/), corré en la
línea de comandos:

    sudo apt-get install curl libcurl3 
    curl -L get.rvm.io | bash -s stable
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile
    source ~/.bash_profile
    echo "source ~/.bash_profile" >> ~/.bashrc


Para probar que todo salió bien, escribí:

    type rvm | head -1

Si rvm está bien instalado, eso debería decir algo como `rvm is a
function`

Si todo salió bien, escribí:

    rvm requirements

Y seguí las instrucciones en la pantalla para instalar las dependencias
de ruby. Una vez terminado eso, es hora de instalar un nuevo ruby:

    rvm install 1.9.3
    rvm use 1.9.3 --default

La segunda de esas líneas hace que de ahora en adelante tu máquina use
ruby 1.9.3 por defecto.

Ahora, estas dos líneas para asegurarte que tenés las versiones
correctas de las cosas:

    ruby -v
    #debería salir algo como 1.9.3
    gem -v
    #algo como 1.8.21


Y hasta podés entrar a la consola de ruby y jugar:

    irb
    > puts "Hola Mundo"


(Más info acá <http://beginrescueend.com/rvm/install/#explained>)
