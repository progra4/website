#Sirviendo HTTP con ruby (y una introducción a git)

El propósito de esta guía es doble: que aprendamos lo básico de escribir un programa de servidor y que aprendamos a guardar nuestro progreso con [git](http://gitref.org/)

Para aprender a escribir programas de servidor, trataremos de reproducir una parte de la funcionalidad [del sitio que usamos para aprender http](http://httparty.heroku.com/) 

Todo el progreso del proyecto estará aquí:

<https://github.com/progra4/quotes>

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

##4. Empezando a funcionar: el asunto de los _modelos_

Hemos llegado hasta este punto y ya tenemos una idea de cómo funcionaría una aplicación web: en cada solicitud que recibe, reacciona de alguna forma al entorno y devuelve los elementos de una respuesta. Empecemos, entonces, a replicar la aplicación que queríamos reproducir.

Al diseñar una aplicación web, nos tenemos que hacer una simple pregunta:

__¿Cuáles son los recursos, cómo puedo ver esto en términos de recursos y su manipulación?__

Esa pregunta nos lleva a pensar en algunas otras, por ejemplo:

* ¿Qué URLs estarán involucradas en nuestro proyecto?
* ¿Cómo mostrar los recursos?
* ¿Cómo se podrán crear/modificar/destruir los recursos?
* ¿Cómo interactúan entre sí?

En este caso, la respuesta es fácil: __los recursos son las citas, se pueden mostrar en una lista o individualmente y cada cita se puede crear, actualizar o destruir__. Es la aplicación más sencilla posible, pero cualquier otra aplicación web sólo es una elaboración de este mismo concepto.

Empecemos con lo más fácil: asumiendo que ya existen las citas, ¿cómo mostraríamos una lista de éstas?

Primero, ¿cómo representamos las citas? Podríamos verlas como instancias de una clase `Quote`

Algo así:

	class Quote
		attr_accessor :author, :content, :language
		def initialize(author, content, language = 'en')
			@author = author
			@content = content
			@language = language
		end
	end

Nos queda el problema de cómo identificar __únicamente__ cada cita, podríamos identificarlas por su lugar en la lista, así serían la cita `1`, la `2`, etc. Pero ¿qué va a pasar cuando empecemos a borrar citas? Si borramos la cita `2`, la que estaba en el lugar `3` va a tomar su lugar y ¡ninguna va a tener el identificador que tenía antes! Podríamos complicarnos y hacer esto funcionar, pero, afortunadamente, hay otra salida fácil: números aleatorios únicos.

El concepto de un `uuid` (universally unique identifier) es el de asignar un identificador tal que nunca se vuelva a repetir (¡hablando de único!) y ruby 1.9.3 incluye el módulo `SecureRandom` que hace precisamente esto, probémoslo en irb:

	1.9.3p125 :001 > require 'securerandom'
	 => true 
	1.9.3p125 :002 > SecureRandom.uuid
	 => "75ba2061-1156-405d-a09a-f795ca32e110"

(obviamente a vos te va a salir algo diferente)

No es tan conveniente como tener un solo entero, pero es suficiente.

Agregemos este conocimiento a la clase `Quote`
	
	require 'securerandom'
	class Quote
		attr_accessor :author, :content, :language
		def initialize(author, content, language = 'en')
			@id = SecureRandom.uuid
			@author = author
			@content = content
			@language = language
		end
	end


Por último, necesitaríamos una forma de __representar__ una instancia de `Quote`, así que agreguemos un método `as_text`:

	class Quote
		def as_text
			  "
       		   #{id}.
        	  #{content}
              --#{author}
      		  "
		end
	end

Ahora bien, ya que vamos a estar creando citas, esta sintaxis es un poco tediosa:

	cita_1 = Quote.new("el autor", "el contenido")
	cita_2 = Quote.new("otro autor", "otro contenido")
	…
	cita_n = Quote.new("miles de autores", "miles de contenidos")
	citas = [cita_1, cita_2, …, cita_n]

Primero que todo, tenemos que estarnos acordandos del orden de los parámetros, y, luego, nos estamos repitiendo un poco.

Resolveríamos el primer problema si pudieramos hacer algo como

	cita1 = Quote.create(content: "el contenido", author: "el autor")
	
Y el segundo, si pudieramos hacer algo como

	citas = Quote.create([
		{content: "primer contenido", author: "primer autor"},
		{content: "segundo contenido", author: "segundo autor"}
	])
	
Para resolver dos problemas de un solo, agreguemos este __método de clase__:

	class Quote
	  def self.create(hash_or_array)
    	if hash_or_array.is_a?(Hash)
      		Quote.new(hsh[:author], hsh[:content], hsh[:language])
    	elsif hash_or_array.is_a?(Array) && hash_or_array.all?{|e| e.is_a?(Hash)}
      		hash_or_array.map{|h|  Quote.create(h)  }
    	end
  	  end
	end
	

De modo que nuestra lista inicial de citas se podría ver así:

	 QUOTES = Quote.create([
	      {
	        author: "Ralph Waldo Emerson",
	        content: "Every sweet has its sour; every evil its good.",
	        language: "en"
	      },
	
	      {
	        author: "Siddhartha Gautama",
	        content: "El dolor es inevitable pero el sufrimiento es opcional.",
	        language: "es"
	      },
	      {
	        author: "Walt Whitman",
	        content: "Be curious, not judgmental",
	        language: "en"
	      }
	  ])


Lo que acabamos de hacer, decidir qué recursos habría y cómo los representaríamos como objetos que existen para el servidor, se conoce como la _capa de datos_, o, __diseñar los modelos__. Cada clase que represente un recurso, entonces, es un _modelo_.

Por último, ya que estamos encapsulando el concepto de _modelo_, ¿dónde hemos de guardar los modelos que creemos? Podría ser un archivo o una base de datos, no importa; pero a nivel de ruby, es mejor verlos como guardados por la clase misma, así:

	class Quote
		@@instances = []
	end
	
La idea es que toda instancia que creemos quede "guardada" en un arreglo que será miembro de la clase.

Así que modificamos el constructor:

	class Quote
		def initialize(a, c, l)
		 #lo que ya estaba…
		 
		 @@instances << self
		end
	end
	
Y va a haber un par de operaciones que necesitaremos constantemente: obtener todas las citas y encontrar una cita específica (usando su identificador único). Así que agreguemos métodos de clase que usen ese arreglo:

	class Quote
		def self.all
			@@instances
		end
		
		def self.find(id)
			@@instances.find do |instance|
				instance.id == id
			end
		end
	end

Todo esto que acabamos de hacer lo podemos poner en un archivo aparte, llamémoslo `models.rb`, y es una perfecta excusa para usar un _módulo_ de ruby:

	require 'securerandom'
	module Models
	  class Quote
	    attr_accessor :author, :content, :language
	    attr_reader :id
	    
	    @@instances = []
	
	    def initialize(author, content, language = 'en')
	      @id = SecureRandom.uuid
	      @author = author
	      @content = content
	      @language = language
	      
	      @@instances << self
	    end
	
	    def as_text
	      "
	        #{id}.
	        #{content}
	        --#{author}
	      "
	    end
	
	    def self.create(hash_or_array)
	      if hash_or_array.is_a?(Hash)
	        hsh = hash_or_array
	        Quote.new(hsh[:author], hsh[:content], hsh[:language])
	      elsif hash_or_array.is_a?(Array) && hash_or_array.all?{|e| e.is_a?(Hash)}
	        hash_or_array.map{|h|  Quote.create(h)  }
	      end
	    end
	    
	    def self.all
			@@instances
		end
		
		def self.find(id)
			@@instances.find do |instance|
				instance.id == id
			end
		end
	  end
	  
	end
	
	#creemos unas cuantas por defecto
	 Models::Quote.create([
	      {
	        author: "Ralph Waldo Emerson",
	        content: "Every sweet has its sour; every evil its good.",
	        language: "en"
	      },
	      {
	        author: "Winston Churchill",
	        content: "We make a living by what we get, we make a life by what we give",
	        language: "en"
	      },
	      {
	        author: "Siddhartha Gautama",
	        content: "El dolor es inevitable pero el sufrimiento es opcional.",
	        language: "es"
	      },
	      {
	        author: "Walt Whitman",
	        content: "Be curious, not judgmental",
	        language: "en"
	      }
	  ])
	


Podemos probar todo en irb con:

	1.9.3p125 :001 > require './models'
	 => true 
	1.9.3p125 :002 > Models::Quote.all
	 => [#<Models::Quote:0x007fcd489cd930 @id="e0536489-04fd-4583-95b2-bd824acd7aee", @author="Ralph Waldo Emerson", @content="Every sweet has its sour; every evil its good.", @language="en">, #<Models::Quote:0x007fcd489cd688 @id="367f10a6-d27e-49e5-999f-32d23118223c", @author="Winston Churchill", @content="We make a living by what we get, we make a life by what we give", @language="en">, #<Models::Quote:0x007fcd489cd548 @id="e46cdc5b-004d-4956-8ab4-5d9785ec9653", @author="Siddhartha Gautama", @content="El dolor es inevitable pero el sufrimiento es opcional.", @language="es">, #<Models::Quote:0x007fcd489cd408 @id="3c086c85-f865-4241-8a0f-81cabd0ef5f5", @author="Walt Whitman", @content="Be curious, not judgmental", @language="en">] 
	 
	
###grabando nuestro progreso

Esta vez no tocamos los archivos de nuestro proyecto que git ya conoce (asegurate con `git status` y `git diff`), así que sólo haremos esto:

	git add models.rb
	git commit -m 'creando los modelos'
	
Pero, en el siguiente cambio que hagamos, vamos a cambiar radicalmente el archivo `app.rb`. Si te da miedo lo que pueda pasar, git tiene una solución para eso: [branches](http://learn.github.com/p/branching.html): "versiones alternativas" de nuestro proyecto. La idea de un _branch_ es partir desde un punto conocido, experimentar un rato y, si no funciona, volver al punto conocido (y, si funciona, implementar el experimento). 

En git uno siempre está trabajando sobre un branch, el nombre por defecto es `master`.  Los branches pueden tener nombres descriptivos, como `experimento`, que determinen de qué se trata toda la historia que representan. 

Creemos el branch `controladores` (de eso se trata lo que sigue):

	git branch controladores
	git checkout controladores
	git branch
		* controladores
  		master

Cuando enviamos un parámetro al comando `git branch`, él crea un `branch` que parte de  la rama actual. El comando `git checkout` nos permite cambiarnos de branch y el comando `git branch` sin parámetros, nos permite ver los branches que existen (marca el actual con un asterisco )


Ahora, cualquier commit que hagamos, quedará en la historia del branch `controladores`, si nos arrepentimos de lo que hicimos allí, podríamos volver a `master` y todo estaría como lo dejamos antes de irnos a `controladores`

##5. Volviendo a la web: mostrando una colección de modelos o un modelo individual


Ahora que resolvimos el problema de representar los recursos (_modelos_) en esta aplicación, veamos cómo representarlos como parte de una respuesta HTTP.

Ahora trataremos con el concepto de __controlador__: no es más que código que está al tanto de las _solicitudes_ y los _recursos_, y que sabe cómo, en respuesta a las primeras, puede manipular los segundos.

Lo que nosotros queremos, primero que todo, es código que tome la lista de modelos y la devuelva en una respuesta. Hagamos eso:

	require './models'
	
	class WebApp
	  def call(env)
	    method = env["REQUEST_METHOD"]
	    status, body = case method
	      when "GET"
	        [200, Models::Quote.all.map(&:as_text).join("\n")]
	      else
	        [405, ""]
	      end
	
	    [
	     status,
	     #los valores de los headers *deben* ser String
	     {'Content-Type' => 'text/plain', 'Content-Length' => body.size.to_s},
	     [body]
	    ]
	  end
	end

Como ves, estamos usando el entorno para saber qué método se ha usado y estamos respondiendo con encabezados útiles (agregamos `Content-Length` para que el cliente sepa cuántos bytes tiene el cuerpo de la respuesta)

No esperemos más y __guardemos nuestro progreso hasta ahora__: 


	git commit -am 'mostrando toda la lista de modelos'


Lo siguiente que se debería poder hacer, es mostrar una sola cita, pero aquí tenemos dos problemas: ¿cómo sabemos qué cita se está pidiendo? y ¿cómo diferenciamos cuando se trate de _obtener_ una cita de cuando se trate de _obtener_ toda la lista?

Usamos expresiones regulares:

	require './models'
	class WebApp
	  def call(env)
	    method = env["REQUEST_METHOD"]
	    path   = env["REQUEST_PATH"]
	
	    collection_pattern = /\/quotes$/
	    member_pattern     = /\/quotes\/([a-z0-9\-]+)/
	
	    status, body = case method
	      when "GET"
	        if path =~ collection_pattern
	          [200, Models::Quote.all.map(&:as_text).join("\n")]
	        elsif path =~ member_pattern
	          id = path.match(member_pattern)[1]
	          quote = Models::Quote.find(id)
	          if quote
	            [200, quote.as_text]
	          else
	            [404, ""]
	          end
	        else
	          [501, "Not Implemented"]
	        end
	      else
	        [405, ""]
	      end
	
	    [
	     status,
	     #los valores de los headers *deben* ser String
	     {'Content-Type' => 'text/plain', 'Content-Length' => body.size.to_s},
	     [body]
	    ]
	  end
	end

Guardemos nuestro progreso:

	git commit -am 'obteniendo o la colección o un miembro'

###regresando a `master`

Como nuestro progreso en la branch `controladores` se ve satisfactorio, estamos listos para regresar a `master`. Podemos, antes, ver en qué han cambiado con 

	git diff master controladores
	
Que mostrará como adiciones todo lo que se introduzca en la branch `controladores` respecto a `master`

Para unir los cambios que hicimos aquí, regresemos a master

	git checkout master
	
Y unámoslos con el comando `git merge`

	git merge controladores
	
Y ahora, si vemos `git log`, veremos las dos historias unidas.

##6. Abstrayendo los controladores

En cuanto encontrés código donde hay demasiadas condiciones anidadas, hacé una pausa y ve cómo podés mejorar la situación. En este caso, vamos a crear algunos métodos que nos ayuden a separar las cosas.

En primera, vamos a usar la clase [`Rack::Request`](http://rack.rubyforge.org/doc/Rack/Request.html) para abstraer el comportamiento de las solicitudes. 

Luego, introduciremos el concepto de un método "enrutador" (_router_) para tratar con las distintas rutas posibles.

Como recordarás de la clase, en la representación con URL de los recursos, usualmente encontramos estas dos formas de URL:

* __colección__: representa a una _lista_ de recursos, el contendedor. En este caso, la url de colección será `/quotes`
* __miembro__: representa a un miembro de una colección de recursos, usualmente, incluye algo que lo identifique únicamente, en este caso, las URL de miembros se verán algo así: `/quotes/7cbcdff2-8175-4ce9-87fe-428ddb0cf731`

Por eso es que arriba usamos expresiones regulares:

La expresión `/\/quotes$/` corresponde a la URL de colección, y se puede interpretar así: "cualquier string que empiece con una pleca (en la expresión regular hubo que escapar la pleca), seguida de la palabra quotes y _allí termine_ (por eso usamos el signo de dólar, éste indica que allí debería estar el final de la cadena)"

Asimismo, la expresión `/\/quotes\/([a-z0-9\-]+)/` corresponde a la URL de miembro: "cualquier string que empiece con pleca, seguida de la palabra quotes, seguida de otra pleca y luego -considerando esto como un grupo, por eso los paréntesis- cualquier letra entre la a y la z, cualquier número entre 0 y 9 y el caracter guión, todo esto repetido una o más veces (las opciones las indicamos encerrándolas entre corchetes, y esa repetición la indicamos con el signo `+`)"

Ahora que ya sabemos qué _rutas_ posibles hay, veamos cómo se combinan con los verbos de HTTP:

* `GET /quotes` equivale a obtener toda la colección, llamaremos a esta acción `index`
* `POST /quotes` equivale a crear un recurso dentro de la colección, llamaremos a esta acción `create`
* `GET /quotes/1` equivale a mostrar un recurso miembro particular, llamaremos a esta acción `show`
* `PUT /quotes/1` equivale a actualizar un recurso: `update`
* `DELETE /quotes/1` equivale a destruir un recurso: `destroy`

Cualquier otra combinación verbo + ruta no tiene semántica en este caso (por ejemplo, no se suele destruir toda la colección, así que `DELETE /quotes` no ha de ocurrir). En estos casos, deberíamos devolver una respuesta con código de estado `405 Method Not Allowed`.

Con este conocimiento, este método podría verse así:

	  def route(request)
	    collection_pattern = /\/quotes$/
	    member_pattern     = /\/quotes\/([a-z0-9\-]+)/
	
	
	    #collection actions
	    if request.path =~ collection_pattern
	      if request.get?
	        return index(request)
	      elsif request.post?
	        return create(request)
	      else
	        return [405, ""]
	      end
	    end
	    
	    #member actions
	    if request.path =~ member_pattern
	      if request.get?
	        # show <=> read
	        return show(request)
	      elsif request.put?
	        return update(request)
	      elsif request.delete?
	        return destroy(request)
	      else
	        return [405, ""]
	      end
	    end
	
	    #a not implemented path was requested
	    return [501, ""]
	  end

Si te fijás, usamos `return` para salir en cuanto encontremos la ruta correcta. Aquí se asume que el parámetro `request` es una instancia de `Rack::Request`

Agregaremos otro método llamado `dispatch` que se encargue de tomar una solicitud y mandarla al router, pero que, además, se encargue de dos casos comunes: cuando un recurso no es encontrado y cuando hay un error:

	  def dispatch(request)
	    begin
	      route request
	    rescue NotFoundException
	      [404, ""]
	    rescue
	      [500, ""]
	    end
	  end
Este método asume la existencia de una clase de excepción llamada `NotFoundException`, que se puede definir así:

	class NotFoundException < Exception; end
	
Lo último que nos queda es definir los métodos que el método `route` asume que existen. En el último ejemplo, teníamos algo equivalente a los métodos `index` y `show`, así que implementemos esos

	def index(request)
      [200, Models::Quote.all.map(&:as_text).join("\n")]
    end

    def show(request)
      quote = Models::Quote.find(request.params["id"])
      if quote
        [200, quote.as_text]
      else
        raise NotFoundException
      end
    end

La gran pregunta es, ¿dónde ponemos estos métodos? Podríamos poner todo dentro de la clase `WebApp`, pero, así abstractos, ¿no sería mejor ponerlos en su propia clase?

Esta clase podría verse así:

	class QuotesController
		def dispatch(request)
			#…
		end
		
		def route(request)
			#…
		end
		
		def get(request)
			#...
		end
		
		def index(request)
			#…
		end
	end
	
Pero, si te fijás, los métodos `dispatch` y `route` son bastante genéricos y no podrían usarse sólo para este caso, así que podríamos ponerlos (generalizarlos) en una super-clase:
	
	class Controller
	    def route(request)
	      collection_pattern = /\/#{resource_name}$/
	      member_pattern     = /\/#{resource_name}\/([a-z0-9\-]+)/
	
	
	      puts request.path
	      puts collection_pattern, member_pattern
	      #collection actions
	      if request.path =~ collection_pattern
	        if request.get?
	          return index(request)
	        elsif request.post?
	          return create(request)
	        else
	          return [405, ""]
	        end
	      end
	      
	      #member actions
	      if request.path =~ member_pattern
	        request.params["id"] = request.path.match(member_pattern)[1]
	        if request.get?
	          # show <=> read
	          return show(request)
	        elsif request.put?
	          return update(request)
	        elsif request.delete?
	          return destroy(request)
	        else
	          return [405, ""]
	        end
	      end
	
	      #a not implemented path was requested
	      return [501, ""]
	    end
	
	
	    def dispatch(request)
	      begin
	        route request
	      rescue NotFoundException
	        [404, ""]
	      rescue
	        [500, ""]
	      end
	    end
	  end

Y así, la clase `QuotesController` se reduciría a esto:

	class QuotesController < Controller
	    include Models
	
	    def resource_name
	      "quotes"
	    end
	
	    def index(request)
	      [200, Quote.all.map(&:as_text).join("\n")]
	    end
	
	    def show(request)
	      quote = Quote.find(request.params["id"])
	      if quote
	        [200, quote.as_text]
	      else
	        raise NotFoundException
	      end
	    end
	  end
Y todo esto podríamos agruparlo dentro de un solo módulo:
	
	require './models'
	module Controllers
		include Models
		class NotFoundException < Exception; end
		
		class Controller
			#…
		end
		
		class QuotesController
			#...
		end
	end

Fijate en la línea `include Models`: la instrucción `include` toma todas las constantes de un módulo y las incluye en el contexto actual. Por eso, en la versión final de esta etapa (que podés ver aquí <https://github.com/progra4/quotes/tree/a32334522aaf981222ab03f5f87ce5c88ae3ba74>), usamos la clase `Quote` en vez de decir `Models::Quote` y por eso, en la clase `WebApp`, al incluir el módulo `Controllers` se puede uno referir a `QuotesController` en lugar de `Controllers::QuotesController`

Por último, si te fijás el parámetro `request` está en casi todas esas funciones, sería más conveniente que lo incluyéramos en el constructor de `Controller` para que fuera una propiedad que estuviera disponible a todos los métodos, ese cambio lo podés ver aquí: <https://github.com/progra4/quotes/tree/4838f7fddb157304aba4b9ed0057fce4e40838e8>

En última instancia, haremos el método `create` que cree una nueva cita, para ver cómo usar el cuerpo de la solicitud. Te queda de ejercicio hacer los métodos `update` y `destroy`.

##Extra: sincronizando tu repositorio git con un remoto

Hasta ahora has guardado todo tu progreso en tu computadora local. ¿Qué pasaría si un día te despertás y tu computadora no encience, o si se te cae en lava ardiente en los volcanes siempre activos de hawaii? Puede pasar. Y, sin computadora, de nada sirve que tengás toda tu historia bien organizada con git.

Lo mejor sería, entonces, que hubiera una copia de tu historia en ¡algún lugar mágico de __internet__!

Y para eso está [github.com](http://github.com). Vos deberías haber creado una cuenta allí, podés crearla en este enlace: <https://github.com/signup/free> .

Una vez que creés tu cuenta y estés autenticado en github.com, vas a poder crear tus propios _repositorios_ allí, un repositorio es simplemente un proyecto.

Para crear un repositorio, andá a esta URL: <https://github.com/new> y vas a ver algo como esto.


![](https://img.skitch.com/20120503-2qnr5awrnqufwttc81w8jnxnb.jpg)

Una vez que des click en `Create Repository`, vas a ver algo como esto:

![](https://img.skitch.com/20120503-1w32gnqygqpd33qbf18y3bqtkc.jpg)

(en este ejemplo, mi usuario se llama `rest-apis` y el repositorio `ejemplo_git`)

__Advertencia__: todos los repositorios que creés son por defecto públicos, es decir, que cualquiera puede ver tu código. Github te permite crear repositorios privados (que sólo vos y la gente que elijás pueda ver) pero suele cobrar por ese servicio. Sin embargo, si te interesa tener repositorios privados en git y no querés pagar por ello, podés decirles que sos un estudiante (incluso podés decirles que sos de la clase que tiene repositorio en <http://github.com/progra4>), para decirles que sos estudiante y ver si te permiten crear repositorios gratis, contactalos aquí: <https://github.com/edu> (da click en `I'm a student`)

Si te fijás, ahí te da las instrucciones para un `Existing git repo`, que es nuestro caso, porque vos ya tenés creado tu repositorio. Lo que vamos a hacer ahora es hacerle saber a nuestro repositorio que puede ser sincronizado con una copia remota:

	git remote add origin git@github.com:TU_USUARIO/TU_REPOSITORIO
	
(ojo que `TU_USUARIO` y `TU_REPOSITORIO` dependen de cuál es tu nombre de usuario y qué nombre le pusiste al repositorio.)

Y lo que le estás diciendo a git es: "te aviso que vas a tener una copia remota y le llamaré `origin`", `origin` es sólo un nombre convencional, puede ser cualquier otra cosa.

De aquí en adelante, cada vez que querás que los commits que tenés localmente se guarden en tu copia remota, usá este comando:

	git push origin master
	
Y aquí estás diciendo: "quiero subir los cambios que tengo hasta ahorita en el branch `master` a mi copia remota que se llama `origin`" (porque podés tener varios branches y varias copias remotas).

Una vez que hagás el `git push`, vas a poder entrar a tu repositorio y ver los archivos y la lista de cambios (hay una pestaña que dice `commits`).

##Más información sobre git

Algunos recursos sobre git que a los que podés acudir para profundizar en esto:

* [The git parable](http://tom.preston-werner.com/2009/05/19/the-git-parable.html)
* [learn.github](http://learn.github.com/p/intro.html)
* [gitref](http://gitref.org/)
* [Pro Git](http://progit.org/book/)
* [Git community book](http://book.git-scm.com/)

