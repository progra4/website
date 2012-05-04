#Examen 1

##Preliminares: modo de entrega

Como dice al final de la [guía de rack](http://progra4.heroku.com/ruby_http.html), es posible que tengás una copia remota de tu repositorio guardada en github.com . Para este examen, yo creé un repositorio en github.com al que sólo vos y yo tendremos acceso. El repositorio estará en <http://github.com/progra4/examen1_TU-NUMERO-DE-CUENTA>

En este momento quizá no tengás acceso porque yo te tengo que dar permiso. Para que te dé permiso, __decime cuál es tu nombre de usuario en github__. Este es el primer paso, no sigás hasta que me hayás logrado decir tu nombre de usuario.

Una vez que me digás tu nombre de usuario y yo te agregue al repositorio, vas a poder hacer lo siguiente:

	git clone git@github.com:progra4/examen1_TU-NUMERO-DE-CUENTA.git examen1
	
Eso creará una copia en tu computadora del repositorio del examen (en una carpeta llamada `examen1`). Una vez que tengás esta carpeta creada, __podés empezar__. En esa carpeta podés poner tu código y hacer los commits (__no necesitarás hacer git init__, cuando una carpeta se crea a partir de una copia remota via `git clone`, git ya está al tanto de ella). De ahí en adelante, recordá que podés hacer `git push origin master` para sincronizar la copia remota con tu copia local en cualquier momento (y se subirán los commits que tengás hasta entonces), te aconsejo que lo hagás frecuentemente porque __lo que haya allí antes de las diez de la mañana del lunes__ se considerará tu entrega final.


##Reglas

* Como se menciona arriba, el examen se entregará __via github__.
* La versión final es la que esté __subida en github antes de las diez de la mañana del lunes__. La revisión se hará el __lunes en la tarde__ de forma presencial (copiaré tu código desde github y lo ejecutaré en mi computadora).
* Como es el mismo examen para todos y es para trabajar en casa, cualquier intento de plagio se penalizará con una nota de __cero__ para los implicados. Pero espero que esto, a estas alturas de la carrera, no tenga que pasar.
* El propósito de este examen no es que sigás instrucciones, sino que demostrés creatividad y capacidad de resolver problemas, los requisitos son cortos precisamente por eso, no es una excusa aceptable que en la revisión se te pregunte por qué no hiciste algo que era obvio que era necesario para el funcionamiento correcto del programa y digás "es que no estaba en el enunciado" o "es que no le entendí". Estoy abierto todo el fin de semana a que me hagás preguntas a mi correo electrónico (luisfborjas@gmail.com).


##Requisitos

Lo que se quiere hacer es una aplicación que permita manejar una lista de cosas por hacer (to-do list). El usuario final debería ser capaz de crear una tarea (que tiene una descripción -que debe ser única-, un responsable y un número de prioridad), ver las tareas que no ha completado ordenadas por prioridad o filtradas por responsable, y marcar las tareas como terminadas.

Si un usuario opta por comunicarse directamente con el servidor, debería ser capaz de ver las listas de tareas y las tareas individuales como __texto plano__.

Pero un usuario también debería poder comunicarse con el servidor a través de una aplicación __cliente__ (que también tenés que programar, en ruby) que le permita llevar a cabo todos los casos descritos antes. Esta aplicación debería portarse de la forma más fácil de usar posible para el usuario final (pensá en los `main` que hacías en tus tiempos) y comunicarse con el servidor en algún formato __legible para una máquina__.

Por __puntos extra__, un usuario debería ser capaz de ver la lista de tareas no terminadas ordenadas por prioridad en formato html en un browser.


###Criterios de evaluación:

* Diseño de la aplicación del lado del servidor, respetando los principios REST (usando bien HTTP). Permitir usar la aplicación directamente por un cliente http de consola (curl) representando los recursos en un formato humanamente legible y también proveer un formato que las máquinas puedan entender (para facilitar el desarrollo del cliente en ruby). Y por __puntos extra__ también poder ver la lista de tareas en formato html.
*  Facilidad de uso de la aplicación cliente: tiene que estar escrita en ruby y proveer una interfaz (en línea de comandos) que haga fácil entender qué se puede hacer y qué pasos se han de seguir.
* Que un usuario final, ya sea directamente o mediante la aplicación cliente, pueda:
	* Crear una tarea (no debe permitir crear tareas con descripciones repetidas, no importan las mayúsculas y minúsculas ni que la prioridad o el responsable sean diferentes. Tampoco se puede dejar la descripción en blanco. El responsable sí puede estar en blanco y la prioridad por defecto debería ser `1`)
	* Actualizar una tarea (cambiar la descripción, el responsable o la prioridad; la descripción no puede quedar en blanco)
	* Marcar una tarea como terminada
	* Listar todas sus tareas no terminadas ordenadas por prioridad (entre mayor el número, mayor la prioridad, no importa que los números se repitan)
	* Ver las tareas filtradas por persona responsable (se usará el nombre de la persona responsable, no debería ser sensible a mayúsculas o minúsculas, de modo que las tareas asignadas a Juan Perez y las de juan PEREZ deberían mostrarse cuando se filtren por el nombre "juan perez")
* Espíritu investigativo: mucho de lo que se necesita aquí probablemente no lo vimos explícitamente en clase, pero todos los recursos necesarios están en lo que ya aprendimos, sólo es de ver más allá de la superficie.





