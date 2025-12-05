
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

 *Stochastic Gradient Descent*

Definimos la función de costos 
$
  J(w) = EE_pi[(V_pi (S) - arrow(v)(S,w))^2 ]
$
Donde $arrow(v)(S,w)$ es la aproximación paramétrica con pesos $w$, y $V_pi (S) $ es el valor verdadero del estado S bajo la politica $pi$ (no lo conocemos, pero imaginemos que sí).
 $=>$ $J(w) = $ error cuadrático medio entre $v_pi $ y $arrow(v)$

 Sea $J(w) = EE_pi [(V_pi (S) - arrow(v)(S,w))^2 ]$ 

 Usamos que la derivada de una esperanza es la esperanza de la derivada:

 $nabla_w J(w) = nabla_w EE_pi [(V_pi (S) - arrow(v)(S,w))^2] = EE_pi [nabla_w (v_pi (S) - arrow(v)(S, w))^2]$

 Para derivar el cuadrado usamos regla de la cadena:

 Sea $e(S,w) := v_pi (S) - arrow(v)(S,w)$ (el error) 

 $=> (v_pi (S) - arrow(v)(S, w))^2 = (e(S,w))^2$ 

 $=> nabla_w (e^2) = 2e nabla_w e$

 Ahora calculamos $nabla_w e: $ $v_pi(S) $ no depende de w $->$ su gradiente es 0

 Como $arrow(v) (S,w) $ si depende de w

 $nabla_w e = nabla_w (v_pi (S) - nabla_w (arrow(v) (S,w))) = 0 -nabla_w arrow(v) (S,w) = - nabla_w arrow(v) (S,w)$

 $=> nabla_w (e^2) = 2e nabla_w e = 2(v_pi (S)-arrow(v) (S,w)) =  -2(v_pi (S) - arrow(v) (S, w)) nabla_w arrow(v) (S,w)$  

 Metemos eso a la esperanza:

 $nabla_w J(w) = EE_pi [nabla_w (v_pi (S) - arrow(v) (S,w))^2] = EE_pi [-2(v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)]$

 sacamos el -2

 $nabla_w J(w) = -2 EE_pi [(v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)]$

 Esto es el gradiente completo.

 $nabla w = -1/2 alpha (-2 EE_pi [(v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)])$

 $nabla w = alpha EE_pi [(v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)]$

 Hasta ahora necesitamos calcular la esperanza, es decir promediar todoso los estados según su probabilidad, eso es caro o imposble de hacer, entonces usamos la idea de *stochastic gradient descent (SGD* en vez de usar la esperanza completa, usamos una muestra.

 *$ nabla w  = alpha (v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)]) ) $*

 Aquí SGD es una aproximación "no sesgada" del gradiente.

 *Feature Vectors*

 Representamos el estado por un vector de características 
 $x(S) = mat(x_1 (S); dots.v; x_n(S))$
En vez de trabajar con la representación "cruda", definimos un vector de características $x(S)$, donde cada $x_i (S)$ es una función $x_i : "Estados" -> RR$ del estado que extrae información relevante.

*¿Cómo usamos estas caractiristicas?*

Representamos la función de valor mediante una combinación lineal de características, ese número será la predicción del valor $v_pi (S)$

 $arrow(v) (S, w) = x(S)^T w = sum_(j=1) ^n x_j (S)w_j $ simplemente es un producto punto, cada caracteristica dice algo sobre el estado, el peso $w_i $ indica cuánto aporta esa característica al valor total.

Derivamos

 $nabla_w arrow(v) (S,w) = x(S)$

 Recordemos que $nabla w  = alpha (v_pi (S) - arrow(v) (S,w)) nabla_w arrow(v) (S,w)]) )$

 sustituyendo en el gradiente:

$ nabla w  = alpha (v_pi (S) - arrow(v) (S,w)) x(S))$

$"error" (S) = v_pi (S) - arrow(v) (S,w)$

- Si es positivo, nuestra prediccióin es demasiado baja, queremos subirla, y viceversa.
- update = tasa × error × entrada.

Supongamos que hay un número finito de estados: $S = {s_1 , ..., s_n}$ Silver define $x^("table)" (S)) = mat(1(S = s_1); dots.v ; 1(S = s_n)) $ donde 1(⋅) es la función indicadora, $1(S = s_i ) = 1 "si el estado es exactamente " s_i, 1(S=s_i) = 0 "en otro caso"$ entonces si S = $s_k$ 

$x^("table)" (S) = (0,...,0,1,0,...0)^T  $
un vector one-hot, todo 0, exepto 1 en la posición k.

Usando el modelo líneal con estas features  $arrow(v) (S,w) = (x^("table") (S))^T w$, si $S_s_k$ 

$=> arrow(v) (S,w) = w_k  $

*Incremental Prediction Algorithms*

Hasta ahora asumiamos que teníamos $v_pi (S) $ como "etiqueta correcta", en RL no tenemos $v_pi (S)$; solo recompensas, entonces usamos un target (una estimación)

*Targets:*

para Monte Carlo (MC):
$
  nabla w = alpha (G_t - arrow(v) (S,w))nabla_w arrow(v) (S_t,w)
$

El caso de MC solo toma el caso particular Target = $G_t$, y en el caso líneal $nabla_W arrow(v) (S_t, w) = x(S_t)$ así que finalmente 

$nabla w = alpha(G_t - arrow(v) (S_T, w))x(S_t)$

Para TD(0): 
$
  nabla w = alpha (R_(t+1) + gamma arrow(v) (S_(t+1), w) - arrow(v) (S_t, w))nabla_w arrow(v) (S_t,w)
$

Para una política fija $pi$, el valor verdadero en el estdado $S_t$ es $v_pi (S_t) = EE_pi [G_t|S_t]$, definimos el target de paso: TD-targe$t_t$ = $R_(t+1) + gamma arrow(v) (S_(t+1), w)$ toma el valor de la recompensa inmediata $R_(t+1)$ mas el valor descontado del siguiente estado segun mi propia aproximación $arrow(v) = (.,w) $ esto viene con error


Para TD($lambda$)
$
  nabla w = alpha (G_t^lambda - arrow(v) (S_t, w))nabla_w arrow(v) (S_t, w)
$
Queremos algo intermedioentre TD(0) Y MC, sea $G_t^lambda = (1-lambda)sum_(n=1)^infinity lambda^(n-1) G_t^n$ donde cada $G_t^n$ es un return de n pasos que mira recopensas y luego bootstrtap con $arrow(v)$, por eso decimos que $G_t^lambda$ tambien es sesgado, por que cada $G_t^n$ suele usar $arrow(v)$ al final y ahí entra el sesgo de aproximación.

Aquí encontramos un error normal que definimos como $delta_t = R_(t+1) + gamma arrow(v) (S_(t+1), w) - arrow(v)(S_(t), w )$

Si  $delta_t > 0 $ la realidad fue mejor que lo que esperabas $->$ tus valores están demasiado bajos.

Si $delta_t < 0$ la realidad fue pero $->$
tus valores están demasiado altos.

$E_t = gamma lambda E_(t-1) + x(S_t)$

esto define la traza de elegebilidad $E_t$, que es un vector del mismo tamaño que $w$.

$E_(t-1) $ es la traza en el paso anterior, multiplicas por $gamma lambda$ y esto desvance la Contribución de estados viejos, luego sumamos $x(S_t) $ el estado actual entra con peso 1, digamos que $E_t$ guarda un recuerdo borroso que ha sido visitado recientemente. Cuanto mas reciente un estado, mayor peso tiene su caracteristica en $E_t$ 

$nabla w = alpha delta_t E_t$  es la regla de actualización, tomas el TD- error actual, $delta_t$ lo multiplicas por la traza $E_t$ que reparte el error entre los estados recientes y escalas por $alpha$ y este es el ca,bio de $w$
 

\
\
\

\
Note que todos tienen la misma forma $nabla w = alpha ( "target" - "predicción") nabla_w arrow(v)$


*Action-Value Function Approximation*

antes habiamos aproximado la función de valor de estadpo $v_pi (s)$, ahora queremos aproximar la función de valor de accion $q_pi (s,a)$, el valor esperado de empezar en s y tomar la acción a, y luego swguir la política $pi$ *$arrow(q) (S,A,w) approx q_pi (S, A)$*.

Esto es analogo a lo que haciamos con $v_pi$, tenemos nuestra función objetivo

$J(w) = EE_pi [(q_pi (S, A) - arrow(q) (S,A, w))^2]$, donde (S,A) son los pares que vemos siguiendo la politica $pi$, y el objetivo es minimizar el error cuadrático medio entre el valor verdadero $q_pi $ y nuestras aproximación $arrow(q ) (S, A, w)$  

Sigueindo con lo mismo derivando usando regla de la cadena

$-1/2 nabla_w J(w) = (q_pi (S,A) - arrow(q) (S,A,w))nabla_w arrow(q) (S,A,w)$

$nabla w = alpha(q_pi (S,A) - arrow(q) (S,A,w))nabla_w arrow(q) (S,A,w)$ 

lo que es update = step-size × (error de predicción) × (gradiente de la predicción)

Nuevamente como no conocemos el valor exacato de $q_pi (S,A)$, lo sustituimos por un target TD o MC.

Analogamente antes teníamos x(S) para estados, ahora queremos aproximar q(S,A) así que las features dependen del par (estado, acción), $x_i (S,A)$ es la i-ésima característica numérica del par (S,A).

Sea $x(S,A) = mat(x_1 (S,A); dots.v; x_n (S,A)) in RR^n$,  donde $x_1 (S,A):$ puede ser ppr ejemplo la posición de un catto si tomas la acción A.

Representamos el action-vlaue por la combinación líneal de las características: *$arrow(q) (S,A,w) = x(S, T)^T w = sum_(j=1)^n x_j (S,A) w_j$* que es exactamente lo mismo que hicimos para $arrow(v) (S,w)$, solo que ahora con (S,A)

El gradiente igual que antes es el vector de features 

$nabla_w arrow(q) (S, A, w) = x(S,A)$

$nabla w = alpha(q_pi (S,A) - arrow(q) (S,A,w))x(S,A)$

Ahora tomamos esa formula y como en predicción la adaptamos a MC, TD, y TD($lambda$), pero para q-funciones.

Para MC $nabla w = alpha(G_t - arrow(q) (S_t, A_t, w)) nabla_w arrow(q) (S_t, A_t, w)$

Para TD(O) $nabla w = alpha(R_(t+1) + gamma arrow(q) (S_(t+1), A_(t+1),
+) - arrow(q) (S_t, A_t, w)) nabla_w arrow(q) (S_t, A_t, w)$

Donde tenemos un error TD: $delta_t = "target"_t - arrow(q) (S_t, A_t, w) "y actualizamos "   nabla w = alpha delta_T x(S_t, A_t)$

Para TD($lambda$) $nabla w = alpha (q_t^lambda - arrow(q) (S_t, A_t, w)) nabla_w arrow(q) (S_t, A_t, w)$

Error TD $delta_t = R_(t+1) + gamma arrow(q) (S_(t+1), A_(t+1), w) - arrow(q) (S_t, A_t, w)$

Traza de elegibilidad
$E_t = gamma lambda E_(t-1) + nabla_w arrow(q) (S_t, A_t, w)$
Guarda en memoria borrosa de qué pares (S,A) han sudo visitados recientemente, $gamma lambda$ los va desvaneciendo con el tiempo.

$nabla w = alpha delta_t E_t$
Con esto hace paso a paso y en línea lo mismo que haría el fowaard view de TD($lambda$) con action-values..


 
