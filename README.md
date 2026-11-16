# Bad Ending

# Vídeos: 
### UI SYSTEM: 
[Vídeo](https://youtu.be/2agKx_-WqXQ)


Historia interactiva en Lua y LÖVE 11.5. Durante las doce semanas antes de
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
instante.

## Sistemas de interfaz

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
protagonista. Estudio y pasatiempos inclinan las cartas hacia temas compartidos
y obsesión; comunicación e inteligencia emocional favorecen respuestas de
amistad y reducen las respuestas de odio; carisma practica cumplidos.

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

**Descripción.** Muestra el día y la semana actual junto con un radar que
representa la proporción entre las tres estadísticas numéricas del prototipo.

**Implementación (`Setup → Update → Render`).**
`DateRenderSystem.setup()` y `RadarRenderSystem.setup()` preparan sus fuentes.
`DayLoopSystem.update()` avanza el calendario y `StatsSystem.update()` modifica
las habilidades al elegir actividades. `DateRenderSystem.draw()` y
`RadarRenderSystem.draw()` leen `RunState` y dibujan el HUD; el radar muestra la
forma relativa de las estadísticas, no sus valores exactos.

**Conexión con el juego.** El calendario sitúa el avance de la partida dentro
del plazo de doce semanas. El radar hace visible el efecto de las actividades
en las habilidades del protagonista.

## Estado del prototipo

`main.lua` inicia `WeekScene`, donde las tres interfaces están registradas y
conectadas al estado del juego. La escena semanal actualiza actividades,
calendario y texto. El generador de cartas existe en una escena de laboratorio
separada; la escena de conversación todavía no está implementada, así que las
cartas ya se clasifican como obsesión, odio o amistad, pero aún no modifican
esos estados al jugarse.

No hay una implementación de Breakout en la partida principal. Los ejemplos de
Pong bajo `lesson/pong/` son material didáctico independiente y no se cargan
desde `main.lua`; las menciones a Breakout en las páginas del curso son texto
de enseñanza, no código del juego.
