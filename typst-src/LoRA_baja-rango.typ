#import "template.typ" as tp
#show: tp.cool-web-page.with(
  current-file: "LoRa_baja-rango.typ",
)


== LoRA como aproximación de baja-rango.

Imaginemos el modelo más simple, entra un vector x y sale un vector y, la regla es: *$y = W\x$*, donde la información de entrada estpa en x, y la forma en que el modelo procesa toda la información está en la matriz W (pesos del modelo). 

En cualquier aprendizaje hay siempre la misma idea, mides que tamn bien hace las cosas el modelo, $->$ pérdida o reward, cambias un poco los números de W para que la próxima vez lo haga mejor.

Entrenar es ajustar la tabla de números W muchas veces. En un LLM un solo W puede tener millones de entradas $->$ es muy caro cambiar todas.

El truco es en lugar de cambiar W directamente, dejamos fijo $W_0$ (los pesos originales pre-entrenados) y sólo se aprnederá una correción $Delta W$.

$W_"nuevo" = W_0 + Delta W$

En el forward:

$y = W_"nuevo" x = (W_0 + Delta W)x = X_0 x + Delta W x$

Comenzando con LoRA, esto nos dice que se impondrá una correción $Delta W$ tenga una forma muy simple: $Delta W = A B$, donde A,B son matrices mucho más pequeñas.

Supongamos que $W_0 in RR^(d_"out" times d_"in" )  => Delta W "debe tener el mismo tamaño:" Delta W in RR^(d_"out" times d_"in") $

LoRA escribe $Delta W  =A B "  con  "  A in RR^(d_"out" times r), " " B in RR^(r times d_"in")$, donde $r$ es un número pequeño.

Supongamos que tenemos una capa de un LLM con $d_"in" = 4096, " " d_"out" = 4096 => W_0 in  RR^(4096 times 4096)$, lo que serían 4096*4096 = 16,777,216 números, si hicieramos fine-tuning normal entrenaríamos muchos millones de parámetros por capa, con LoRA eliges por ejemplo:

 $r = 16 => "  " A in RR^(4096 times 16) " " -> 65536 "parámetros", " " B in RR^(16 times 4096) " " -> "otros " 65,536 $

 Total: $131,072 $ parámetros. Note que es más de 100 veces menor, y puedes seguir haciendo cambios útiles, pero de una forma muy "controlada".

 Con esto tenemos una breve introducción sobre la idea de qué es LoRA.

 == Bajo rango:

Cualquier matriz que se escriba como $A\B$ con $A in RR^(d_"out" times r) "y " B in RR^(r times d_"in")$ no puede ser totalmente "arbitraria", está limitada.

Esto se mide con el concepto de rango: básicamente cuánta "complejidad lineal" tiene la matriz. Cuando usas $r$ pequeño, obligas a que la correción $Delta W$ tenga poca complejidad lineal: por eso se llama actualización de rango bajo.

$=>$ la correción $Delta W$ no puede ser cualquier cosa: solo matrices que se puedan escribir como $A B$ con r pequeño. Esto reduce el número de parámetros y "simplifica" la clase de funciones que puedes aprender.

En RL tienes una política $pi_theta (a | s)$, pero dentro $pi_theta$ es un modelo con muchas matrices $W^1, W^2, ... $, cuando haces PPO, GRPO, etc, el algoritmo  te dice cómo cambiar los parámetros para mejorar el reward. 

Con LoRA lo único que cambia es que en lugar de cambiar $W_0$ directamente, dices "mi política tiene matrices $" " W_"eff" = W_0 + A B$, en algunas capas", y el RL solo aprende A y B, osea LoRa es una forma específica de parametrizar la política para que entrenes pocos parámetros (los A, B) en lugar de todo W. 

Ejemplo: sea $Delta W = A B$ tamaño 2 x 3.

Y los pesos efectivos: $W_"eff" = W_0 + Delta W$

$=> " " W_0 in RR^(2 times 3)$

$=> " " A in RR^(2 times 1), B in RR^(1 times 3)$

$=> " " Delta W = A B in M_(2 times 3)$ Esta es la correción que LoRA lo agrega $W_0$

$=> " " W_"eff" = W_0 + Delta W $, donde $W_0$ era lo que el modelo sabía, LoRA aprendió A, B, que generan $Delta W$, y la capa que realmente se usa en inferencia es $W_"eff"$

Tomemos un vector de entrada $x in M_(3 times 1)$

La salida del modelo original sin LoRA $y_0 = W_0 x, "  " y_0 in M_(2 times 1)$, con LoRApodemos verlo:

1. Usando directamente $W_"eff"$ $" " =>  y_"eff" = W_"eff" x, => " " y_"eff" in M_(2 times 1)$

2. Separando modelo base + correción LoRA, usando la identidad: $y"eff" = W_0 x + Delta W x$, donde $y_"eff" in M_(2 times 3)$, que es exactamente lo que se obtuvo en 1.

3. La factorización real de LoRA, $Delta W x = A(B x)$, recuerda que $B in M_(1 times 3) " " => B x in M_(1 times 1) "  " A (B x) in M_(2 times 1)$, que es exactamente $Delta W x.$ 

Entonces, primero se va de dimensión 3 a 1 con B (proyección), depsues de dimension 1 a 2 con A (re-expansión). Eso es lo que significa "bajo rango", toda la corrección vive en un subespacio 1-dimensional en el medio.

La conexión con el RL, supongamos que tenemos un estado $s$, los pasos para un embedding o algo y obtienes un vector $x(s) in RR^3$, tambien una capa final con pesos $W_"eff" in RR^(2 times 3)$, que produce logits: $z(s) = W_"eff"x (s)$, de eso logits sacas una política sobre dos acciones con softmax:   \  $pi_phi.alt (a = 1| s) = exp(z_1)/ (exp(z_1) + exp(z_2)), "  " pi_phi.alt (a = 2| s) = exp(z_2)/ (exp(z_1) + exp(z_2))$, donde $phi.alt = (A, B) $, son los árámetros LoRA y $W_0$ está fijo.

En RL el algoritmo (PPO, GRPO, ...) te dice cómo actualizar $phi.alt$ para mejorar el retorno, pero la matemática no cambia, sigue haciendo $W_"eff" = W_0 + A B y z = W_"eff" x (s)$, lo único que cambia es de donde viene el gradiente (de la pérdida de RL en vez de una pérdida supervizada.)