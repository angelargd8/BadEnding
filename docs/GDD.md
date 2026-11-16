# Bad Ending — Documento de diseño del juego

## 1. Concepto

**Género:** raising sim + card battler

**Premisa:** es un simulador de citas al revés. El protagonista no intenta conquistar a alguien; busca que la chica deje de idealizarlo y pueda conocerlo como realmente es. Quiere terminar la relación con honestidad, sin humillarla ni arruinar la posibilidad de una amistad.

Doce semanas antes de graduarse, un estudiante introvertido de tercer año se da cuenta de que su novia, una alumna extrovertida de primer año, está enamorada de una versión idealizada de él. Ella habla de esa versión con otras personas y atribuye al protagonista cualidades y acciones que no son reales. Aunque ella le cae bien, esa idealización le incomoda y la relación no es compatible con lo que ambos quieren, pero ella no se ha dado cuenta.

El título **Bad Ending** juega con la expectativa del género: el desenlace deseado no es que ella se enamore más, sino que ambos puedan separarse con claridad.

## 2. Personajes y escenario

- **Protagonista:** chico introvertido de tercer año en la escuela Ao Koukou. Su nombre y sus respuestas pueden quedar a elección del jugador. No es perfecto: puede ser torpe, reservado, impaciente o tener intereses que ella desconoce.

- **La chica:** estudiante extrovertida de primer año. No es una antagonista; está enamorada de una imagen idealizada y no se da cuenta de cuánto se aleja esa imagen de la realidad.

- **Lugar:** Osaka, principalmente Ao Koukou y sus alrededores.
- **Plazo:** las doce semanas previas a la graduación del protagonista.
- **Tono:** drama juvenil con humor ocasional. Las decisiones pueden ser incómodas y tener consecuencias, pero el juego no recompensa el abuso ni presenta el odio como una victoria.

## 3. Objetivo emocional

El jugador intenta comunicar una verdad difícil: “me caes bien, pero no soy la persona que imaginas y no quiero seguir en esta relación”. Las respuestas deben permitir:

1. **Aclarar malentendidos** y mostrar defectos o límites reales.
2. **Poner límites** de manera directa y respetuosa.
3. **Ser hiriente o evasivo**, dañando la confianza.
4. **Reforzar accidentalmente la idealización**, por ejemplo al aceptar un cumplido o evitar corregir una historia falsa.

El juego reconoce que una conversación no controla por completo los sentimientos de otra persona. El jugador sí controla si habla con honestidad, si evita la conversación y cómo trata a la chica.

## 4. Ciclo de juego

La partida cubre doce semanas. Cada semana combina actividades personales con una oportunidad de interactuar:

Antes de la primera semana, una escena de apertura presenta el monólogo del protagonista. El jugador avanza cada frase con Enter o Espacio.

1. El jugador elige cómo pasar sus días y qué habilidades practicar.
2. Esas elecciones influyen en las cartas de conversación disponibles.
3. La chica busca hablar, compartir rumores o pasar tiempo con el protagonista.
4. El jugador elige una respuesta o puede evitarla.
5. La conversación modifica la obsesión, el odio y la posibilidad de una amistad respetuosa.
6. Un resumen muestra qué cambió y avanza el calendario.

La graduación cierra la historia con un desenlace basado en las decisiones y el estado de la relación.

## 5. Actividades

Durante la semana, el protagonista puede dedicar tiempo a:

| Actividad | Desarrollo | Uso narrativo |
|---|---|---|
| Pasatiempos | Intereses propios y autoconocimiento | Ayuda a mostrar quién es fuera de la imagen que ella inventó. |
| Estudiar | Conocimiento y preparación para graduarse | Da recursos para explicar con claridad y corregir versiones falsas. |
| Practicar comunicación efectiva | Escuchar, expresarse con claridad y poner límites | Desbloquea respuestas directas, cuidadosas y honestas. |
| Practicar inteligencia emocional | Reconocer emociones propias y ajenas | Ayuda a responder sin escalar una conversación difícil. |
| Practicar carisma | Ensayar cumplidos y frases bonitas que sí sean sinceros | Puede aumentar la idealización; el protagonista debe evitar prometer sentimientos que no tiene. |

El prototipo conserva tres valores numéricos para las cartas (`int`, `charm`, `sense`) y registra por separado el tiempo dedicado a cada una de las cinco actividades. Así, carisma tiene su propio progreso aunque el formato actual de las cartas aún reutilice el eje numérico `charm`.

En el prototipo, los tres ejes comienzan en 1 y la interfaz muestra su proporción en un triángulo, sin revelar los valores exactos. Esta forma es una representación provisional de las habilidades, no una medida del valor personal del protagonista.

## 6. Cartas de conversación

Las cartas representan **respuestas**, no temas para conquistar a la chica. Cada carta contiene una frase y valores asociados a los tres ejes de habilidades. La colección determina qué respuestas aparecen durante una conversación.

Las cartas se generan en tres categorías de resultado:

- **Obsesión:** temas en común, estudio y cumplidos pueden hacer que ella se enamore más de la imagen idealizada.
- **Odio:** respuestas hirientes, que aparecen con más frecuencia si el protagonista no practica comunicación ni inteligencia emocional.
- **Amistad:** respuestas honestas y cuidadosas, más frecuentes cuando practica comunicación e inteligencia emocional.

Los valores de las cartas reflejan las habilidades practicadas, pero no hacen que una respuesta sea moralmente correcta por tener un número alto. El sentido narrativo de la frase y el contexto también cuentan.

**Cómo se inclina el mazo:** si no ha practicado comunicación ni inteligencia emocional, el 65 % de las cartas se genera como respuesta de odio. Cada práctica de esas habilidades reduce esa probabilidad en cinco puntos, hasta un mínimo del 10 %. Las cartas restantes se reparten entre obsesión y amistad. Su peso inicial es 1 para cada categoría; cada práctica de estudio o pasatiempos suma 0.15 al peso de obsesión, y cada práctica de carisma suma 0.35. Cada práctica de comunicación o inteligencia emocional suma 0.35 al peso de amistad. Estudio y pasatiempos generan temas en común y refuerzan que a ella le atrae que él sea estudioso; carisma aporta cumplidos y aumenta su frecuencia un 10 % por práctica, hasta el 75 %. Comunicación e inteligencia emocional hacen más frecuentes las respuestas de amistad. Estos pesos son parámetros iniciales para ajustar en pruebas de juego.

## 7. Estados de la relación

Las conversaciones y la evitación modifican tres valores independientes:

| Estado | Identificador heredado | Qué representa |
|---|---|---|
| **Obsesión** | `obsession` | Cuánto se aferra ella a la versión idealizada del protagonista. No equivale a una relación sana. |
| **Odio** | `hate` | Resentimiento causado por el rechazo, la evasión o las respuestas crueles. |
| **Amistad** | `friendshipness` | Confianza para aceptar los límites y conservar una amistad respetuosa. |

Evitarla o ignorarla no reduce por sí solo la obsesión; sí incrementa el odio porque deja los malentendidos sin resolver. Hablar con ella puede reducir la idealización y aumentar la amistad, pero una respuesta hiriente puede aumentar el odio y una respuesta complaciente puede reforzar la obsesión.

Estos estados no son una sola barra: es posible que coexistan sentimientos contradictorios. El diseño final debe evitar que el jugador pueda optimizar el rechazo como si fuera una puntuación de combate.

## 8. Desenlaces

La graduación ocurre al final de la semana doce. Los desenlaces se determinan por las conversaciones, los límites expresados y los tres estados de relación.

- **Amistad respetuosa:** ella entiende que la imagen que tenía no era realista; ambos aceptan terminar la relación y conservar una amistad con límites claros.
- **Separación amarga:** la relación termina, pero la evasión o las respuestas hirientes dejan resentimiento.
- **Idealización persistente:** ella sigue aferrada a la versión inventada y no acepta plenamente la incompatibilidad.
- **Desenlace abierto:** la conversación no resuelve todo, pero el protagonista es honesto y deja que ella decida qué hacer con esa verdad.

Los nombres y umbrales de los finales se deben validar con pruebas de juego. La amistad es un desenlace positivo, aunque no signifique seguir como pareja.

## 9. Presentación y accesibilidad narrativa

- La interfaz y los textos del juego estarán en español.
- Mostrar con claridad qué respuesta se está eligiendo; los valores de relación pueden presentarse mediante cambios cualitativos en diálogos, retratos y resúmenes.
- Evitar que el juego etiquete a la chica como “loca” o culpable por sentir afecto. El conflicto nace de una idealización y de la incompatibilidad, no de que sentir cariño sea malo.
- Mantener al protagonista falible. La historia no debe convertir su versión de los hechos en verdad absoluta sin espacio para reconocer sus propias acciones.

## 10. Alcance de la primera versión

1. Calendario de doce semanas y ciclo de actividades.
2. Escena de apertura con el monólogo inicial y avance por Enter o Espacio.
3. Cinco actividades: pasatiempos, estudio, comunicación efectiva, inteligencia emocional y carisma.
4. Conversaciones con opciones de respuesta en forma de cartas.
5. Tres valores independientes de relación: obsesión, odio y amistad.
6. Consecuencias explícitas para hablar, evitarla o ignorarla.
7. Escenas en Ao Koukou, Osaka, y finales de graduación.

Las escenas de mapa, generación de cartas y entrenamiento que ya existen son prototipos técnicos. Todavía no implementan el sistema completo de conversación ni los desenlaces de este documento.
