# Bad Ending

# Vídeos: 
[Vídeo Progression-Cycle](https://youtu.be/Ct-qHc0fFi8)


[Vídeo UI SYSTEM](https://youtu.be/2agKx_-WqXQ)


Historia interactiva en Lua y LÖVE 11.5. Durante las seis semanas antes de
graduarse, un estudiante introvertido de tercer año intenta terminar con
honestidad una relación con una alumna extrovertida de primer año, quien está
enamorada de una versión idealizada de él. Las actividades semanales influyen
en las respuestas disponibles y en el rumbo de la relación.

## Ejecutar

Desde la raíz del proyecto:

```sh
love .
```

La partida comienza con una escena narrativa. Usa Enter, Espacio o clic
izquierdo para pasar cada frase; al terminar, se abre la semana de actividades. En la semana, usa
las flechas izquierda y derecha para seleccionar una actividad y Enter o
Espacio para elegirla. Cada elección actualiza el estado, muestra una viñeta
y avanza el día. Durante la viñeta, Enter termina de escribir el texto al
instante. Pulsa C en cualquier escena para abrir la colección y C otra vez
para volver exactamente a la escena anterior.

Para depurar, `E` o `F1` muestra u oculta las herramientas; `F` o `F9` pausa o
reanuda el juego; `Q` o `F10` avanza un cuadro mientras está pausado. Ejecutar
`love . --debug` también abre el editor con el juego dentro de una vista ampliada.

## Progression-Cycle

La partida conecta la preparación semanal con el mazo de respuestas:

1. De lunes a viernes, el jugador elige una actividad. Cada elección modifica
   las estadísticas acumuladas y registra la práctica de esa semana.
2. Al terminar el viernes, la fecha pasa a sábado por la mañana y se abre un
   sobre con cinco cartas. Su tipo depende de la semana y del progreso
   acumulado hasta abrir el sobre.
3. Las cinco cartas se agregan una sola vez al `runState.collection`. El mazo
   acumula las cartas de las semanas anteriores y las conserva hasta que se
   utilicen en una conversación.
4. C abre la colección desde cualquier escena. Se muestran hasta diez cartas
   por página, en dos filas de cinco; cada carta lleva en su parte superior un
   icono que indica si favorece la obsesión, el odio o la amistad. Las flechas
   permiten recorrer las páginas del mazo. C cierra la colección y reanuda la
   escena pausada, sin avanzar el día ni repetir una actividad.
5. En la apertura del sábado, Enter o Espacio comienza la semana siguiente y
   reinicia el contador de práctica semanal. Al terminar el sobre de la sexta
   semana, el ciclo concluye y no se inicia una séptima semana.

Estudiar desarrolla `int`, comunicación y carisma desarrollan `charm`, y entrenar
inteligencia emocional desarrolla `sense`. Estos valores influyen en la habilidad
principal y los números de cada carta. Los pasatiempos suman felicidad.

La amistad y el odio son las cartas más frecuentes al inicio. Desde la semana 4,
la base favorece la obsesión. Los puntos acumulados en IE y comunicación favorecen
la amistad (hasta el 60 % por carta), los de estudio favorecen el odio y los de
pasatiempos o carisma favorecen la obsesión. Si sale obsesión, el carisma practicado
esa semana también influye en la posibilidad de que la frase sea un cumplido.

Sí, se usa aleatoriedad: cada sobre recibe una semilla aleatoria y se hacen
sorteos para la habilidad principal, los valores, el resultado y la frase. Las
estadísticas inclinan las probabilidades, pero no garantizan una carta concreta.
Los datos de partida y la colección viven en el mismo `runState` mientras el
juego está abierto; guardar en disco es independiente.

## UI-Systems

La escena semanal compone tres interfaces: el menú de actividades, el cuadro
de texto y el HUD de semana/estadísticas. En este motor, `draw()` es la etapa
de renderizado. La escena ejecuta `setup()` una vez al entrar y luego llama
`update(dt)` y `draw()` cada cuadro. Cada interfaz separa esas etapas entre
sistemas ECS pequeños: los sistemas de presentación preparan recursos y
dibujan; los sistemas de comportamiento leen entradas y actualizan el estado.

### 1. Menú de actividades

**Descripción.** Muestra cinco opciones: estudiar, pasatiempos, comunicación
efectiva, inteligencia emocional y carisma. El cursor indica cuál está
seleccionada.

**Implementación (`Setup → Update → Render`).** `MenuRenderSystem.setup()`
crea las fuentes. `MenuInputSystem.update()` mueve el cursor y, al confirmar,
emite `activityPicked`; `StatsSystem.update()` aplica la actividad a las
estadísticas y al registro de práctica. `MenuRenderSystem.draw()` representa
las opciones leyendo el componente `menu`. En este proyecto, `draw()` cumple
el papel de `Render`.

**Conexión con el juego.** Las actividades definen en qué se prepara el
protagonista. Dedicar más días al estudio aumenta la posibilidad de recibir cartas
de odio. Practicar comunicación o IE favorece la amistad, y elegir pasatiempos o
carisma favorece la obsesión.

### 2. Cuadro de texto y viñetas

**Descripción.** Presenta la pregunta del día y una viñeta breve después de
elegir una actividad, con un efecto de texto que aparece progresivamente.

**Implementación (`Setup → Update → Render`).**
`TextboxRenderSystem.setup()` crea la fuente. `VignetteSystem.update()` escribe
la línea asociada a la actividad; `DayLoopSystem.update()` controla la fase y
el avance del día; `TextboxSystem.update()` incrementa `visibleChars` para el
efecto de máquina de escribir. `TextboxRenderSystem.draw()` dibuja el panel y
el fragmento visible del texto.

**Conexión con el juego.** Las viñetas muestran cómo las decisiones afectan
al protagonista y dan contexto emocional a la preparación antes de conversar
con la chica.

### 3. HUD de semana y habilidades

**Descripción.** Muestra el día y la semana actual junto con un radar de estudio,
felicidad e inteligencia emocional. La estrella indica los puntos acumulados
por pasatiempos, incluidos los que se ganan jugando Snake.

**Implementación (`Setup → Update → Render`).**
`DateRenderSystem.setup()` y `RadarRenderSystem.setup()` preparan sus fuentes.
`DayLoopSystem.update()` avanza el calendario y `StatsSystem.update()` modifica
las habilidades al elegir actividades. `DateRenderSystem.draw()` y
`RadarRenderSystem.draw()` leen `RunState` y dibujan el HUD; el radar muestra la
forma relativa de las estadísticas, no sus valores exactos.

**Conexión con el juego.** El calendario sitúa el avance de la partida dentro
del plazo de seis semanas. El radar hace visible el efecto de las actividades
en las habilidades del protagonista.

## Estado del prototipo

`main.lua` inicia la escena narrativa y luego la semana de actividades. El
ciclo semanal incluye la apertura de sobre del sábado y el acceso a la
colección. `PackLabScene` permanece como laboratorio independiente para ajustar
la generación de cartas. La escena de conversación todavía está pendiente; las
cartas se conservan en el mazo hasta que esa mecánica permita jugarlas y
consumirlas.
