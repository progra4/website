#Ruby y HTTP

##1. Clientes: produciendo solicitudes, consumiendo respuestas

Para consumir servicios HTTP, usaremos la librería `Net::HTTP` que ya viene con ruby.

##2. Servidores: consumiendo solicitudes, produciendo respuestas

Un programa de lado del servidor no es más que un script que siempre está escuchando a ver si le llegan solicitudes. Para escribir nuestros propios scripts que hagan esto, usaremos una librería llamada [rack](http://rack.rubyforge.org/). Para instalarla, corré esta línea

	gem install rack
	
Las reglas de rack son:

1. Una aplicación consiste en un objeto que responda al método `call` 
2. El método recibirá un sólo parámetro: el entorno, que contiene a la solicitud y todas las variables del servidor necesarias para poder responder bien (encabezados, cuerpo de la solicitud, etc.)
3. El método deberá retornar un arreglo para construir con él la respuesta: el código de estado, los encabezados y un iterable (algo que responda a `each`) para construir el cuerpo

Bajo esas reglas, la aplicación más sencilla para rack se vería así:


	lambda do |env|
		[200, {}, ['Hola Mundo']]
	end
	
Un objeto `lambda` es una instancia de la clase `Proc`. La clase `Proc` define el método `call` (nos referimos así al método `Proc#call`).

Obviamente, para hacerla funcionar, hay que poner un par de instrucciones extra: importar rack y decirle al script que se quede escuchando solicitudes y responda usando nuestra función:

	require 'rack'
	h = lambda do |env|
		[200, {}, ['Hola Mundo']]
	end
	Rack::Handler::WEBrick.run(h, Port: 3000)
	
Una convención que hay es usar una clase en lugar de un `lambda`, en esa clase definimos el método call y le damos a `rack` una instancia de ella, así:

	class WebApp
	  def call(env)
	    [200, {}, ['Hola Mundo']]
	  end
	end
	Rack::Handler::WEBrick.run(WebApp.new, Port: 3000)

Una convención más que se usa es tener dos archivos: uno dedicado al código de la aplicación y otro como "entrada" para el servidor. Este último se conoce como el `rackup`, probemos eso:

	#app.rb
	class WebApp
	  def call(env)
	    [200, {'Content-Type': "text/plain", ['Hola Rackup']}]
	  end
	end
	
	#start.ru
	require './app'
	run WebApp.new
	
Para correr una app con un archivo para `rackup`, usamos el comando `rackup` que rack instaló por nosotros:

	rackup -p 3000 start.ru
	
