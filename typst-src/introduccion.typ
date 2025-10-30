== Introduction to Reinforcement Learning
El aprendizaje por refuerzo aparece en la interseccioón de muchos campos. En ciencias computacionales se estudia como parte del machine learning; en neurociencia se relaciona con los sistemas de recompensa; en psicología con el condicionamiento clásico y operante; en economía con la racionalidad limitada y la toma de decisiones secuenciales; en matemáticas con la investigación de operaciones; y en ingeniería con el control óptimo.

*Nota* el M-L se podria ver como una interseccion entre aprendizaje supervisado, el no supervisado y el aprendizaje por refuerzo.

== Reward
Una recompensa (reward) $R_t$ es una señal numérica (escalar) que llega en el paso t. Sirve para indicar que tan bien va el agente en ese instant. Su meta es maximizar la reocmpensa acumulado (a lo largo del tiempo).

*Hipótesis de la recomepnsa* "todo objetivo que un agente puede perseguir puede especificarse como la maximizacion del valor esperado de una señal escalar de recompensa a lo largo del tiempo".

Asimismo nos encontramos con desiciones secuenciales, el cual su objetivo es elegir acciones que maximicen la recompensa futura total. Algo muy importante es que as acciones tienen efectos a largo plazo, la recompensa puede retrasarse; aveces conviene sacrificar lo inmediato para ganar más después.

*Agente y entorno* 
En cada paso $t$ el agente ejecuta $A_t$ (accion tomada en t) y el entorno devuelve una observacion $O_(t+1)$ y una recompensa $R_(t+1)$. Note que el tiempo t avanza con cada paso del entorno.

*Historia y estado*

Definimos la historia como $H_t$: todo lo observado y hecho hasta t.

$H_t = (O_1,R_1,A_1,...,O_t,R_t)$. La historia es algo muy fuerte, peor muy costoso, pues incluye *todo* lo hecho hasta el tiempo t.

El estado $S_t$ es la información relevante para decidir qué pasa después. Formalmente $S_t = f(H_t)$.

*Estado del entorno $S^e_t$*: representación privada del entorno: datos que usa para generar la proxima observación y recompensa. Normalmente no es visible para el agente y si lo feura puede tener informacion no relevante.

*Estado del agente $S^a_t$*: es la representación interna del agente, es la información que el agente construye para elegir la siguiente acción. Puede ser cualquier funcion de la historia: $S^a_t = f(H_t)$.

*Estado de información (estado de markov)* contiene toda la info útil del pasado; el futuro no depende del pasado si conoces el presente. $S_t$ es Marcov si *$PP[S_(t+1)| S_t] = PP[S_(t+1)| S_1,...S_t]$.* En consecuencia el estado del entorno $S^e_t$ es de Marcov por construcción y $H_t$ tambien es Marcov pero es grande, por eso buscamos un buen $S^a_t$ apartir de observaciones parciales (POMDP).

*Entorno totalmente observable (MDP)*

El agente ve directamente el verdadero estado del entorno, formalmente $O_t = S^e_t = S_t$ (observación = estado del entorno = estado de información). Se puede pensar como jugar ajedrez, vemos todo el tablero.

*Entorno parcialmente observable (POMDP)*
El agente no ve todo; sólo recibe observaciones $O_t$ que no revelan el estado real $S^e_t$.

Consecuencias: El agente construye un estado interno $S^a_t$
- opcion 1: usar la historia completa $S^a_t = H_t$
- Opción 2: creencia sobre el estado es decir una estadística. $S^a_t = PP[S^e_t = s^1],...,PP[S^e_t = s^n]$.
- Opcion 3: red neuronal recurrente $S^a_t = σ(S^a_(t-1)W_s + O_t W_o)$

== Componentes principales de un agente RL
- *Política $pi$ :* mapea estado $->$ acción.
- *Función de valor:* mide "que tan bueno" es un estado (o estado-acción).
- *Modelo:* representa la dinámica del entorno (las transiciones y recompensas).

Una *política* puede ser determinista, es decir que siempre elige la misma acción para un estado (s) en específico, formalmente: *$a = pi(s)$*.

De manera similar existe la política estocástica, esta define una distribución de probabilidad sobre acciones para un estado dado. Esto significa que, para un mismo estado (s), el agente puede tomar diferentes acciones (a) en distintos momentos. 

La función de valor es una predicción de la recompensa futura, que un agente puede recibir al estar en un estado particular. Su funcion es evaluar la calidad de los estados, lo que a su vez ayuda al agente a seleccionar mejor las acciones. Formalmente:

 *$V_pi (s) = EE_pi [R_(t+1) + γ R_(t+2) + γ^2 R_(t+3) + ... | S_t = s]$*

- donde $v_pi (s)$ es el valor esperado de estar en el estado s y seguir una política $pi$ a apartir de ese momento.
- $EE_pi [.]$ indica el promedio ponderado de todos los posibles resultados, siguiendo la política $pi$.
- $R_(t+1), R_(t+2)...:$ las recompensas que el agente recibe en lo spasos de tiempo futuro.
- $γ$ es el factor de descuento, un valor entre 0 y 1. Si $γ$ es cercano a 0, el agente se enfoca en las recompensas inmediatas, si $γ$ es cercano a 1 el agente prioriza las recompensas a largo plazo

Un *Modelo* predice que hará el entorno a continuación. Es una reresentación del entorno que el agente utiliza para predecir. Se compone de dos elementos claves:

- Transiciones $cal(P)$: predicen el siguiente estado, formalmente *$cal(P)^a_(s s') = PP[S_(t+1) = s' | S_t = s, A_t = a]$*. Es la probabilidad de que el próximo estado sea s' si ahora estas en s y haces a. En casos deterministas es igual a 0 o 1.
- Recompensas $cal(R)$: predice la recompensa inmediata. Un modelo de recompensa predice cual será la recompensa inmediata que el agente recibirá después de ejecutar una acción específica. Formalmente *$cal(R)^a_t = EE [R_(t+1) | S_t = s, A_t = a]$*.



