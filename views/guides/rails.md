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


     class Task < ActiveRecord::Base
      attr_accessible :description, :priority
    
      validates_presence_of :description
      validates_uniqueness_of :description
      validates :priority, numericality: {:greater_than => 0}
    
      before_validation :clean_description, if: "description.present?"
    
      private
      def clean_description
        self.description = self.description.strip.capitalize
      end
     end
     
Hablemos de esto por partes:

* `validates_presence_of` es un método que genera un validador para el atributo (o atributos) que se le provean. Valida que el atributo tenga un valor no-nulo
* `validates_uniqueness_of`: valida que el atributo (columna) sea único entre todas las filas ya existentes de la tabla
* `validates` es general, y sirve para construir validadores más complejos. En este caso validamos la ["numericality"](http://guides.rubyonrails.org/active_record_validations_callbacks.html#numericality) del atributo `priority` para asegurarnos que sea mayor que cero.

Además de los métodos que generaron validadores, tenemos otro método, que genera un "callback". En RoR hay un concepto interesante con los modelos: __eventos__, cada vez que un modelo se crea, actualiza o destruye, ciertos eventos son reportados al sistema, y pueden ser usados por nosotros. En esta ocasión, estamos diciendo "antes de que ocurra el evento `validation` quiero que un método se ejecute". Y estamos usando un símbolo para referirnos a un método privado que definimos después. Y, además, usamos la opción `if` para decir que ese método sólo debería ejecutarse si hay una descripción presente. El método en sí simplemente elimina espacios en blanco y capitaliza las descripciones.

Probemos las validaciones en una sesión de irb:


Y, ahora, es buena idea hacer otro commit.




Más información sobre validaciones y "callbacks" acá: <http://guides.rubyonrails.org/active_record_validations_callbacks.html>


###2. El router

Ahora, no es divertido si sólo tenemos nuestros modelos en la aplicación; después de todo, es una aplicación web y todo el centro es HTTP. Según recordarás de los experimentos que hicimos en el primer parcial, todo el secreto de HTTP es poder usar los _verbos_ y _rutas_ para poder interactuar con los _recursos_. Ya tenemos un modelo que representa los recursos, ahora hablemos de cómo _configuraríamos_ las rutas.

La convención de rails es que usemos los principios de arquitectura [REST](http://blog.steveklabnik.com/posts/2011-08-07-some-people-understand-rest-and-http). La forma de hacerlo es editando el archivo `config/routes.rb` y diciéndole a rails que tendremos nuestras tareas como _recursos_:

    Tasks::Application.routes.draw do
      resources :tasks
    end
    
La convención en rails es ver las cosas como recursos, y las rutas y quién se encarga de ellas se decide automáticamente. Para ver las combinaciones de acción + ruta que nuestra aplicación espera entender, podemos usar el comando `rake routes`:

        tasks GET    /tasks(.:format)          tasks#index
              POST   /tasks(.:format)          tasks#create
     new_task GET    /tasks/new(.:format)      tasks#new
    edit_task GET    /tasks/:id/edit(.:format) tasks#edit
         task GET    /tasks/:id(.:format)      tasks#show
              PUT    /tasks/:id(.:format)      tasks#update
              DELETE /tasks/:id(.:format)      tasks#destroy
              
Esa es la tabla de rutas, si te fijás, es justo la convención que ya sabíamos. Expliquemos qué significa cada columna:

* La primera columna es el _alias_ para la ruta. Así, la primera ruta, la que representa la colección de todos los `tasks` se llama, sorprendentemente, `tasks`, y las acciones que representan recursos extra, como _new_ y _edit_, tienen su propio nombre. Recordá este concepto de alias para más tarde.
* La segunda y tercera columnas son el verbo + ruta, como ya sabemos, eso representa una acción única en nuestra aplicación. Algo a notar aquí son los valores que parecen símbolos (`:format`, `:id`), estos son __segmentos dinámicos__ de las rutas y serán incluidos en el hash `params` al que tienen acceso los controladores.
* La última columna es parte de la convención: como dijimos que nuestro recurso se llama `tasks`, espera que exista un controlador llamado `tasks` (en realidad, `TasksController`) que tenga métodos para las siete acciones posibles sobre un recurso (`index`, `create`, `new`, `edit`, `show`, `update`, `destroy`)


Ahora ya le prometimos a nuestra aplicación que manejaremos los recursos `tasks` y vemos en la __tabla de rutas__ que espera que tengamos un controlador, así que hagamos eso realidad en el siguiente paso.

    
Más información sobre las rutas está en [las guías oficiales de rails](http://guides.rubyonrails.org/routing.html)

###3. El controlador y las vistas

Así como comenzamos sabiendo que necesitaríamos representar nuestros recursos como modelos y usamos un generador para generar los archivos necesarios; ahora nos dimos cuenta que necesitamos un controlador, y también hay un generador:

    rails generate controller tasks index show new create edit update destroy
    
El generador de controladores recibe dos tipos de parámetros: el nombre del controlador (en este caso, `tasks`, como prometimos al router) y las acciones que ese controlador tendrá, en este caso, las siete acciones básicas que pueden hacerse sobre recursos.

Veamos qué generó:

      create  app/controllers/tasks_controller.rb
       route  get "tasks/destroy"
       route  get "tasks/update"
       route  get "tasks/edit"
       route  get "tasks/create"
       route  get "tasks/new"
       route  get "tasks/show"
       route  get "tasks/index"
      invoke  erb
      create    app/views/tasks
      create    app/views/tasks/index.html.erb
      create    app/views/tasks/show.html.erb
      create    app/views/tasks/new.html.erb
      create    app/views/tasks/create.html.erb
      create    app/views/tasks/edit.html.erb
      create    app/views/tasks/update.html.erb
      create    app/views/tasks/destroy.html.erb
      invoke  test_unit
      create    test/functional/tasks_controller_test.rb
      invoke  helper
      create    app/helpers/tasks_helper.rb
      invoke    test_unit
      create      test/unit/helpers/tasks_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/tasks.js.coffee
      invoke    scss
      create      app/assets/stylesheets/tasks.css.scss
      
Si te fijás, creó el controlador `tasks_controller` en la carpeta `controllers`, agregó unas cuantas rutas a `config/routes.rb` (esas están incorrectas, las podemos borrar) y además generó una plantilla para cada una de las acciones. Como algo extra, notá que generó un archivo llamado `tasks_helper` (ya hablaremos de los helpers), un archivo para todo el javascript relacionado a las vistas (rails usa un dialecto de javascript muy similar a ruby llamado [coffeescript](http://coffeescript.org/)) y otro archivo para todo el css relacionado a las vistas también (y rails usa otro dialecto de css, llamado [sass](http://sass-lang.com/))

Por ahora, concentrémonos en el controlador y las vistas. Nuestra meta en esta etapa será poder crear una `task`, poder mostrarla y poder jugar con la lista de `tasks`

Notá que también agregó varias instrucciones `get` al router, esas podés borrarlas, ya de las rutas de nuestro recurso se encarga la instrucción `resources :tasks`

####Creando una tarea: el formulario

La clase base de todos los controladores, `ActionController::Base`, agrega una convención interesante: luego de ejecutar el método de una acción, va a buscar una plantilla en la carpeta de `views` del controller, la llenará y la usará como respuesta. De modo que, en el controlador `TasksController` (dentro de `app/controllers/tasks_controller.rb`), esta acción, por ejemplo:

    def new
    end
    
Luego de ser ejecutada, responderá con un cuerpo html con el contenido de la plantilla `app/views/tasks/new.html.erb`. Así que llenemos _esa_ plantilla con el formulario para crear un task.

Rails tiene varios [métodos de ayuda](http://guides.rubyonrails.org/form_helpers.html) para formularios, usémoslos para generar un formulario para crear tareas:

    <h1>Create a task</h1>
    <%= form_for @task do |f| %>
      <p>
        <%= f.label :description %>
        <%= f.text_area :description %>
      </p>
      <p>
        <%= f.label :priority %>
        <%= f.number_field :priority %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    
Si te fijás, requiere que proveamos la variable `@task` en el binding. ¿Por qué una variable de instancia? Porque cuando rails llena plantillas, usa el binding de __todo__ el controller (en cada solicitud, creará una _nueva_ instancia del controlador), así que no nos servirían variables locales de métodos. En el archivo `app/controllers/tasks_controller.rb`, cambiemos el método `new` para que provea esa variable:

    def new
        @task = Task.new
    end

Ahora, algo curioso del método `form_for` es que es inteligente: sabe qué tag crear basado en la variable que le demos:

* Usa el método `class` para saber de qué clase es instancia (en este caso, `Task`) y a partir de allí asume que tenemos un controlador con ese nombre en plural (`TasksController`) y que estamos usando las convenciones REST (es decir, que tenemos un método `create` relacionado a `POST /tasks` y un `update` relacionado a `PUT /tasks/:id`).
* A partir del estado de la instancia (si es nueva o si ya está guardada en la base de datos) y las convenciones que mencionamos arriba, decide qué `action` y qué `method` usar (si es una nueva instancia, hará `POST` a `/tasks`) y si es una instancia ya guardada antes, hará `PUT` a `/tasks/:id`.

Ahora bien, si ejecutamos el servidor:

    rails server

Llenamos el formulario y hacemos _submit_, podremos ver algo similar a esto en el log (la salida en terminal) del servidor (toda esta información, además de salir a la pantalla, también está en el archivo `log/development.log`):

    Started POST "/tasks" for 127.0.0.1 at 2012-05-20 01:48:08 -0600
    Processing by TasksController#create as HTML
      Parameters: {"utf8"=>"✓", "authenticity_token"=>"ph6/DQPV4Oju19f7y5KidRKrEa0AN3FAMuGAmqVcE/8=", "task"=>{"description"=>"asdfasdf", "priority"=>"1"}, "commit"=>"Create Task"}
      Rendered tasks/create.html.erb within layouts/application (0.3ms)
    Completed 200 OK in 18ms (Views: 17.2ms | ActiveRecord: 0.0ms)
    
El [log](http://railscasts.com/episodes/56-the-logger) es una de las piezas de información más importantes que rails nos provee: dice todo lo que pasa con las solicitudes que entran y cómo construye las respuestas, veamos en detalle cada línea de esta solicitud-respuesta:

En cuanto a la solicitud:

* `Started POST "/tasks" ` nos reporta qué ruta fue llamada por qué verbo, desde qué dirección remota a qué hora y fecha
* `Processing by TasksController#create as HTML` nos dice que a esa combinación de verbo + ruta le está asignando como responsable el método `create` de una instancia de `TasksController`, como esperaríamos. Es interesante notar que, por defecto, el formato en el que lidia con las solicitudes es `HTML`. Como mencionamos en los segmentos dinámicos arriba, podríamos pedirlo en otro agregando la extensión a la ruta  (`/tasks.json` pediría la respuesta como `JSON`, por ejemplo), o usando el ya conocido header `Accept`.
* Los parámetros incluidos en la solicitud representados en un hash, nótese que entre estos está el hash `task`, que tiene las propiedades que introdujimos en el form (`utf8` fuerza a internet explorer a enviar los forms en unicode correcto, `authenticity_token` es parte de una [estrategia de seguridad](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf) para evitar que otros sitios simulen ser parte de la aplicación)

En cuanto a la respuesta:

* Nos informa que llenó la plantilla `tasks/create.html.erb` porque ese es precisamente el comportamiento por defecto. En realidad no queremos eso, queremos que se cree una tarea y nos redirija, ya haremos eso.
* Por último, nos dice que terminó de responder, y con qué estado.


####Creando una tarea: la acción `create`

Ya que sabemos qué información tendríamos para crear una tarea, podríamos hacer algo como esto, aprovechando el método `params` que todos los controladores tienen, que devuelve un hash con los parámetros de la solicitud actual:

    @task = Task.create(params[:task])

También es buena idea, como hacíamos antes, redirigir al cliente a un lugar donde pueda ver que en efecto se creó la tarea. Esta vez, hagamos que vea la tarea individual usando el método `redirect_to`:

    redirect_to "/tasks/#{@task.id}"
    
Ahora bien, una buena idea en cualquier aplicación web es no depender de las rutas explícitas, porque podrían cambiar, y en su lugar aprovechar los __alias__, y los métodos que terminan en  `_path` o en `_url`:

    redirect_to task_path(id: @task.id)
    
Recordando que en la ruta para una tarea individual (a task path) necesitamos el segmento dinámico `:id`.

Pero puede ser más corto aún: como estamos tratando los `tasks` como recursos (recordá que hasta declaramos `resources :tasks` en el router), podemos dejar que rails asuma que estamos respetando REST, sólo darle la instancia y que él adivine la ruta:

    redirect_to @task
    
De modo que, en el controlador (en `app/controllers/tasks_controller.rb`), definiríamos el método `create` así:

    def create
        @task = Task.create params[:task]
        redirect_to @task
    end

Al ser redirigidos a `/tasks/:id`, se estaría haciendo un `GET` a esa ruta. Según nuestra tabla de rutas (recordá que se obtiene con `rake routes`), de esta acción está a cargo el método `show`.

¿Qué queremos en el método `show`? Pues simplemente buscar una tarea con el identificador único incluido en la ruta y mostrarla en una plantilla, así que se vería  algo así:

    def show
        @task = Task.find(params[:id])
     end
     
Dos cosas a notar de arriba:
* Usamos el método `find` para encontrar _en la base de datos_ mediante el identificador único.
* De entre los parámetros, sacamos el segmento dinámico `:id` (recordá que la ruta es `tasks/:id`)

Lo asignamos a una variable de instancia para que esté disponible en el _binding_ de la instancia del controlador en esta solicitud y luego dejamos que el comportamiento por defecto (llenar la plantilla `show.html.erb`) ocurra. Editemos esa plantilla (en `app/views`)

    <p>
      Task with description <%= @task.description %>
      and priority <%= @task.priority %>
    </p>
    <%= link_to "All tasks", tasks_path %>
    
Suficientemente sencillo. Fijate, sin embargo, en la última línea: usamos el método de ayuda ([helper method](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html)) `link_to` para generar un hipervínculo cuyo texto sea "All tasks" y su `href` sea la ruta que el método `tasks_path` devuelve (que es la ruta a la colección: `/tasks`). De este modo, podríamos ir a ver la lista de todos los tasks.

Y probemos con `rails server` otra vez crear una tarea en `/tasks/new` y esta vez debería crearla y redirigirnos a la tarea recién creada. Si todo funciona, __es buen tiempo para hacer commit__.


####Mostrando todas las tareas

Ahora bien, para mostrar todas las tareas, ya sabemos que tenemos que encargarnos de la acción `index` en el controlador (`app/controllers/tasks_controller.rb`):

    def index
        @tasks = Task.all
    end

Y de la plantilla correspondiente (`app/views/tasks/index.html.erb`):

    <ol>
      <% @tasks.each do |task|%>
        <li>
          <%= task.description %>
          <%= link_to "show priority", task %>
       </li>
      <% end %>
    </ol>

Un par de observaciones interesantes: estamos usando código encerrado entre `<% %>` (nótese la falta del signo igual) para ejecutar código de ruby, iterar entre todas las tareas. Y también, que de segundo parámetro al método `link_to` sólo estamos enviando la instancia de tarea, no una ruta. ¿Cómo funciona esto? Al igual que `form_for`, usa [reflexión](http://en.wikipedia.org/wiki/Reflection_(computer_programming)) para adivinar que esta instancia pertenece a la clase `Task` y asumir que es un recurso y que, como tal, su ruta se vería `/tasks/:id`.

¿Qué pasaría si quisiéramos borrar una tarea? Si recordás HTTP, deberíamos hacer un `DELETE` a la ruta miembro. Rails nos permite hacer algo como lo siguiente:

    <%= link_to "delete", task, :method => :delete, :confirm => "are you sure?" %>

Que haría lo siguiente: usar javascript para preguntarnos si de veras queremos borrar el recurso y luego, siempre con javascript, enviar una solicitud `DELETE` a la ruta especificada en el `anchor`. Con eso en mente, nuestra plantilla se vería así:

    <ol>
      <% @tasks.each do |task|%>
        <li>
          <%= task.description %>
          <%= link_to "show priority", task %>
          <%= link_to "delete", task, :method => :delete, :confirm => "are you sure?" %>
       </li>
      <% end %>
    </ol>
    <%= link_to "create a task", new_task_path %>

Pero aún no tenemos nuestra acción `destroy` (que, según nuestra convención, reflejada en la tabla de rutas, es la que se encarga de un `DELETE`). Así que agreguémosla al controlador:

    def destroy
        Task.find_by_id(params[:id]).try(:delete)
        redirect_to tasks_path
    end
    
Una observación: estamos usando el método [`try`](http://guides.rubyonrails.org/active_support_core_extensions.html#try), que rails agrega a los objetos para que, si el objeto no es `nil`, lo ejecute, y si es `nil`, sólo devuelva `nil`. Además, estamos usando el método `find_by_id` en lugar de `find`, para que, si el objeto no existe, simplemente devuelva `nil`, en lugar de levantar una excepción.

#### Validaciones en formularios

Hasta este momento, nuestra acción de crear se ve así:

    def create
        @task = Task.create(params[:task])
        redirect_to @task
    end
    
Pero está asumiendo que todo ha salido bien. ¿Cómo hacer para cuando las cosas salen mal, como validaciones que no pasan?

Recordemos que en lugar de usar el método `create`, podríamos crear la instancia y luego intentar guardarla. El método `save` nos devuelve un valor booleano que dice si la instancia se pudo guardar o no. Así que podríamos hacer que se vea así:

    def create
        @task = Task.new(params[:task])
        if @task.save
            redirect_to @task
        end
    end
    
La gran pregunta es ¿qué hacer cuando una tarea __no__ se salve? Idealmente, deberíamos _volver a mostrar el formulario_ y allí mostrar los errores. Rails nos permite elegir qué plantilla usar mediante el método `render`, así que podemos cambiar la acción por esto

    def create
        @task = Task.new(params[:task])
        if @task.save
            redirect_to @task
        else
            render :new
        end
    end
    
Para decirle que, si no pudimos guardar, se vuelva a mostrar el formulario. Pero ¿qué ganamos con mostrar el formulario de nuevo? No mucho si no hay forma de mostrar los errores, así que editemos el formulario (en `app/views/tasks/new.html.erb`):

    <h1>Create a task</h1>
    <%= form_for @task do |f| %>
      <% if @task.errors.any? %>
          <h2>Invalid task, the errors were:</h2>
          <ul>
              <% @task.errors.full_messages.each do |msg| %>
                <li><%= msg %></li>
              <% end %>
          </ul>
      <% end %>
    
      <p>
        <%= f.label :description %>
        <%= f.text_area :description %>
      </p>
      <p>
        <%= f.label :priority %>
        <%= f.number_field :priority %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>

Y ahora, si tratamos de guardar una tarea inválida, veremos una lista de errores al querer guardarla. Notá que usamos el métod `any?` para preguntarnos si la tarea tiene algún error y el método `full_messages` para obtener un arreglo con todos los mensajes de error.

####Actualizando tareas

Como ya te imaginarás, para actualizar una tarea necesitamos tener un formulario en la plantilla `app/views/tasks/edit.html.erb` pero, antes de hacerlo, considerá ¿no sería ese formulario prácticamente idéntico al que está en la plantilla para uno nuevo? Si lo sospechás, es cierto: todo el formulario sería idéntico. Así que ¿será que lo copiamos y pegamos? ¡NO! Recordá un principio muy importante en programación: _Don't Repeat Yourself_ (DRY). Afortunadamente, rails tiene el concepto de plantillas [parciales](http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials).

Así que vamos a hacer lo siguiente en `app/views/tasks/edit.html.erb`:

    <h1>Edit a task:</h1>
    <%= render 'form' %>
    
Que básicamente dice: buscá en esta carpeta (`app/views/tasks`) una plantilla llamada `_form.html.erb` (notá el guión bajo al principio), llenala con el binding actual y ponela aquí.

Ahora, la plantilla `app/views/tasks/_form.html.erb` debería verse así:

    <%= form_for @task do |f| %>
      <% if @task.errors.any? %>
          <h2>Invalid task, the errors were:</h2>
          <ul>
              <% @task.errors.full_messages.each do |msg| %>
                <li><%= msg %></li>
              <% end %>
          </ul>
      <% end %>
    
      <p>
        <%= f.label :description %>
        <%= f.text_area :description %>
      </p>
      <p>
        <%= f.label :priority %>
        <%= f.number_field :priority %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>

Luego, necesitamos encargarnos de la acción `edit`: ella debería encontrar la tarea que queremos editar y ponerla disponible en el binding para el formulario

    def edit
     @task = Task.find(params[:id])
    end
    
Y deberíamos poner un vínculo en la lista de tasks (en `app/views/tasks/index.html.erb`) que nos permita editar una tarea:

    <%= link_to "edit this task", edit_task_path(task) %>
    
Y, si vamos a editar una de nuestras tareas, deberíamos poder. Sabemos, también, que el formulario hará un `PUT` a `/tasks/:id`, y nuestra tabla de rutas dice que de esa combinación quien se encarga es el método `update` en el controlador, así que también editemos ese:

    def update
        @task = Task.find(params[:id])
        if @task.update_attributes(params[:task])
            redirect_to @task
        else
            render :edit
        end
    end
    
Si te fijás, es muy similar al método create, con algunas diferencias:

* En vez de usar una nueva instancia, encontramos la instancia a editar con el método `find`
* En vez de usar el método save, usamos el método de instancia `update_attributes`, que recibe un hash con los atributos a actualizar y devuelve `true` si logró guardar el modelo.
* Si no logró guardar los cambios, volvemos a mostrar el formulario.

Con esto, ya tenemos las siete acciones básicas que se pueden hacer con un recurso, y ya podemos manipular recursos a través de http, representados como html.


Más información sobre los controladores está en las [guías oficiales de rails](http://guides.rubyonrails.org/action_controller_overview.html). Y sobre las vistas, podés leer sobre los [layouts](http://guides.rubyonrails.org/layouts_and_rendering.html) y sobre los [métodos de ayuda para formularios](http://guides.rubyonrails.org/form_helpers.html) también en las guías oficiales. Para saber sobre los métodos que rails agrega a los objetos de ruby, consultá aquí: <http://guides.rubyonrails.org/active_support_core_extensions.html>.

###4. Cerrando esta iteración: subiendo la aplicación a heroku

Para subir una aplicación a heroku, tenés que tener una [cuenta en heroku](http://api.heroku.com/signup) y seguir el proyecto con git. Una observación a hacer: __tu carpeta `.git` debería estar al mismo nivel que los archivos de rails (es decir, la carpeta `app` y la carpeta `.git` deberían estar en la misma carpeta, si no, heroku no aceptará la aplicación). Todos los archivos de tu aplicación deben ser conocidos por git.

Para que de ahora en adelante heroku confíe en vos, ejecutá lo siguiente:

    heroku login
    
(te pedirá el correo y contraseña de tu cuenta en heroku).

Antes de poder usar heroku, necesitamos hacer una pequeña edición en nuestro `Gemfile`, donde dice

    gem 'sqlite3'
    
Sustituilo por las siguientes dos líneas:

    gem 'sqlite3', :group => :development
    gem 'pg', :group => :production 
    
Y ejecutá, en terminal:

    bundle install --without production
    
Volvé a hacer un commit de todo, acabás de cambiar algunos de los gems de tu proyecto.

¿Qué acabamos de hacer? La opción `:group` del método `gem` le dice a `bundler` (la utilidad que maneja nuestras dependencias), en qué [entorno](http://thirddirective.com/posts/14-rails-environments) estaremos usando cada gem: el gem `sqlite3` lo usaremos al programar (`development`) y el gem `pg` (para comunicarse con bases de datos en [postgreSQL](http://www.postgresql.org/)), en un ambiente de producción (heroku es un ambiente de producción: porque es públicamente accesible).

Ahora, creá tu repositorio en heroku con la siguiente instrucción:

    heroku create --stack cedar
    
Que debería tener una salida similar a esta:

    Creating stark-moon-2137... done, stack is cedar
    http://stark-moon-2137.herokuapp.com/ | git@heroku.com:stark-moon-2137.git
    Git remote heroku added
    
Notá que el nombre antes de `herokuapp.com` es aleatorio, así que te saldrá uno diferente al que me salió a mí. Si la última línea (`Git remote heroku added`) no te aparece, agregá el repositorio de heroku manualmente con:

    git remote add heroku git@heroku.com:NOMBRE_ASIGNADO_POR_HEROKU.git
    
Es hora de subir el código de nuestra aplicación a heroku:

    git push heroku master
    
(estás subiendo el código a heroku, no a `origin`, que está en github)

Y deberías ver algo como esto:

    Counting objects: 129, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (113/113), done.
    Writing objects: 100% (129/129), 29.82 KiB, done.
    Total 129 (delta 23), reused 0 (delta 0)
    
    -----> Heroku receiving push
    -----> Ruby/Rails app detected
    -----> Installing dependencies using Bundler version 1.2.0.pre
           Running: bundle install --without development:test --path vendor/bundle --binstubs bin/ --deployment
           …
                  Cleaning up the bundler cache.
    -----> Writing config/database.yml to read from DATABASE_URL
    -----> Preparing app for Rails asset pipeline
           Running: rake assets:precompile
    -----> Rails plugin injection
           Injecting rails_log_stdout
           Injecting rails3_serve_static_assets
    -----> Discovering process types
           Procfile declares types      -> (none)
           Default types for Ruby/Rails -> console, rake, web, worker
    -----> Compiled slug size is 15.7MB
    -----> Launching... done, v4
           http://stark-moon-2137.herokuapp.com deployed to Heroku


En este momento, tu aplicación ya está lista para ser visitada en heroku. Pero hay un problema: acabás de poner la aplicación en otra computadora, una que no sabe cuál es la estructura de tu base de datos (recordá que la base de datos __no__ es parte de tu aplicación). Para que heroku esté al tanto de tu base de datos, tenés que ejecutar las migraciones allí también (esto sólo se debería correr cada vez que cambiés la estructura de la BD):

    heroku run rake db:migrate
    
Y deberías ver que las migraciones se ejecutaron:

    Running rake db:migrate attached to terminal... up, run.1
       Migrating to CreateTasks (20120514062804)
    ==  CreateTasks: migrating ====================================================
    -- create_table(:tasks)
       -> 0.0080s
    ==  CreateTasks: migrated (0.0082s) ===========================================
    
Ahora deberías poder entrar a tu aplicación, en la ruta `/tasks` (en el caso de este ejemplo, a `http://stark-moon-2137.herokuapp.com/tasks`) y usar la aplicación. 

¡Felicidades, acabás de subir tu primera aplicación a internet!

Si todo está bien, deberías subir todos tus cambios a tu repositorio de github también.


###5. Extra: un controlador para la ruta raíz

Si te fijás, en este punto sólo algo bajo `/tasks`. Si entrás a la ruta raíz (`/`) vas a ver una página por defecto de ruby on rails. Esa está en el archivo `public/index.html`. Borrémoslo:

    rm public/index.html
    
Y agreguemos esta línea dentro del router:

    root to: "tasks#index"
    
Ahí estamos simplemente diciendo: quiero que cuando se pida la ruta raíz, de esta también se encargue el método `index` de una instancia del controlador `tasks`

Ahora bien, quizá no queremos ese tipo de ambigüedad, o quizá queremos que en la ruta raíz salga algo diferente. Creemos un controlador que no sea un recurso, simplemente algo aparte:

    rails g controller home index
    
Estamos creando un controlador llamado `home` con una acción `index`. En la plantilla (en `app/views/home/index.html.erb`):
    
    <h1>Tasks app</h1>
    
    <%= link_to "See all tasks", tasks_path %>


Y cambiamos la ruta raíz en `config/routes.rb` a:

    root to: "home#index"
    
Y ahora, en vez de ver la lista de tareas al pedir la ruta raíz (`/`), veremos la plantilla que acabamos de llenar. Acabamos de aprender, también, que podríamos hacer controladores que no tienen que ver, necesariamente, con un recurso.

##Iteración 2: Los usuarios

###1. Usando `scaffold` para generar el código que manipula usuarios

Ahora que ya tenemos las tareas, deberíamos ser capaces de asignarlas a usuarios. De modo que necesitamos un nuevo recurso: `User`. 

Para con este recurso, podríamos hacer como antes y crear el modelo, acciones y vistas manualmente. Pero sería básicamente lo mismo que ya hicimos. Recordá: don't repeat yourself.

Rails, afortunadamente, nos permitiría generar todo de una vez con el generador de recursos (`rails generate resource`). Pero podemos ir un paso más allá y no sólo generar el recurso, sino ¡llenar el controlador y vistas de una sola vez! Para eso, usaremos un generador más:

    rails generate scaffold User email username
    
Lo que hicimos fue decir: "generá todo lo necesario para manipular un recurso llamado `User` con propiedad `email` y `username` (si no especificás el tipo de datos de una propiedad, será `string` por defecto).

Deberías ver algo como esto:

      invoke  active_record
      create    db/migrate/20120521015711_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/unit/user_test.rb
      create      test/fixtures/users.yml
       route  resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      invoke    test_unit
      create      test/functional/users_controller_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      create        test/unit/helpers/users_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/users.js.coffee
      invoke    scss
      create      app/assets/stylesheets/users.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss
      
Si te fijás, creó todo lo que nosotros habíamos creado en partes antes, pero no sólo eso, ¡sino que ya llenó de código el controlador y vistas! (¡andá ve!). 

Algo diferente que vas a notar en el código generado es que todas las acciones en el controlador usan el método [`respond_to`](http://guides.rubyonrails.org/action_controller_overview.html#rendering-xml-and-json-data). Ese método sirve para decidir, en base al formato pedido, cómo representar el recurso (recordá que poder tener varias representaciones es escencial para una arquitectura REST), usar ese método se ve así:

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
    
Que básicamente es: en base al formato pedido, si es html, dejar que nada pase (para que haga lo por-defecto, que es llenar y mostrar la plantilla `index.html.erb`, en el caso de la acción `index`) y, en el caso de que se pida `json`, mostrar un objeto json a partir del arreglo de usuarios. Para probarlo, podrías crear un par de usuarios y luego pedir (desde curl o el browser): `/users.json`, y verías un objeto JSON con la lista de usuarios. Recordá que en la tabla de rutas el segmento dinámico opcional `.:format` nos permite agregar el formato necesitado a la ruta.

Recordá que acabás de generar un modelo, de modo que necesitás correr la migración (después de hacer un commit):

    rake db:migrate
    git push heroku master
    heroku run rake db:migrate

Por último, podríamos agregar la siguiente línea a la página que vemos en la raíz (`app/views/home/index.html.erb`): 

    <%= link_to "All users", users_path %>
    
Si ejecutás el servidor (`rails server`), vas a notar que la página se ve ligeramente mejor (los vínculos son grises, no azules, el tipo de letra ya no es times new roman, etc.) Esto es gracias a una _hoja de estilos_ que se agregó: `app/assets/stylesheets/scaffolds.css.scss`, ¡también en eso nos ayudó rails!

###2. Relacionando usuarios a tareas

Ahora llegamos a lo bueno ¿cómo hacer para relacionar usuarios a tareas?. La idea es simple: necesitamos saber, por cada tarea, quién está asignado, ¿no? Además, los usuarios tienen un identificador único, de modo que, sabiendo éste, sabríamos quién es el responsable de la tarea. En lenguaje de bases de datos, tendríamos que tener una columna más en cada fila de tarea: una columna que guarde el responsable de la tarea. Como va a ser el identificador del usuario, llamémosle `user_id`. 

Para agregar una columna a la tabla de usuarios, puesto que hemos de cambiar la estructura de la base de datos, necesitamos una migración. Rails tiene un generador de migraciones con una convención interesante: si escribimos `AddXXXXToTABLE`, va a saber que queremos agregar una columna a la tabla `TABLE`, y generará una migración con las instrucciones adecuadas. En este caso, esperaría un parámetro más: la columna a agregar:


    rails g migration AddUserIdToTasks user_id:integer


una vez que ejecutés la migración (`rake db:migrate`), tu tabla tendrá un campo para el identificador de usuarios.

Pero eso fue a nivel de la base de datos, a nivel de los modelos también tenemos que informar de esta asociación, así que, en el modelo para tareas (`app/models/task.rb`), agregaríamos esta línea:

    class Task < ActiveRecord::Base
        belongs_to :user
        …
        #el resto del código
    end

Con `belongs_to` simplemente estamos avisándole a rails que cada instancia de este modelo pertenecerá a un usuario. Con esto, ya sabrá que tiene que buscar el propietario en una columna llamada `user_id` (por convención). Y no sólo eso, sino que también líneas como `task.user` nos darán una instancia completa de usuario, porque rails se encargará de buscar en la base de datos un usuario con el id que esté guardado en la instancia de task, automáticamente.

Asimismo, los usuarios también deberían estar avisados que las tareas les pertenecerán, así que en el modelo de usuario (`app/models/user.rb`), escribimos:

    class User < ActiveRecord::Base
        has_many :tasks
    end

Con esto, líneas como `user.tasks` funcionarán: nos devolverían el arreglo de todas las tareas que le pertenecen a un usuario.

Para saber más sobre asociaciones, consultá la [guía oficial de rails sobre asociaciones](http://guides.rubyonrails.org/association_basics.html). 

Ahora bien, necesitamos reflejar en el formulario de tareas que éstas pueden pertenecer a un usuario. Para ello, necesitamos un campo en la plantilla parcial para el formulario (`app/views/tasks/_form.html.erb`) que nos permita elegir un usuario. Esto es un problema interesante: necesitaríamos poder elegir un identificador único dentro de todos los usuarios y asignarlo al campo `user_id`. En html existe el tag `select`, que funciona así

    <select name="user_id">
        <option value="1">lfborjas</option>
        <option value="2">johnnycash</option>
    </select>

Si te fijás, usamos el tag `select` para nombrar el campo a llenar. Y el tag `option` para las opciones que habrían de salir. Las opciones tienen un valor en el atributo `value` que es el que será enviado en el formulario, y otro dentro del tag que sólo se mostrará. Rails tiene un _helper_ que nos ayuda con todo eso: `collection_select`. Agreguemos esto dentro del formulario en `app/views/tasks/_form.html.erb`:

    <%= f.label :user %>
    <%= f.collection_select :user_id, User.all, :id, :username %>
    
Que básicamente es: quiero tener de opciones para el campo `user_id` a todos los usuarios (`User.all`) y que el valor de las opciones sea el `id` de cada instancia y lo que el usuario vea sea el `username` de cada instancia.

###3. Viendo las tareas de cada usuario

Ahora que ya podemos asignarle tareas a un usuario, deberíamos poder ver todas las tareas asignadas a un usuario. Idealmente, deberíamos hacerlo a través de una url clara como `/users/lfborjas/tasks` o, usando segmentos dinámicos, `/users/:id/tasks`. Hay dos cosas a hacer:
    
    resources :users do
        get tasks, on: :member
    end
    
    tasks_user GET    /users/:id/tasks(.:format) users#tasks
    
    def tasks
        @tasks = User.find_by_username(params[:id]).tasks
        render 'tasks/index'
    end
    
    def to_param
       username
    end


###3. Autenticación

Un caso muy común en las aplicaciones web es permitirle a los usuarios registrarse con un password, para poder autenticarse. Si te has fijado en aplicaciones como facebook o twitter, existe el concepto de "registrarse" (que es crear una cuenta de usuario) e "iniciar sesión" (que es crear una nueva sesión de uso).

Vamos por pasos:

#### Registrarse

Si te fijaste, registrarse no es más que crear una cuenta de usuario, que es, simplemente, crear un usuario. Ya en el scaffold que hiciste es posible crear usuarios, pero se crean sin contraseña. Necesitamos algún mecanismo para guardar la contraseña de un usuario.

Si te ponés a pensar, sería increíblemente inseguro guardar la contraseña de los usuarios en texto plano: cualquiera que pueda leer la base de datos podría verla. Un mecanismo muy común es usar [un hash cifrado](http://en.wikipedia.org/wiki/Cryptographic_hash_function) irreversible. De esta forma, para asegurarnos que un usuario dice que es quien es, en lugar de comparar su contraseña con la que tuviéramos guardada, simplemente ciframos la contraseña y, si el resultado es idéntico al guardado, es quien dice ser.

Este _resultado_ que mencionamos arriba, lo llamaremos `password_digest` y, como necesitamos guardarlo con cada usuario, será una columna que agreguemos a la tabla usuarios:

    rails g migration AddPasswordToUsers password_digest:string
    
Una vez que ejecutés `rake db:migrate`, pasemos a lo siguiente.

Ok, ya guardamos el resultado, pero, ¿cómo lo calculamos? O, ¿cómo validaríamos que las personas, al crear un password, estén seguras de hacerlo, y que no esté en blanco? Y, cuando alguien quiera que lo autorizemos ¿cómo volver a calcular el password y asegurarse que es quien dice ser?. Todos estos métodos los podríamos hacer por nuestra cuenta, pero en __rails 3.1__ se agregó el método `has_secure_password`, que hace todo esto por nosotros, asumiendo que tenemos una columna `password_digest` y atributos `password` y `password_confirmation` para cuando se cree un usuario (estos atributos __no__ se guardan en la base de datos).

Agreguemos esto a nuestro modelo de usuario (`app/models/user.rb`)

    
    class User < ActiveRecord::Base
        has_secure_password
        attr_accessible :username, :email, :password, :password_confirmation
        validates_uniqueness_of :username, :email
    end

El método `has_secure_password` asume que tenemos una librería de cifrado, así que agreguemos una librería para usar el algoritmo `bcrypt` a nuestro `Gemfile`:

    
    gem 'bcrypt-ruby', '~> 3.0.0'
    
Y lo instalamos:
    
    bundle install --without production

Ahora, necesitamos que, al crear un usuario desde un browser, se le pidan los atributos nuevos (`password` y `password_confirmation`).
    
    <div class="field">
        <%= f.label :password %><br />
        <%= f.password_field :password %>
    </div>
     <div class="field">
        <%= f.label :password_confirmation %><br />
        <%= f.password_field :password_confirmation %>
     </div>
    
Y con esto, ya permitimos a los usuarios registrarse.

####Iniciar sesión

Ahora que podemos crear una "cuenta" en nuestra aplicación, deberíamos permitirle al usuario "iniciar sesión". Recordemos que en http todo se basa en los recursos, así que esto de _iniciar sesión_ no es más que __crear__ una sesión. En otras palabras, las _sesiones_ son recursos. Nada más y nada menos. Pero esta vez, estos recursos sólo existirán virtualmente, no en la base de datos.

Como vamos a manipular un recurso, necesitamos un controlador, con la acción `new` para tener un formulario donde crear las sesiones:
    
    rails g controller sessions new
    
Y agregar el recurso a nuestro `config/routes.rb`:

    resources :sessions
    
Ahora, nuestra acción `new` puede quedarse vacía, lo que nos interesa es el formulario. La gran pregunta es ¿cómo se vería un formulario que __no__ sea para un modelo? Afortunadamente, rails también nos da [helpers para formularios simples](http://guides.rubyonrails.org/form_helpers.html#dealing-with-basic-forms)

De modo que la plantilla de este formulario (en `app/views/sessions/new.html.erb`):

    
    <%= form_tag sessions_path do %>
      <div class="field">
        <%= label_tag :email %>
        <%= text_field_tag :email, params[:email] %>
      </div>
    
      <div class="field">
        <%= label_tag :password %>
        <%= password_field_tag :password %>
      </div>
    
      <div class="actions"><%= submit_tag "Log In" %>
    <% end %>

Si te fijás, esta vez no usamos el método `form_for` ni usamos la variable `f` para construir el form: este formulario no construirá ningún objeto, sino que enviará los parámetros `email` y `password`.

Y este formulario hará `POST` a la ruta `/sessions`, de modo que de ello se puede encargar el método `create` del controlador (`app/controllers/sessions_controller.rb`):

      def create
        user = User.find_by_email params[:email]
        if user && user.authenticate(params[:password])
          session[:user_id] = user.id
          redirect_to root_url , notice: "Logged in!"
        else
          flash.now.alert "Email or password is invalid"
        end
      end
      
Lo que hacemos es simple:

* Encontrar al usuario cuyo email corresponde al dado (con el [método dinámico](http://guides.rubyonrails.org/active_record_querying.html#dynamic-finders))
* Usamos el método `authenticate` que `has_secure_password` agrega a las instancias de   nuestro modelo `User`
* Si el usuario es quien dice ser, guardamos su identificador único en la sesión.
* Usamos el [flash](http://guides.rubyonrails.org/action_controller_overview.html#the-flash) para reportar si se logró hacer la autenticación o si hubo un error.
* Si la autenticación funcionó, redirigimos al usuario a la ruta raíz (`root_path`).

Pero, ¿en qué consiste "crear una sesión"? Básicamente es hacer que el cliente recuerde (en un _cookie_), quién es. Pero en vez de guardarlo en un cookie (porque alguien podría pretender ser quien no es), usamos el concepto de [sesión](http://guides.rubyonrails.org/action_controller_overview.html#session). 

De modo que, "cerrar sesión" simplemente es destruir una sesión, la sesión actual del usuario:


      def destroy
        session[:user_id] = nil
        redirect_to root_url, notice: "Logged out!"
      end
      

Mucho de lo que hacemos en una aplicación que tiene sesiones de uso es asegurarnos que hay un usuario que haya iniciado sesión. Para esto, agregaremos dos métodos comunes a todos los controladores: `current_user` para saber el usuario actual y `logged_in?` para saber si hay un usuario autenticado. Así que agregaremos esos métodos al padre de todos los controladores: `application_controller` (en `app/controllers/application_controller.rb`)

    class ApplicationController < ActionController::Base
      protect_from_forgery
   
      private
      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end
    
      def logged_in?
        current_user != nil
      end
    
      helper_method :current_user, :logged_in?
    end


Ahora que tenemos eso, podríamos hacer que en todas las páginas de la aplicación nos muestre quién está autenticado, o, si no hay nadie, que nos dé la opción de crear una cuenta o iniciar sesión. Para lograr esto, editaremos el _layout_ general de todas las plantillas, que está en `app/views/layouts/application.html.erb`:
    
    <% unless logged_in? %>
      <%= link_to "Create an account", new_user_path %>
      <%= link_to "Log In", new_session_path %>
    <% else %>
      Logged in as <%= current_user.username %>
      <%= link_to "Log out", session_path("current"), method: "delete" %>
    <%end%>
    
En este momento, la ruta para crear una cuenta se ve como `/users/new`, y para una sesión `/sessions/new`. Agreguemos rutas que se vean mejor a `config/routes.rb`:

      get 'signup', to: 'users#new', as: 'signup'
      get 'login', to: 'sessions#new', as: 'login'
      get 'logout', to: 'sessions#destroy', as: 'logout'
      
 Y así, lo que hicimos arriba podría verse así:
 
    <% unless logged_in? %>
      <%= link_to "Create an account", signup_path %>
      <%= link_to "Log In", login_path %>
    <% else %>
      Logged in as <%= current_user.username %>
      <%= link_to "Log out", logout_path %>
    <%end%> 

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