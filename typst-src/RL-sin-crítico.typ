== RL sin crítico /PPO

Piensa en RL estándar con gradiente de política:

$nabla_theta J(theta) approx EE[sum_t A_t nabla_theta log pi_theta (a_t | s_t)]$, el problema es de donde sale $A_t$.

La idea de actor-critico es 
- Actor: la política $pi_theta (a | s)$
- Crítico: una red que aproxima el valor $V_phi (s) approx EE[G_t | s_t = s]$,

$=>$ definimos la ventaja como: $A_t approx G_t - V_phi (s_t)$

Es decir el crítico $V_phi (s)$ dice que "tan bueno es este estado en promedio", la ventaja $A_t$ mide "que tan mejor/peor fue esta acción respecto al promedio del estado".

PPO es simplemente un método de gradiente de política con actor-crítico que controla que la política no cambie demasiado rápido.

La idea central sería:
- Tienes una política vieja $pi_(theta_"old")$ con la que recoges datos.
- Quieres actualizar a $pi_theta$ pero sin deformarla demasiado.

Con esto, definimos el ratio: $r_t (theta) = (pi_theta (a_t | s_t))/(pi_(theta_"old") (a_t | s_t))$.

El objetivo PPO es algo como esto:

$L^"CLIP" (theta) = EE_t ["min"(t_t (theta) A_t, "clip"(r_t(theta), 1 - epsilon, 1 + epsilon)arrow(A)_t)]$