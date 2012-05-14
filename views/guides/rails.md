#El Tao de Rails

De ahora en adelante usaremos [Ruby on Rails](http://rubyonrails.org/) para crear aplicaciones web. Ruby on Rails (llamémoslo RoR de ahora en adelante), es un _framework_: abstrae prácticas comunes y usa convenciones para hacer más rápido el desarrollo. Hoy haremos nuestra primera aplicación en ruby on rails.

En esta ocasión, estaremos haciendo la aplicación que quedó para el primer examen: un pequeño administrador de proyectos. Vamos a poder crear tareas (`tasks`) que estén asignadas a usuarios (`users`) y vamos a permitir a los usuarios __autenticarse__. Haremos cada una de estas cosas en una iteración aparte. Esta guía está influenciada por [esta guía en jumpstartlabs](http://tutorials.jumpstartlab.com/projects/blogger.html) y el [railstutorial](http://ruby.railstutorial.org/ruby-on-rails-tutorial-book) 


##git ready

Todo el progreso de este proyecto será parte de tu evaluación. Para ello, esta vez te tocará hacer a vos una copia de este repositorio y trabajar sobre ella. 

El repositorio original vivirá acá:

<https://github.com/progra4/tasks_app>


Veamos cómo:

Usaremos algo llamado `fork`: crea una copia del repositorio original (`progra4/tasks_app`) y la guardará en tu cuenta personal (mi nombre es `lfborjas`, así que lo guardará en `lfborjas/tasks_app`), para hacer eso, es tan simple como dar click en el botón fork de la página del proyecto (señalado con una flecha):

![https://img.skitch.com/20120514-g9ydhtthq48stema91bcqmr2k1.jpg](fork)

Y, una vez que lo copiés, deberías ver algo similar a esto (notá la URL):

![https://img.skitch.com/20120514-dh1rkr8qfugbchk3bajj1tfnie.jpg](hardcore_forking)

Que desaparecerá después de unos segundos y te mostrará el mismo listado de archivos que el proyecto original.

Ahora,  __desde tu copia__, podés hacer un `git clone`.

Una vez que hagás un git clone, se espera que tengás __al menos un commit__ por cada iteración/cambio significativo. En clase decidiremos qué será cada tarea.




##Preliminares

Si es la primera vez que usás ruby on rails, vas a tener que instalar [sqlite](http://www.sqlite.org/) y el [gem de rails](http://rubygems.org/gems/rails/versions/3.2.3) (estaremos usando la versión `3.2.3`), asimismo, instalaremos el [gem de heroku](http://rubygems.org/gems/heroku/versions/2.25.0) para hacer nuestra aplicación públicamente accesible.

Para instalar `sqlite` en __linux__, hacé lo siguiente:

    sudo apt-get install sqlite3 libsqlite3-dev

Para instaler `sqlite` __mac OSX__ (asumiendo que tenés [homebrew](http://mxcl.github.com/homebrew/) instalado):

    brew install sqlite
    
##Iteración 0. Creando la aplicación

Rails gira en torno a la terminal: tanto para crear una aplicación nueva como para agregar modelos o controladores, todo está basado en [utilidades de línea de comandos](http://guides.rubyonrails.org/command_line.html). Los comandos _universales_ (que funcionarían en cualquier aplicación) usan el comando `rails`, los que dependen del proyecto (como por ejemplo, hacer algo en la base de datos específica del proyecto), usan el comando `rake`

Cuando querés crear una aplicación nueva en rails, usás el comando `rails new` seguido del nombre del proyecto:
  
    rails new tasks
    
Esto creará la carpeta `tasks` y mostrará varias líneas que comienzan por `create`:

      create  
      create  README.rdoc
      create  Rakefile
      create  config.ru
      create  .gitignore
      create  Gemfile
      create  app
      …
      
Y otras tantas líneas que demuestran que se están instalando las _gems_ de las que depende rails:

    run  bundle install
    Fetching gem metadata from https://rubygems.org/.........
    Using rack (1.4.1) 
    Installing i18n (0.6.0) 
    Installing multi_json (1.3.5) 
    …

    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed


Dos cosas a notar ahí: rails crea un _montón_ de carpetas y archivos, pero prestémosle atención a algunos de ellos:

* __config.ru__: el archivo que usará `rack` para iniciar el servidor.
* __Gemfile__: el archivo donde declaramos todas las dependencias de nuestro proyecto, para declarar una dependencia usás `gem <DEPENDENCIA>` y las instalás usando [bundler](http://gembundler.com/) con el comando `bundle install`. Así, hay un solo lugar donde estarán todas las gems de tu proyecto.
* La carpeta `app`: aquí están agrupados todos los `models`, `views` y `controllers` de tu proyecto, es donde más trabajaremos
* La carpeta `config`: aquí están diversas configuraciones/personalizaciones de tu proyecto, en especial, un par de archivos importantes:
    *  `routes.rb`, define los _paths_ (rutas), y que cumple con el concepto de `router/dispatch` que habíamos discutido previamente.    
    * `database.yml`: contiene la configuración para la base de datos
* La carpeta `db`, que contiene lo relacionado a la base de datos. En el archivo `db/schema.rb` encontraremos los campos que tienen los modelos.


Usualmente, luego de crear un proyecto en rails, queremos seguirlo con `git`, así que podemos hacer esto:

    git init 
    git add .
    git commit -m "creado el proyecto en rails"
    
Si te fijás, `rails` generó el archivo `.gitignore` que tiene reglas que definen qué archivos debería ignorar git (hay archivos que nunca queremos tener, como archivos temporales que editores como gedit crean)


Una vez que creés el proyecto, podés levantar el servidor usando el comando `rails server`

    rails server
Y vas a ver algo similar a esto, si todo sale bien

    => Booting WEBrick
    => Rails 3.2.3 application starting in development on http://0.0.0.0:3000
    => Call with -d to detach
    => Ctrl-C to shutdown server
    [2012-05-13 23:56:27] INFO  WEBrick 1.3.1
    [2012-05-13 23:56:27] INFO  ruby 1.9.3 (2012-02-16) [x86_64-darwin11.3.0]
    [2012-05-13 23:56:27] INFO  WEBrick::HTTPServer#start: pid=15206 port=3000
    
Si te fijás, hace exactamente lo mismo que hacíamos antes con `rackup start.ru -p 3000`, pero esta vez es un comando más estándar y más corto.

Una vez que hagás eso, podrías ir a <http://localhost:3000> y verías algo como esto:

![https://img.skitch.com/20120514-jxfghu4xnditq3arxucidy2fq2.jpg](riding_rails)


##Iteración 1: Tasks

###1. Modelos

Como ya sabemos, la parte central de muchas aplicaciones web son los modelos, así que concentrémonos en eso primero.

En rails, todo empieza con un [generador](http://railscasts.com/episodes/216-generators-in-rails-3): vos podrías agregar manualmente el archivo que representará la clase de tu modelo a la carpeta `app/models` y agregar el archivo que creará la tabla de tu modelo a la carpeta `db/migrate`, pero es tedioso escribir y memorizar tanto código y pasos, así que podés usar el generador de modelos (`rails generate model`) para que te ayude.

Para generar un modelo, usualmente le decís cómo se llamará y qué propiedades tendrá. En este momento, nuestras tareas tendrán sólo una descripción y prioridad, nos ocuparemos del responsable en la siguiente iteración. Así que lo haremos con este comando

    rails generate model Task description:string priority:integer
    
Si te fijás, después del nombre del modelo ponemos las propiedades con el tipo que han de tener. Este tipo es útil para la base de datos.


Deberías ver algo similar a esto:

      invoke  active_record
      create    db/migrate/20120514062804_create_tasks.rb
      create    app/models/task.rb
      invoke    test_unit
      create      test/unit/task_test.rb
      create      test/fixtures/tasks.yml

Ahí te dice qué archivos creó. Los que nos importan son el que está en `db/migrate`
 y el que está en `app/models`. Hablemos un poco de la migración ahorita.
 
####Migraciones

En una aplicación hecha en RoR se asume que vas a guardar las cosas en una base de datos, ¿qué es una base de datos? Un archivo glorificado: contiene tablas que representan un objeto; las columnas representan las propiedades del objeto y las filas representan instancias de cada objeto. Los programas que se encargan de gestionar bases de datos de este tipo se conocen como _relational database management systems (RDBMS)_ y los más famosos en el mundo opensource son: [mySQL](http://www.mysql.com/), [postgreSQL](http://www.postgresql.org/) y [sqlite](http://www.sqlite.org/) (pero sqlite no es un RDBMS de verdad! Sólo sirve para usarlo como base de datos local porque es un programa liviano y no presenta inconvenientes, ¡nunca lo usés en un sitio de verdad!). Nosotros estamos usando acá sqlite, y si te fijás, eso está declarado en el archivo `config/database.yml`.

Pues bien, ahora que sabés sobre los RDBMS, tenés que saber que uno interactúa con ellos usando un lenguaje declarativo llamado [SQL](http://en.wikipedia.org/wiki/Sql), y una de las cosas que uno hace con SQL es decirle al RDBMS "mirá, voy a tener una tabla con tales y tales columnas de tales y tales tipos". Este tipo de instrucciones se puede perfectamente [hacer](http://dev.mysql.com/doc/refman/5.1/en/create-table.html) [manualmente](http://dev.mysql.com/doc/refman/5.1/en/alter-table.html). Pero estas instrucciones, además de difíciles, pueden variar de un RDBMS a otro. Pero no temás, ¡rails es tu amigo! Y aquí entra el concepto de __migración__: una migración es un script en ruby que crea o modifica tabla en el RDBMS. Así que cada vez que creés un modelo (decidás qué propiedades tendrá) o querás agregar o quitar una propiedad de un modelo, en vez de hacerlo directamente con el RDBMS, harás una migración. Por ejemplo, la migración que acabamos de crear (el archivo que está en `db/migrate` cuyo nombre termina en `create_tasks.rb`) se ve así:

    class CreateTasks < ActiveRecord::Migration
      def change
        create_table :tasks do |t|
          t.string :description
          t.integer :priority
    
          t.timestamps
        end
      end
    end

Si te fijás, se puede leer más o menos en inglés: "crear la tabla _tasks_ y dentro de ella: habrá una columna _string_ que sea la descripción y una columna _integer_ que sea la prioridad". También agregó una línea que dice `timestamps`. Los timestamps son dos columnas: `created_at` y `updated_at` que rails agrega por defecto a todas las tablas, son útiles para saber cuándo se creó y guardó una instancia o cuando se modificó una instancia, respectivamente. Una cosa a notar es la convención que __creamos los modelos en singular (`Tasks`) pero las tablas tendrán el nombre en plural (`tasks`)__.

Ahora bien, este archivo sólo __declara__ qué hará la migración, pero aún no hemos hablado con la base de datos. Para que la migración se aplique, vas a correr un comando específico a tu aplicación (recordá que esos se corren con `rake`)

    rake db:migrate
    
Y si todo sale bien, verás algo como esto:

    ==  CreateTasks: migrating ====================================================
    -- create_table(:tasks)
       -> 0.0012s
    ==  CreateTasks: migrated (0.0013s) ===========================================

Y, después de esto, después de que la tabla se haya creado en la base de datos, vas a fijarte que existe un nuevo archivo: `db/schema.rb`, este refleja la estructura actual de la base de datos (cuándo fue la última vez que cambió, qué tablas hay y qué columnas contienen), ahorita se ha de ver así:

    ActiveRecord::Schema.define(:version => 20120514062804) do
    
      create_table "tasks", :force => true do |t|
        t.string   "description"
        t.integer  "priority"
        t.datetime "created_at",  :null => false
        t.datetime "updated_at",  :null => false
      end
    
    end
    
Si te fijás, `:version => 20120514062804` se refiere a la fecha, hora, minutos, segundos y milisegundos en que fue modificada la estructura de la base de datos por última vez (va a ser diferente para vos) y abajo hay algo similar a una migración, con todas las tablas y columnas. 

Algo interesante a notar es la propiedad `:null => false` en las columnas `created_at`, esto es un _constraint_ que significa que el valor de esta columna nunca debería estar vacío (de todas formas vos no vas a llenarlos prácticamente nunca, estos atributos los maneja rails automáticamente, sólo preocupate por las columnas que vos creés explícitamente).

Podés ver a los archivos en `db/migrate` como la intención de cambiar la base de datos y al archivo `db/schema` como el resultado de haber seguido esa intención.

Otra cosa que tenés que saber, aunque no salga en ninguno de los dos archivos anteriores

Ok, ahora que sabemos todo sobre las migraciones, veamos qué hay en nuestro modelo (en el archivo `app/models/Task.rb`):

    class Task < ActiveRecord::Base
      attr_accessible :description, :priority
    end

Si te fijás, no hay mucho: todos los métodos interesantes están en la superclase `ActiveRecord::Base`, dentro de poco jugaremos con ellos. Una cosa que te podés fijar es en el uso del método `attr_accessible`: no lo confundás con `attr_accessor`, que es un método de ruby, `attr_accessible` es un método de la librería `ActiveRecord` de rails y lo que significa es que estos atributos (`description` y `priority`) pueden ser modificados directamente por vos. Los atributos que no estén aquí listados no pueden ser cambiados (por ejemplo, los atributos `created_at` y `updated_at` no los podés modificar a través de métodos como `create` o `update`, estos métodos, que discutiremos dentro de poco, se conocen como métodos de __mass assignment__). Este modelo es similar a lo que hemos estado haciendo: representa un recurso, lo que podemos hacer con los recursos y se encarga de guardarlo en la base de datos y sacarlo de allí cuando lo necesitemos. 


####Jugando con los modelos

Como recordarás, a veces nos convenía probar las clases que hacíamos en `irb` para ver si funcionaban como esperábamos, usualmente abríamos una sesión de `irb` y escribíamos unos cuantos `require` para importar nuestras clases. En rails hay una convención divertida: __no te toca importar prácticamente nada, todo se importa automáticamente al iniciar el servidor (o, como lo llama la gente de rails, _loading the environment_)__. Y rails te ayuda hasta en la consola, dándote el comando `rails console`

    rails console

Que carga una sesión de `irb` pero con todo tu "entorno" ya cargado. Escribilo, y verás algo como esto:

    Loading development environment (Rails 3.2.3)
    1.9.3p125 :001 >

Vamos a hacer una rápida sesión para ver qué encontramos:

    1.9.3p125 :001 > Task
     => Task(id: integer, description: string, priority: integer, created_at: datetime, updated_at: datetime)
     
Rails tiene la decencia de cambiar el método `inspect` de la clase `ActiveRecord::Base` para mostrar todas las columnas que tiene la tabla. Como te decía, además de las dos que vos declaraste, agrega automáticamente a __todos__ los modelos los atributos `id`, `created_at` y `updated_at`.

    1.9.3p125 :002 > Task.all
      Task Load (0.3ms)  SELECT "tasks".* FROM "tasks" 
     => [] 
Aquí, muy interesantemente, nos está mostrando cómo el método `all` usa SQL para buscar _todas_ las instancias de la clase `Task` en la tabla `tasks` de la base de datos. Al final nos devuelve un arreglo vacío, como es de esperar.

Probemos crear una instancia de `Task`:

    1.9.3p125 :003 > i = Task.new(description: "aprender rails", priority: 10)
     => #<Task id: nil, description: "aprender rails", priority: 10, created_at: nil, updated_at: nil>
     
Tomá nota que esto __sólo creó la instancia__, pero no la ha guardado en la base de datos: por eso no le ha asignado un `id`, ni los timestamps. De modo que correr `Task.all` en este punto nos seguirá dando un arreglo vacío. Guardemos esta instancia a la base de datos usando el método `save`:

    1.9.3p125 :005 > i.save
       (0.2ms)  begin transaction
      SQL (91.7ms)  INSERT INTO "tasks" ("created_at", "description", "priority", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Mon, 14 May 2012 07:32:22 UTC +00:00], ["description", "aprender rails"], ["priority", 10], ["updated_at", Mon, 14 May 2012 07:32:22 UTC +00:00]]
       (3.0ms)  commit transaction
     => true 
     
Incluso podés cambiar atributos de la instancia y volver a grabarla

    1.9.3p125 :014 > i.priority = 6
     => 6 
    1.9.3p125 :015 > i.save
       (0.1ms)  begin transaction
       (0.4ms)  UPDATE "tasks" SET "priority" = 6, "updated_at" = '2012-05-14 07:42:52.258642' WHERE "tasks"."id" = 1
       (46.7ms)  commit transaction
     => true
     
(notá que esta vez usó la sentencia SQL `UPDATE` en lugar de `CREATE`, porque la fila ya existe en la base de datos)

Una vez más, rails nos explica qué pasos está tomando para hablar con el RDBMS, y, si logra guardar la instancia, nos devuelve `true`. Si volvemos a tratar de obtener todas las instancias:

    1.9.3p125 :006 > Task.all
      Task Load (0.3ms)  SELECT "tasks".* FROM "tasks" 
     => [#<Task id: 1, description: "aprender rails", priority: 10, created_at: "2012-05-14 07:32:22", updated_at: "2012-05-14 07:32:22">]
     
Tendremos, esta vez, un arreglo con un solo elemento. Probemos crear otra instancia, esta vez con el método `create`:

    1.9.3p125 :007 > Task.create(description: "pasar la clase", priority: 6)
       (0.1ms)  begin transaction
      SQL (0.6ms)  INSERT INTO "tasks" ("created_at", "description", "priority", "updated_at") VALUES (?, ?, ?, ?)  [["created_at", Mon, 14 May 2012 07:34:28 UTC +00:00], ["description", "pasar la clase"], ["priority", 6], ["updated_at", Mon, 14 May 2012 07:34:28 UTC +00:00]]
       (2.8ms)  commit transaction
     => #<Task id: 2, description: "pasar la clase", priority: 6, created_at: "2012-05-14 07:34:28", updated_at: "2012-05-14 07:34:28"> 
     
Si te fijás, este método hace la instancia y la guarda _en un solo paso_ ¡conveniente! (espero que en este punto hayás notado que rails está obsesionado con hacerte fácil la vida). Ahora `Task.all` te debería dar un arreglo con dos elementos. Probemos con otros métodos: `count`, `where`, `exists?` y las variantes de `find`:
    
    1.9.3p125 :008 > Task.count
       (0.3ms)  SELECT COUNT(*) FROM "tasks" 
     => 2 
    1.9.3p125 :009 > Task.where(priority: 6)
      Task Load (0.2ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."priority" = 6
     => [#<Task id: 1, description: "aprender rails", priority: 6, created_at: "2012-05-14 07:32:22", updated_at: "2012-05-14 07:42:52">, #<Task id: 2, description: "pasar la clase", priority: 6, created_at: "2012-05-14 07:34:28", updated_at: "2012-05-14 07:34:28">]
    1.9.3p125 :010 > Task.exists?(priority: 10)
      Task Exists (0.2ms)  SELECT 1 FROM "tasks" WHERE "tasks"."priority" = 10 LIMIT 1
     => false 
    1.9.3p125 :011 > Task.find(2)
      Task Load (0.4ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."id" = ? LIMIT 1  [["id", 2]]
     => #<Task id: 2, description: "pasar la clase", priority: 6, created_at: "2012-05-14 07:34:28", updated_at: "2012-05-14 07:34:28"> 
     1.9.3p125 :017 > Task.find_by_priority(6)
      Task Load (0.2ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."priority" = 6 LIMIT 1
     => #<Task id: 1, description: "aprender rails", priority: 6, created_at: "2012-05-14 07:32:22", updated_at: "2012-05-14 07:42:52">
     1.9.3p125 :018 > Task.find_all_by_priority(6)
      Task Load (0.4ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."priority" = 6
     => [#<Task id: 1, description: "aprender rails", priority: 6, created_at: "2012-05-14 07:32:22", updated_at: "2012-05-14 07:42:52">, #<Task id: 2, description: "pasar la clase", priority: 6, created_at: "2012-05-14 07:34:28", updated_at: "2012-05-14 07:34:28">]

si te fijás, el método `find_by_priority` sólo devuelve el _primer_ objeto que cumpla los requisitos, mientras que `where` y `find_all_by_priority` devuelven todos.

Y qué pasa si quisiéramos actualizar una instancia que está en la base de datos, usamos el método `update_attributes`:

    1.9.3p125 :022 > i2 = Task.find(2)
      Task Load (0.2ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."id" = ? LIMIT 1  [["id", 2]]
     => #<Task id: 2, description: "pasar la clase", priority: 6, created_at: "2012-05-14 07:34:28", updated_at: "2012-05-14 07:34:28"> 
    1.9.3p125 :023 > i2.update_attributes(description: "pasar progra4", priority: 7)
       (0.1ms)  begin transaction
       (0.4ms)  UPDATE "tasks" SET "description" = 'pasar progra4', "priority" = 7, "updated_at" = '2012-05-14 07:54:26.321018' WHERE "tasks"."id" = 2
       (50.1ms)  commit transaction
     => true 
 
Y veamos qué cosas pueden salir mal:

    1.9.3p125 :019 > Task.find(666)
      Task Load (0.1ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."id" = ? LIMIT 1  [["id", 666]]
    ActiveRecord::RecordNotFound: Couldn't find Task with id=666
    1.9.3p125 :020 > Task.find_by_id(666)
      Task Load (0.3ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."id" = 666 LIMIT 1
     => nil
     1.9.3p125 :021 > Task.where(id: 666)
      Task Load (0.2ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."id" = 666
     => [] 

si te fijás, el método `find` explota si no encuentra lo que busca, mientras que los `find_by` y `where`, no.


Eso es todo con los modelos por ahora. 

Este es un buen momento para hacer commit :)

Vas a encontrar más información sobre migraciones aquí: <http://guides.rubyonrails.org/migrations.html>  y más sobre los métodos de `ActiveRecord::Base`, aquí: <http://api.rubyonrails.org/classes/ActiveRecord/Base.html>

Y con esto podemos pasar a la siguiente parte de esta iteración.

####Validaciones

En la primera parte vimos cómo rails nos ayuda a interactuar con la base de datos. Pero los modelos tienen aún otra responsabilidad: asegurarse que los datos están correctos. Por ejemplo, en esta aplicación no queremos:

* Tareas con descripciones en blanco
* Tareas con descripciones repetidas
* Tareas con prioridades menores que 0

Para forzar a que estas reglas se cumplan, introduciremos el concepto de __validación__. 

Rails nos ofrece ciertos métodos que podemos agregar a nuestras clases para forzar estas reglas, editemos el modelo que vive en `app/models/task.rb`:

###2. El router


###3. El controlador y las vistas

##Iteración 2: Los usuarios

###1. El modelo usuarios y la asociación con Task

Las propiedades son `string` por defecto.

    rails g model User email password_digest
    rails g migration AddUserIdToTasks user_id:integer

###2. Administración de usuarios

    rails g scaffold_controller users index show new create edit update destroy 
    
###3. Asociaciones en forms


###3. Autenticación

<http://railscasts.com/episodes/250-authentication-from-scratch-revised> y <http://railscasts.com/episodes/250-authentication-from-scratch>


##Más recursos

* [Railscasts](http://railscasts.com/)
* [Rails Guides](http://guides.rubyonrails.org/)
* [Rails API Docs](http://api.rubyonrails.org)
* [Rails Tutorial](http://ruby.railstutorial.org/ruby-on-rails-tutorial-book)
* [Rails for Zombies](http://railsforzombies.com/)
* [Jumpstart Labs](http://tutorials.jumpstartlab.com/)

##Referencias

 * [A first rails app](http://tutorials.jumpstartlab.com/projects/blogger.html)
 * [Getting started with rails](http://railscasts.com/episodes/310-getting-started-with-rails)
 * [Authentication from scratch](http://railscasts.com/episodes/250-authentication-from-scratch-revised?view=asciicast)