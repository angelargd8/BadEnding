# Bad Ending — Documento de diseño del juego

## Concepto

**Género:** raising sim + card battler

**Premisa:** el protagonista es un estudiante introvertido de tercer año de Ao Koukou. Mizuki, una estudiante de primer año, está enamorada de una versión idealizada de él. Durante seis semanas, el jugador equilibra sus estudios, su felicidad y la relación con Mizuki.

El título juega con la expectativa de un juego de citas. El objetivo es terminar como amigos, sin que Mizuki lo odie ni quede demasiado obsesionada con él, y cumplir las metas personales de estudio y felicidad.

## 3. Ciclo de juego

Una partida dura seis semanas. El flujo actual es:

1. La pantalla inicial permite empezar una partida, cargar una partida guardada o salir.
2. Una escena de apertura presenta la situación. El jugador avanza el texto con Enter o Espacio.
3. De lunes a viernes, el jugador elige una de cinco actividades. Cada elección aumenta su contador de práctica y, cuando corresponde, el atributo asociado; también muestra una viñeta breve y avanza el día.
4. El sábado por la mañana se abre un sobre con cinco cartas nuevas. Después, el protagonista aparece en el interior de su casa; al salir puede recorrer el mapa.
5. En el mapa se pueden visitar lugares y jugar sus minijuegos. En la cafetería, la interacción con la mesa de Mizuki lleva a preparar la cita.
6. Para la cita se seleccionan cinco cartas de la colección. La cita tiene cuatro intercambios: Mizuki inicia cada uno y el jugador escoge una carta como respuesta.
7. El domingo se muestra el resumen de la semana. Al terminar la sexta semana se evalúan los requisitos de victoria o derrota.

La partida se guarda al llegar al resumen dominical y al abrir el sobre del sábado. El menú permite cargar la partida guardada.

## 4. Actividades y atributos

El menú semanal ofrece cinco actividades:

| Actividad | Atributo que aumenta | Seguimiento |
|---|---|---|
| Estudiar | Estudio (`int`) | Práctica de estudio |
| Pasatiempos | No aumenta un atributo numérico | La práctica de pasatiempos también se usa para calcular felicidad |
| Comunicación efectiva | Comunicación (`charm`) | Práctica de comunicación |
| Inteligencia emocional | Inteligencia emocional (`sense`) | Práctica de inteligencia emocional |
| Carisma | Carisma (`charm`) | Práctica de carisma |

Comunicación y carisma comparten el atributo `charm`, aunque sus contadores de práctica se mantienen separados. El juego registra la práctica total y la práctica de la semana para modificar la generación de cartas y mostrar el resumen. Las actividades tienen varias viñetas breves que se eligen al azar.

La pantalla semanal muestra el día, el número de semana, el protagonista, la actividad seleccionada, un radar de estudio, felicidad e inteligencia emocional, y el texto de la actividad. La felicidad se calcula a partir de la proporción de práctica dedicada a pasatiempos.

## 5. Mapa, movimiento y lugares

El mapa representa el pueblo donde vive el protagonista y los lugares que frecuenta. Está dividido en estas escenas de exploración:

- **Mapa principal:** casa y escuela.
- **East Map:** clínica y cafetería.
- **Interiores separados:** casa, escuela, clínica y cafetería.

El personaje se mueve con las flechas o WASD. Las colisiones con edificios, muebles y árboles bloquean el paso; las zonas de entrada y salida activan transiciones entre escenas. Al presionar **M** desde la escena semanal se abre el mapa y desde el mapa principal se vuelve a la escena semanal. Desde otras escenas de exploración, M permite regresar al mapa principal. **C** abre la colección de cartas.

Visitar una ubicación puede conceder una recompensa de actividad una vez por semana. Las zonas de interacción de los interiores activan los minijuegos o, en la cafetería, el armado del mazo para la cita.

## 6. Minijuegos y progreso

Los minijuegos no usan una probabilidad para decidir si el jugador gana. Al alcanzar un resultado terminal, cada partida concede **5 puntos** a su área y la misma partida no puede conceder el premio otra vez:

| Lugar | Minijuego | Recompensa |
|---|---|---|
| Casa | Snake | +5 puntos de pasatiempos, que cuentan para felicidad |
| Escuela | 2048 | +5 puntos de estudio y al atributo de estudio |
| Clínica | Flappy Bird | +5 puntos de inteligencia emocional y a su atributo |

El resultado terminal puede ser completar, perder o terminar la partida, según el minijuego. La recompensa se concede una sola vez por ejecución del minijuego. Si se juega el sábado, al salir se continúa hacia el armado de la cita; en otros días se regresa al mapa interior correspondiente.

## 7. Colección y generación de cartas

Cada sobre semanal agrega cinco cartas a la colección. Una carta tiene una frase, una categoría de respuesta y valores en los atributos heredados `int`, `charm` y `sense`. El atributo principal se selecciona según los valores del protagonista; los otros valores también pueden contribuir en menor medida.

Las cartas pertenecen a tres categorías:

- **Amistad:** respuestas de apoyo y comprensión.
- **Odio:** respuestas hostiles o hirientes.
- **Obsesión:** respuestas que refuerzan la idealización; pueden incluir cumplidos.

Las probabilidades base cambian después de la tercera semana. Las actividades practicadas las modifican proporcionalmente:

| Semanas | Amistad | Odio | Obsesión |
|---|---:|---:|---:|
| 1–3 | 45 % | 40 % | 15 % |
| 4–6 | 14 % | 23 % | 63 % |

Por cada punto de práctica se agrega peso a la categoría correspondiente: inteligencia emocional y comunicación favorecen amistad; estudio favorece odio; pasatiempos y carisma favorecen obsesión. La probabilidad de amistad tiene un máximo de 60 %. El carisma practicado durante la semana también puede hacer que una carta de obsesión use una frase de cumplido; esa posibilidad llega como máximo a 75 %.

Antes de una cita, el jugador selecciona cinco cartas de su colección para el mazo de esa cita. Se juegan cuatro y cada carta usada se elimina de la colección. Las cartas seleccionadas pero no jugadas permanecen en la colección.

## 8. Relación y citas

La partida comienza con 75 puntos de obsesión, 25 de amistad y 0 de odio. El resumen muestra la proporción de cada valor respecto del total acumulado; no es una escala única de afecto.

Al jugar una carta:

- Amistad suma un punto de amistad y resta cinco puntos de obsesión, hasta un mínimo de cero.
- Odio suma un punto de odio y resta tres puntos de obsesión, hasta un mínimo de cero.
- Obsesión suma un punto de obsesión.

Al resolver la cita, un resultado positivo suma un punto de amistad; uno negativo suma un punto de odio y reduce tres puntos de obsesión. La cita usa una tirada aleatoria. La probabilidad parte de 35 %, aumenta 10 puntos por cada carta de amistad jugada, baja 7 por cada carta de odio y 3 por cada carta de obsesión, y recibe un bono de hasta 18 puntos por comunicación e inteligencia emocional. El resultado final queda limitado entre 5 % y 95 %.

## 9. Resumen semanal y finales

El resumen dominical presenta los totales de estudio, felicidad e inteligencia emocional; las proporciones de obsesión, odio y amistad; las actividades de la semana; y los porcentajes de estudio y felicidad. Al avanzar después de los primeros cinco resúmenes comienza la semana siguiente. Tras el sexto, se evalúa el final.

Para **ganar** deben cumplirse al mismo tiempo estas condiciones:

- La proporción de odio debe ser menor que 30 %.
- La proporción de obsesión debe ser menor que 15 %.
- El atributo de estudio debe ser mayor que 30.
- La proporción de la práctica total dedicada a pasatiempos, que representa felicidad, debe ser mayor que 30 %.

Si se cumplen, la pantalla dice: **«Ahora Mizuki y tú son amigos.»**

Si se pierde, se muestran los motivos que correspondan:

- Odio: **«Mizuki terminó odiándote.»**
- Obsesión: **«Mizuki quedó obsesionada contigo.»**
- Estudio insuficiente: **«Pasaste mucho tiempo con tus amigos y en tus pasatiempos, pero descuidaste los estudios y no te graduarás.»**
- Felicidad insuficiente: **«Pasaste mucho tiempo estudiando y aprendiendo inteligencia emocional, pero descuidaste a tus amigos y tus pasatiempos. No eres feliz.»**
- Si faltan estudio y felicidad: **«Descuidaste tus estudios y tus pasatiempos. No te graduarás y también perdiste tiempo con tus amigos.»**

Las condiciones pueden combinarse: por ejemplo, un mensaje sobre la relación puede aparecer junto al mensaje de estudio o felicidad.

## 10. Presentación, controles y guardado

- La interfaz y las viñetas están en español.
- **Flechas / WASD:** moverse por los mapas.
- **M:** abrir o regresar al mapa según la escena.
- **C:** abrir la colección.
- **Flechas / A-D, Espacio / Enter y clic:** navegar y seleccionar opciones o cartas según la pantalla.
- **Espacio / Enter o clic:** avanzar la apertura, los textos, la cita y el resumen cuando corresponda.
- El menú inicial ofrece **Start**, **Load Game** y **Quit**.

## 11. Organización técnica actual

El proyecto usa una arquitectura ECS. Las escenas componen entidades de datos y sistemas pequeños que procesan movimiento, colisiones, transiciones, selección de actividades, generación de cartas, minijuegos, presentación y guardado. El estado de partida se conserva al cambiar de escena. Los interiores se construyen mediante una fábrica compartida con configuración distinta para cada lugar.

La historia ramificada, las conversaciones narrativas extensas y los desenlaces intermedios descritos en borradores anteriores no forman parte de la versión actual. El final implementado es una evaluación de relación, estudio y felicidad al cierre de la sexta semana.
