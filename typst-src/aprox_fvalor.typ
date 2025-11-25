== Value Function Approximation

Recordemos que $v_pi = EE_pi [G_t | S_t =s]$ es la funicon de valor de estado bajo la política $pi$, y la funcion de valor de acción es $q_pi (s, a) = EE_pi [G_t | S_t = s, A_t = a]$, existe un número de estados/acciones y se puede guardar v(s) o q(s,a) en una tabla.

En RL el tamaño de un problema está determinado principalmente por su espacio de estados (y tambien acciones.)

Con ejemplos de Silver sencillos, de \<10 estados podía hacer una tabla, para cada estado s, guardaba un número V(s) o para cada par $(s,a)$ guardaba $Q(s,a)$.
Pero para ejemplos como Go $10^170$ es tan grande que si ocuparamos 1 byte por estado se necesitarian $10^170$ bytes $approx$ $10^158$ TB, lo cual es imposiblel, y en escenarios como el ejemplo del helicoptero, los etsados son infinitos, tenemos el peor de los casos. 

Silver ilistraba ejemplos de lookup table, que basicamente es una tabla, tienes un indice por estados s, y ahí guardas un número $V(s)$, y si trabajas con $Q$ una entrada por par (s,a). Formalmente esto es una función $V(s = \t\a\b\l\a\[s]$, no hay estructura, cada valor de estado es independiente.

Es correcto usar esto cuando el numero de estados $|S|$ es pequeño.

Necesitamos aprovechar estructura y similitud entre estados, como estados \"parecidos" deberían tener valores parecidos, aquí es donde entra la aproximación de funciones. 

*Idea central:* en lugar de tener una tabla sin estructura, modelamos la funcion de valor como una función parametrizada.

*$v(s,w) approx v_pi(s)$ o $q(s,a,w) approx q_pi (s,a)$*, donde w es un vector de parámetros (pesos). pudiendo ser un vector de pesos de un modelo lineal, todos los pesos de una red neuronal, parámetros de un árbol de desicicon, etc.

En lugar de guardar un número independiente para cada estado, aprendes una fórmula general de parámetros *w* que te da un valor para cualquier estado, ganando así una generalización. *Debemos minimizar el error de la predicción*

== Métodos incrementales.
*Gradient Descent*

Sea $J(w)$ una funcion diferenciable de el vector de parámetros $w$. Definimos el gradiente como:

$nabla_w J(w) = mat(partial J(w)/(partial_(w_1)); ... ; partial J(w)/partial_(w_n) )$ 
para encontrar un mínimo local de $J(w)$, ajustamos w en la dirección del gradiente negativo $nabla w  = -1/2 alpha nabla_w J(w)$ donde $alpha$ es el step-size (taza de aprendizaje).

Como queremos minimizar $J(w)$, así que no queremos ir hacia donde crece, si no hacia donde disminuye, usando aproximacón de tylor llegamos a:
$
  w_(n u e v o) = w_ (v i e j o) + nabla w = w_(v i e j o) - 1/2 alpha nabla_w J(w_(v i e j o))
$
el $-1/2$ es una convención que podriua ser absorbida por $eta : = -1/2 alpha$
