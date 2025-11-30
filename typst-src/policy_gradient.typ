Recordemos que en RL tenemos un agente que toma las desiciones, un entorno con el que este interactua y en cada tiempo t el entorno está en un estado $S_t$ y el agente elige una acción $A_t$, el entorno responde con una recompensa $R_(t+1)$ y un nuevo estado $S_(t+1).$

*Una politica es la forma en que el agente decide qué acción tomar en cada estado:*
 
$pi(a|s) = PP[A_t = a | S_t = s]$, es decir, si estoy en s con que probabilidad elijo la acción a.

El objetivo es maximizar la recompensa total futura (el retorno)

$G_t = R_(t+1) + gamma R_(t+2) + gamma^2 R_(t+3) + ...$


== Policy Gradient

Anteriormente lo que haciamos era aproximar la función de valor (o la de acción valor) con un modelo paramétrico
$V_theta (s) approx V^pi (s)  "     y     "   Q_theta (s,a) approx Q^pi (s,a)$, 

En los métodos value-based aprnedes una funcion de valor $v(s) "    o   " q(s,a)$, la política nose aprende directamente si no que se deriva de estos valores, es implicita, sale como producto de $Q_theta$

primero definimos la regla que dice que acción tomar enc ada estado, $pi(a|s) = PP[a|s]$, definimosla funicón de desempeño $J(pi) = EE_pi [G_0 | S_0 = s_0]$, todo el problema de RL se puede resumir en encontrar una política que haga grande $J(pi)$.

Parametrizamos la política que sea algo que podamos representar con números. 

$pi_theta (a|s) = PP[a| s, theta]$, $=>$ $"   " J(theta) = J(pi_theta) = EE_(pi theta) [G_0 | S_0 = s_0]$, desempeño esperado de la plítica parametrizada por $theta$.

Políticas deterministas o estocástica? Si hacemos el ejercicio del piedra papel o tijera y obtuvieramos una politica determinista es decir simepre tijera o simepre papel, con recompensa de +1 si ganas, -1 si pierdes, 0 si empatas, sería muy explotable y tu rival detectaría el patrón haciendo que tu recompensa siempre fuese de -1, al ser estocástica puedes hacer 
$pi_theta (R) approx pi_theta (P) approx pi_theta (T) approx 1/3$, el objetivo de policy gradient ajusta $theta$ hasta que las probabilidades se acerquen a la mezcla óptima $1/3$ en cada una.