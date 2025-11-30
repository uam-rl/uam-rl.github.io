#import "template.typ" as tp
#show: tp.cool-web-page.with(
  current-file: "R1.typ",
)
== DeepSeek-R1: incentivar la capacidad de razonamiento en los LLM meidante el aprendizaje por refuerzo.

*Introduction*

El post-entrenamiento mejora la presición de tareas de razonamiento, alinea los modelos con valores sociales y se adapt a preferencias de usuarios, ocupando poco gasto computacional comparado con el pre entrenamiento.

Comenzaron recopilando miles de prompts orientado al razonamiento para afinar (SFT) el modelo DeepSeek-V3-Base, dspues se le aplico RL orientado al razonamiento com en R1-zero (entrenado con RL puro. Se obtuvo un alcance de razonamiento comparable a OpenAI 01-1217.

Hay dos maneras de hacer que un LLM "razone" mejor: *Gastando más cómputo en la inferencia* (hacer que "piense" mas tiempo con cadenas de pensamiento largas y votaciones.). 2. *Entrenándolo para que razone mejor de fábrica (cambiar sus parámetros con RL para que, aun pensando poco, elija mejores pasos)*. Apostando por la segunda.

Se destilaron modelos densos más pequeños desde DeepSeek-R1. Los modelos destilados de 32B y 70B establecen un nuevo récord en benchmarks de razonamiento 

*Approach*
Para DeepSeek-R1-zero, adoptamos un modelo de recompensa basado en reglas que consisten principalmente en dos tipos de recompensas: *Recompensas de exactitud:* la cual evalua si la respuesta es correcta. *Recompensas de formato:* obliga al modelo a poner su proceso de pensamiento entre etiquetas \<think> y \</think>. Donde think son las etiquetas del proceso de razonamiento. No se aplica un modelo de recompensa neuronal de resultado o de proceso porque peude sufrir reward hacking en el proceso de aprendizaje ppr refuerzo a gran escala. 

Para entrenar DeepSeek-R1-zero, se requeria que primero produzca un proceso de razonamiento, seguido de la respuesta final. Obtiene un rendimiento en un promedio de pass\@1 saltando de un 15.6% inicial a un 71%, lo cual es comparable ocn OpenAI o1-0912. Esto destaca la eficacia del algoritmo de RL.
DS-R1-zero alcanza capacidades de razonamiento sin necesidad de ningun fine-tuning supervisado. El p´roceso de auto-evolucion mejora sus capacidades de razonamiento de manera autónoma. DeepSeek-R1-zero adquiere de forma natural la capacidad de resolver tareas de razonamiento cada vez más complejas aprovechando la computación de tiempo de prueba extendida. 

Aunque DeepSeek-R1-zero exhibe fuertes capacidades de razonamiento y desarrollo de manera autónoma comportmientos de razonamiento inesperados y poderosos, enfrenta enfrenta varios problemas principalmente mezcla de idiomas y legibilidad. Para mejorar esto exploraremos DeepSeek-R1, el método que utiliza RL con datos iniciales (cold-start).

== DeepSeek-R1: Aprendizaje por refuerzo con Cold Start
Se diseñó un pipeline para entrenar DeepSeek-R1 que consta de cuatro etapas:

*1Cold Star* antes de aplicar otra ronda de RL, afinan el modelo con pocos ejemplos cuadrados (CoT largos, reflexivos y verificados), esto acorta la fase inestable de RL y mantiene la fuerza de razonamiento de R1-Zero y entrega cadenas claras eliminando salidas que no sean fáciles de leer. El formato de salida es \<special_token><reasoning_process></special_token><summary>,

*2Aprendizaje RL orientado al razonamiento* Despues de afinar DeepSeek-V3-Base con los datos cold-start, se aplica el mismo proceso de entrenamiento por refuerzo a gran escala empleado en DeepSeek-R1-Zero, centrandoce en mejorar las capacidades de razonamiento del modelo. Durante el entrenamiento, se observa que las cadenas de razonamiento (CoT) a veces mezclan idiomas, especialmente cuando el RL promueve múltiples idiomas. Para mitigar el problema introducen una recompensa de consistencia linguística, calculada como la proporción de palabras en el idioma objetivo dentro de la Cot. Aunque esto puede degradar el modelo segun ablation.

*4Muestreo por rechazo y ahuste fino supervisado.* se usa depsues del RL para generar datos supervisados, el modelo genera varias repsuestas por promp y un evaluador elige las mejores, es como un filtro inteligente, donde solo se conservan las mejores soluciones,  lo que produce datos curados de maenra automatica, a aeste flujo se le conoce como *Datos de razonamiento*. Despues vienen datos de redaccion, traducción, etc. asi el modelo no solo razona, tambien se comunica bien, y a esto se le llama *Datos no-razonamiento*. Para alinear aun más el modelo se implemta una segunda etapa de RL orientada a mejorar la utilidad y la inocuidad mientras se refinan simultáneamente sus capacidades de razonamiento.A esto le llaman *RL para todo escenario*, por ultimo *destilación* se selecciona Llma3-8B y Llama3-3.3 porque su capacidad de razonamiento es ligeramente mejor que Llama3-1. Para los modelos destilados solo aplicaron SFT y no realizaron una etapa de R


