#Examen 2

El propósito de este examen es reproducir la aplicación que se encuentra en <http://examen2.herokuapp.com/> en ruby on rails.

La aplicación es simple: una persona puede poner un pedazo de código, con un título y descripción, y otras personas pueden comentar respecto a ello. Más o menos para pedir ayuda respecto a código que uno esté haciendo.

## Método de entrega:

La aplicación se entregará via heroku. Recordá que heroku guarda repositorios de git también, así que te recomiendo hacer push ahí. Si querés más seguridad, podés decirme para que te cree un repositorio privado en github. Pero con heroku debería ser suficiente.

Para el lunes, debés haber subido la aplicación a heroku y ejecutado esta línea:

    heroku sharing:add luisfborjas@gmail.com
    
Lo cual me enviará una notificación por correo electrónico y me permitirá bajar tu código. La aplicación será revisada como esté funcionando en heroku.

__importante__: incluí un archivo llamado `README` con tu nombre y número de cuenta.

##Requerimientos

La aplicacion no tiene que _verse_ "bonita" como la que está en línea, pero debe tener la misma funcionalidad:

* Permitirle a los usuarios crear una cuenta, iniciar sesión y cerrar sesión, con retroalimentación visual (decirles si tienen una sesión iniciada, permitirles salir, etc.)
* Permitirle a la gente ver todos los "reviews" que se han creado __en orden descendente por fecha de creación__.
* __sólo a usuarios autenticados__ permitirles crear nuevos reviews 
* __en la misma página donde se muestra un review, sólo a usuarios autenticados__ permitir comentar en un review
* __sólo al propietario de un review__ permitirle editarlo o destruirlo.


Parte de la evaluación en este examen es que seás capaz de usar `gems` para hacerte la vida más fácil, se requiere que usés al menos un gem. Yo recomendaría una de estas pero podés usar cualquiera. 

* [Sorcery](https://github.com/NoamB/sorcery) o [devise](https://github.com/plataformatec/devise) (no usés ambas, sólo una: hacen cosas similares)
* [Twitter bootstrap](https://github.com/seyhunak/twitter-bootstrap-rails)
* [Simple_form](http://github.com/plataformatec/simple_form)

Recursos que te podrían servir:

* [Rails guides](http://guides.rubyonrails.org/)
* [Rails API documentation](http://api.rubyonrails.org/)
* [Railscasts](http://railscasts.com/)
