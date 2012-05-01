#Sirviendo HTTP con ruby (y una introducción a git)

El propósito de esta guía es doble: que aprendamos lo básico de escribir un programa de servidor y que aprendamos a guardar nuestro progreso con [git](http://gitref.org/)

Para aprender a escribir programas de servidor, trataremos de reproducir una parte de la funcionalidad [del sitio que usamos para aprender http](http://httparty.heroku.com/) 

##0. Preliminares


###Configurando git

__Si es la primera vez que usamos git__, tenemos que decirle quiénes somos, porque con nuestra "identidad" va a firmar cada cambio que hagamos (esto sirve mucho cuando trabajamos en grupo: así sabemos quién hace qué). Obviamente, te toca sustituir`TU NOMBRE` por tu propio nombre y `tucorreo@dominio.com` por tu correo electrónico.

	git config --global user.name "TU NOMBRE"
	git config --global user.email tucorreo@dominio.com
	
Como vamos a usar git tanto, vamos a agregar otra configuración que le pone colores a toda la información que nos mostrará git al usarlo

	git config --global color.ui true

Ahora que ya configuramos git, podemos empezar nuestro proyecto.

Para poder guardar el progreso de un proyecto con git, tenemos que tener una carpeta exclusiva para él (dentro de esta carpeta pueden haber todas las sub-carpetas que queramos). Así que creemos una carpeta para el trabajo que haremos hoy.

	mkdir quotes


Para que git pueda ir guardando nuestro progreso, tenemos que "iniciarlo" dentro de nuestra carpeta (con esto se creará la carpeta `.git`, que contendrá el "historial" de nuestro progreso, a este historial se le llama el `index` de git)

	cd quotes
	git init
	
Por ahora no haremos nada más con git, empecemos con el proyecto en sí.

### Librerías necesarias

Para este ejemplo, necesitamos instalar una librería de ruby que nos permite escribir servidores: [rack](http://rack.rubyforge.org/). Para instalarla, ejecutá lo siguiente

	gem install rack


##1. La aplicación web más básica

Un programa de lado del servidor no es más que un script que siempre está escuchando a ver si le llegan solicitudes. Como se menciona arriba, 
	
Las reglas de rack son:

1. Una aplicación consiste en un objeto que responda al método `call` 
2. El método recibirá un sólo parámetro: el entorno, que contiene a la solicitud y todas las variables del servidor necesarias para poder responder bien (encabezados, cuerpo de la solicitud, etc.)
3. El método deberá retornar un arreglo para construir con él la respuesta, los elementos del arreglo deben contener, en este orden: el código de estado, los encabezados y un iterable (algo que responda a `each`) que se usará para construir el cuerpo de la respuesta.

Bajo esas reglas, la aplicación más sencilla para rack se vería así:


	lambda do |env|
		[200, {}, ['Hola Mundo']]
	end
	
Un objeto `lambda` es una instancia de la clase `Proc`. La clase `Proc` define el método `call` (para referirnos a métodos de instancia, podemos usar esta convención: `Proc#call` - que es, `Clase#método`).

Obviamente, para hacerla funcionar, hay que poner un par de instrucciones extra: importar rack y decirle al script que se quede escuchando solicitudes y responda usando nuestra función:

	require 'rack'
	h = lambda do |env|
		[200, {}, ['Hola Mundo']]
	end
	Rack::Handler::WEBrick.run(h, Port: 3000)


Una convención que hay es usar una clase en lugar de un `lambda`, en esa clase definimos el método call y le damos a `rack` una instancia de ella, así:

	require 'rack'	
	class WebApp
	  def call(env)
	    [200, {}, ['Hola Mundo']]
	  end
	end
	Rack::Handler::WEBrick.run(WebApp.new, Port: 3000)
	
Para ejecutar nuestro script, podemos usar `ruby app.rb`. Y entrar a `localhost:3000/` en un browser o hacer `curl localhost:3000` (tené en cuenta que la aplicación es tan básica que ni siquiera se puede detener, hay que matar el proceso o cerrar la terminal y abrir otra)

Guardá lo anterior en un archivo llamado `app.rb` dentro de la carpeta que creaste para el proyecto (según lo dicho arriba, `quotes`)

### guardando nuestro progreso

En este punto ya tenés _algo_ que funciona. La costumbre de alguien que usa git es decirse a sí mismo "ok, en este momento tengo algo que funciona, quiero recordar este momento para siempre". Hacer eso es tan sencillo como decirle a git "hey git, acordate de este momento para siempre, porque aquí parece ir todo bien". Veamos cómo hacerlo:

Hay dos pasos para que git recuerde una de nuestras pequeñas victorias: primero, enemos que decirle a git _qué_ archivos son importantes en este momento. Por ejemplo, quizá en tu proyecto haya varios archivos pero lo importante de ahorita sólo está en unos cuantos. Para decirle a git que los cambios que hicimos en un archivo son relevantes, usamos la instrucción `git add`:

	git add app.rb

Aquí le decimos: "git, acabo de hacer algo importante con `app.rb`, preparate para acordarte". Pero _agregar_ un archivo no es el final de la historia, para que git guarde nuestro progreso usamos la instrucción `git commit`, que es el segundo paso:

	git commit -m 'mi primera web app'
	
Que va a devolver un mensaje parecido a este:

	[master (root-commit) cd7dde2] mi primera web app
 	1 files changed, 7 insertions(+), 0 deletions(-)
 	create mode 100644 app.rb

Que simplemente nos da algunas estadísticas de los cambios que acabamos de guardar.
	
si has jugado videojuegos, podés ver a la instrucción `git commit` como algo que crea un _checkpoint_: estamos creando un recuerdo. La opción `-m` nos permite agregar un mensaje descriptivo que nos ayudará a recordar de qué trataba este momento.


__¡Listo!__ ahora git se acordará para siempre de este momento. ¿Cómo sabemos que se acuerda? bueno, podemos preguntarle con la instrucción `git log`:

	git log

Nos debería mostrar algo similar a:

	commit 9d36cb55f9a207e37b48b7fcbddbe85f2dd98353
	Author: Juan Pérez <juanperez@gmail.com>
	Date:   Tue May 1 11:04:26 2012 -0600

    	mi primera web app
    	
Si te fijás, hay un par de cosas interesantes que notar allí:

* la primera línea, la que dice `commit`, nos muestra un __identificador único__: con esto podemos referirnos a este punto en la historia (así, podemos decir, "ah bueno, lo que yo hice en el commit "9d36cb55f9a207e37b48b7fcbddbe85f2dd98353" fue tal o cual cosa"). A este identificador único nos referiremos como `hash` de ahora en adelante
* Nos muestra __quién__ hizo el commit y __cuándo__ lo hizo
* Nos muestra el mensaje. Este mensaje debería ser una __descripción__ de lo que hicimos en ese momento de la historia.

##2. La aplicación web más básica que sigue estándares 


Una convención más que se tiene al usar `rack` para escribir servidores es tener dos archivos: uno dedicado al código de la aplicación y otro como "entrada" para el servidor. Este último se conoce como el `rackup`, probemos eso:

	#app.rb
	class WebApp
	  def call(env)
	    [200, {'Content-Type' => "text/plain"}, ['Hola Rackup']]
	  end
	end
	
	#start.ru
	require './app'
	run WebApp.new

(tendríamos dos archivos ahora: `app.rb` y `start.ru`)
	
Para correr una app con un archivo para `rackup`, usamos el comando `rackup` que rack instaló por nosotros:

	rackup -p 3000 start.ru
	

Esto debería tener un efecto similar a lo anterior, sólo que esta vez separamos al programa del servidor en sí de _cómo_ es ejecutado. Esta distinción es importante: vos podés escribir código de servidor y no deberías preocuparte de _cómo_ será ejecutado: puede ser usando `rackup` o cualquier otra cosa, eso no debería afectar el código en sí.


### guardando nuestro progreso
Ahora que ya tenemos un nuevo cambio que funciona, podríamos grabar con git otra vez. Pero, ¿de qué sirve guardar nuestro progreso si no sabemos _cuál_ fue nuestro progreso?

Afortunadamente, también le podemos preguntar eso a git, con el comando `git status`

	git status

que nos mostrará algo similar a esto:

	# On branch master
	# Changes not staged for commit:
	#   (use "git add <file>..." to update what will be committed)
	#   (use "git checkout -- <file>..." to discard changes in working directory)
	#
	#	modified:   app.rb
	#
	# Untracked files:
	#   (use "git add <file>..." to include in what will be committed)
	#
	#	start.ru
	no changes added to commit (use "git add" and/or "git commit -a")

Lo que git nos está queriendo decir:

con `Changes not staged for commit:` nos dice: "aquí hay unos archivos que vos has querido que yo recuerde antes, los acabás de cambiar, si querés que me acuerde otra vez de ellos, dale `git add`" y luego procede a listar los archivos que ya conoce y cómo los hemos cambiado. En este caso, nos dice que hemos modificado (`modified`) el archivo `app.rb`.

Pero luego nos dice, con `Untracked files:`, que, además de los cambios en archivos que ya conoce, hay ahora otros archivos que __aún no conoce__. Para "presentarle" estos archivos a git, también podemos usar `git add`.

De modo que, con `git add`, podemos hacer dos cosas:

* __Presentarle__ archivos a git, archivos que aún no conocía
* O __recordarle__ archivos que ya conocía

Hagamos ambas cosas, porque queremos que en este momento de la historia se acuerde de lo que hicimos con __ambos__ archivos:

	git add app.rb
	git add start.ru
	
Pudimos haber hecho esto también:

	git add .

Que simplemente agrega todos los archivos en el directorio actual, pero esa es una costumbre peligrosa, ya que podríamos a veces agregar archivos que no queremos recordar en este momento.

Una vez agregados los archivos a este nuevo recuerdo (en idioma git, acabamos de mover archivos al `stage` antes de hacer commit, que los mueve al `index`) podemos ver cuál es el status ahora:

	git status
	# On branch master
	# Changes to be committed:
	#   (use "git reset HEAD <file>..." to unstage)
	#
	#	modified:   app.rb
	#	new file:   start.ru
	
esta vez nos dice, con `changes to be committed`, que ya está al tanto de los archivos que queremos recordar en este nuevo cambio, y está listo para que lo guardemos. Para guardar el cambio, para hacer efectivo el recuerdo, haremos nuestro segundo commit:

	git commit -m 'usando rackup'
	
Y, ahora que ya hicimos el commit, veamos el status del proyecto

	git status
	# On branch master
	nothing to commit (working directory clean)
	
con `nothing to commit`, git nos está diciendo que no hemos hecho ningún cambio desde el último commit, así que no hay nada nuevo que podríamos recordar.

Podemos, también, ver la historia hasta ahora, con `git log`, y esta vez veremos dos commits.

##3. Respondiendo a nuestro entorno

Nuestra aplicación hasta el momento no hace nada útil, de hecho, ¡ni siquiera toca el parámetro `env`!

Repasemos cómo funciona una aplicación web en el lado del servidor:

* Recibe la solicitud
* Usa la información que está representada en la solicitud para construir una respuesta
* Devuelve la respuesta

Hasta ahora, vimos que `rack` representa el último paso en un arreglo con la forma `[estado, encabezados, cuerpo]`. Pero, ¿cómo representa los primeros dos pasos?. Bueno, la solicitud está representada en el parámetro `env`: contiene un `Hash` con toda la información que se pueda sacar de la línea de solicitud, los encabezados y el cuerpo de las solicitudes, __además__ de otras `variables de entorno` del servidor en el que estamos, que nos pueden ayudar. y ¿cómo _recibe_ las solicitudes? De eso se encarga `rackup`: cuando una solicitud entra al puerto `3000` (en este caso), agarra __la representación en texto de la solicitud__ y la interpreta como un `Hash`. Luego toma nuestra aplicación e invoca al método `call` con este `Hash` como parámetro y espera que le retornemos un arreglo que a su vez usará para construir __la representación en texto de la respuesta__.

Exploremos un poco nuestro entorno, editemos `app.rb`:

	#app.rb
	class WebApp
	  def call(env)
	  	lang = env['HTTP_ACCEPT_LANGUAGE'] || 'en'
	  	path = env['PATH_INFO']
	  	
	  	body = if lang == 'en'
	  		"you just asked for #{path}, \n with the env #{env.to_s}"
	  	else
	  		"acabas de pedir #{path}, \n con el entorno #{env.to_s}"
	  	end	
	  	
	    [200, {'Content-Type' => "text/plain"}, [body]]
	  end
	end

Ejecutémoslo

	rackup start.ru -p 3000

Y veámoslo en un browser o via curl con

	curl -H "Accept-Language: es" localhost:3000

Si te fijás, esta vez saldrá un `Hash` gigante con varias llaves en mayúsculas. Dedicale un tiempo a leerlo todo, a ver qué cosas interesantes encontrás.

Algunas cosas de interés que podrías ver:

* Hay algunas llaves que empiezan con `HTTP_`, esas suelen corresponder a información que va en los encabezados (por eso ves, por ejemplo, la llave `HTTP_ACCEPT_LANGUAGE` o la llave `HTTP_HOST`)
* Hay otras que empiezan con `REQUEST_`, que corresponden a la línea de solicitud, como `REQUEST_METHOD` o `REQUEST_PATH`
* Otras varias que corresponden a información útil de la solicitud, como `QUERY_STRING`
* Información específica del servidor mismo, como `SERVER_SOFTWARE`
* Información específica introducida por `rack`, como `rack.errors`, que suelen ser objetos de ruby que abstraen información "cruda" de la solicitud.

Como vemos, `env` contiene toda la información útil para construir respuestas, aunque esta está presentada de forma burda.

###guardando nuestro progreso

Ok, llegamos otra vez al punto en que tenemos algo funcionando. Hora de guardar nuestro progreso.

Ahora, la última vez aprendimos que le podemos preguntar a git qué cosas han cambiado desde la última vez que hicimos commit con `git status` (hacelo ahorita a ver qué cambió, quizá te diga que esta vez sólo modificaste `app.rb`). 

Ahora bien, ¿qué pasa si el `git status` no es suficiente, si no sólo queremos saber _qué_ cambió sino _cómo_ cambió?. En otras palabras, ¿qué pasa si queremos ver la __diferencia__ entre este momento y la última vez que hicimos un commit? La respuesta: `git diff`:

	git diff
	diff --git a/app.rb b/app.rb
	index b0b3226..c71f80d 100644
	--- a/app.rb
	+++ b/app.rb
	@@ -1,5 +1,14 @@
	 class WebApp
	   def call(env)
	-    [201, {'Content-Type' => "text/plain"}, ['Hola Rackup']]
	+    lang = env['HTTP_ACCEPT_LANGUAGE'] || 'en'
	+    path = env['PATH_INFO']
	+
	+    body = if lang == 'en'
	+             "you just asked for #{path}, \n with the env #{env.to_s}"
	+           else
	+             "acabas de pedir #{path}, \n con el entorno #{env.to_s}"
	+           end
	+
	+    [201, {'Content-Type' => "text/plain"}, [body]]
	   end
	 end 	
	 
Como podés ver, nos da la siguiente información:

* Las líneas precedidas por un signo menos (`-`) son __líneas que estaban allí en el último commit, pero que fueron borradas (o _sustitudas_)__
* Las precedidas por un signo `+` son las nuevas líneas que este cambio introducirá.

(si configuraste bien git y los colores de tu terminal funcionan, las líneas borradas te saldrán en rojo y las agregadas, en verde).

Ahora que ya sabés _qué_ cambiaste, podés hacer un nuevo commit:

	git add app.rb
	git commit -m 'explorando el entorno'
	
Una ayuda: esta rutina de agregar archivos que __ya conocía git__ y luego hacer commit es tan común que el comando git commit tiene la opción `-a`, que hace automáticamente el `git add` de archivos que ya conoce git (ojo: __no hace `git add` de archivos que estén `untracked`, es decir, que nunca le hayás presentado a git__), así que los últimos comandos podrían haber sido:

	git commit -am 'explorando el entorno'

#4. Empezando a funcionar

Hacer, con lo de env, lo de las quotes

introducir git branching

#5. Pausa: limpiando el código

Cambiarlo, en un branch, y luego hacer merge ¿cuándo introducir git reset/checkout?

