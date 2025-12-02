== RL sin crítico

Piensa en RL estándar con gradiente de política:

$nabla_theta J(theta) approx EE[sum_t A_t nabla_theta log pi_theta (a_t | s_t)]$, el problema es de donde sale $A_t$.

La idea de actor-critico es 
- Actor: la política $pi_theta (a | s)$
- Crítico: una red que aproxima el valor $V_phi (s) approx EE[G_t | s_t = s]$,

$=>$ definimos la ventaja como: $A_t approx G_t - V_phi (s_t)$

Es decir el crítico $V_phi (s)$ dice que "tan bueno es este estado en promedio", la ventaja $A_t$ mide "que tan mejor/peor fue esta acción respecto al promedio del estado".