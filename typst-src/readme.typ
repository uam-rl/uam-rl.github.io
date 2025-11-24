= Replicación del paper DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning

== Objetivo general
Desarrollar y analizar un modelo de \~7B de parámetros que repliqeu, a escala reducida, el enfoque de *DeepSeek-R1* 

- Fine-tuning eficiente con *LoRA* sobre un modelo open-source (Qwen2.5-7B o Llama3-8B).
- Entrenamiento por refuerzo con *GRPO (Group Relative Policy Optimization)*.
- Uso de *verificadores (reward models / rule-based rewards)* para tareas de razonamiento (matemáticas, código, QA factual).
- Evaluación rigurosa en *benchmarks* y diseño de un *paper de alto nivel* con metodología sólida (ablaciones, análisis estadístico, ejemplos cualitativos).

=== Etapa 1 - Fundamentos teóricos
*Objetivos de la etapa*
- Que el equipo tenga una comprensión *formal* de:
  - Modelos de decisión de Markov (MDP).
  - Políticas y retornos.
  - Gradiente de política.
  - PPO y relación con GRPO.
  - LoRA como aproximación de baja-rango.
- Entender el diseño conceptual de DeepSeek-R1:
  - RL sin crítico.
  - Rewards por verificadores.
  - Separación `<think>` / `<answer>`.

*Recursos intentando documentar todo*
- *Curso de David Silver (UCL)*
  - Lecturas clave: Policy Gradient, Actor–Critic.
- Paper de *DeepSeek-R1* (arXiv).
- Documentación de:
  - *LoRA / PEFT*.
  - *TRL (Transformers Reinforcement Learning)*.

*Responsables:* ...


=== Eatapa 2 modelo 7B + LoRA SFT
*Objetivo*
Obtener una línea base fuerte y estbale antes de RL:
- Modelo 7B que:
  - use formato "\<think> ... <answer> ... <\answer>",
  - que razone de manera decente en mates/código simple.
  - no mezcle idiomas.

*Recursos*
- Seleccionar modelo base como Qwen2.5-7B-Instruct o Llama-3-8B-Instruct
- Construir dataset inicial de SFT:
  - problemas de matemáticas con solución y, si es posible, CoT generada por un modelo grande
  - problemas de código con solución y explicación breve
  - QA factual con razonamiento corto.
- Implementar scrip src/sft_lora.py:
  - Carga de modelo + tokenizador.
  - Apliar LoRA con PEFT.
  - Entrenamiento en dataset SFT en formato CoT.

*Responsables:* ...

- Checkpoint "baseline_7b_lora_sft/".
- Evaluación simple (pre-RL):
  - exactitud en un subconjunto de mates y código,
  - ejemplos cualitativos de razonamiento.

Esta etapa definirá la *línea base* de comparación en el paper.

=== Etapa 3, diseño e implementación de verificadores (Rewards)

*Onjetivo* definir formalmente las *funciones de recompensa* que guiarán el RL, inspiradas en DeepSeel-R1 pero adaptada a 7B.

*matemáticas* 
- math_boxed_answer_reward
  - compara respuesta final (extraída del \<answer>) con la solución correcta.
- math_steps_format_reward
  - Heurísticas para verificar que en \<think> hay pasos explícitos.

*Código:* 
- code_test_case_reward
  - Ejecuta el código generado en sandbox y evalúa proporción de casos de prueba pesados.

*Formato / idioma*
- format_think_answer_reward
  - Chequea preencia y orden correcto de \<think> y \<answer>
- languaje_consistency_reward
  - penaliza mezcla fuerte de idioma objetivo y otros.

*Helpfulness y safety (opcional siq ueremos)*
- helpfulness_llm_judge_reward
- safety_llm_judge_reward

*Responsables* ...

*Resultafos esperados:* 
- Módulo src/rewards/ con:
  - test unitarios básicos,
  - Documentación de cada verificador 
- Tabla en el futuro paper con la *definición matemática de cada recompensa*

=== Etapa 4 implementación de GRPO y bucle de RL
*Objetivo* implementar el buble de entrenamiento RL que:
- muestrea grupos de respuestas.
- aplica verificadores $->$ obtiene recompensas.
- calcila ventajas por grupo.
optimiza la política LoRa con loss GRPO

*cComponentes:*
- Script `src/grpo_loop.py` con:
  - Carga de `baseline_7b_lora_sft`.
  - Generación de G respuestas por prompt.
  - Cálculo de rewards y ventajas.
  - Cálculo de `grpo_loss` (PPO-like con KL).
- Estadísticas de entrenamiento:
  - reward medio,
  - longitud media del `<think>`,
  - porcentaje de problemas resueltos por batch.

  *Resonsables....*

  - Checkpoints intermedios `r1_7b_lora_stepXXXX/`.
- Curvas de:
  - reward promedio vs. pasos,
  - exactitud en validación vs. pasos,
  - longitud de `<think>` vs. pasos.
- Observación de posibles “momentos ahá” (cambios abruptos de comportamiento).

=== Etapa 5 rejection Sampling + SFT de refinamiento (opcional si queremos)

*Objetivo:* Pulir el modelo final usando *muestras de alta calidad* generadas durante RL.

*Pasos:*
- Elegir un checkpoint RL “bueno”.
- Generar N respuestas por prompt en un dataset de razonamiento.
- Quedarse sólo con:
  - respuestas correctas,
  - con razonamiento claro y formato limpio.
- Entrenar un SFT corto (`sft_refinement.py`) sobre estas muestras.

*Responsables* ...

- Modelo final `r1_7b_lora_final/`.
- Comparación cuantitativa:
  - baseline vs. RL vs. RL+SFT.
- Casos de estudio cualitativos con ejemplos de mejoras claras.

=== Etapa 6 — Evaluación rigurosa y análisis

*Objetivo:* Producir evidencia sólida para un *paper publicable*:
- Métricas cuantitativas.
- Ablaciones.
- Ejemplos cualitativos bien seleccionados.

*Métricas y tareas:*
- Exactitud en:
  - conjunto de mates,
  - conjunto de código,
  - QA factual.
- Calidad subjetiva:
  - evaluación humana o LLM-juez.
- Ablaciones sugeridas:
  - sin `language_consistency_reward`,
  - sin `format_think_answer_reward`,
  - tamaños de grupo distintos,
  - entrenamiento sólo SFT vs. SFT + RL.

*Responsables* ... 

*Resultados:*
- Carpeta `results/` con:
  - tablas `csv` o `json`,
  - gráficas listas para el paper (en `figures/`).
- Primer borrador de la sección “Experiments” del artículo.

=== Etapa 7 — Redacción del paper nivel doctorado

*Estructura propuesta del artículo*

1. *Introducción*
   - Motivación (razonamiento en LLMs).
   - Limitaciones de modelos grandes.
   - Contribución principal: pipeline R1-7B-LoRA.

2. *Background*
   - MDPs y policy gradient (David Silver).
   - GRPO como variante de PPO.
   - LoRA y modelos 7B.

3. *Método*
   - Descripción formal del pipeline:
     - SFT LoRA,
     - Verificadores,
     - GRPO,
     - Refinamiento SFT.
   - Definición matemática de todas las recompensas.

4. *Setup experimental*
   - Detalles del modelo base.
   - Datasets.
   - Hiperparámetros.

5. *Resultados*
   - Métricas cuantitativas.
   - Ablaciones.
   - “Aha moments” observados.

6. *Discusión*
   - Limitaciones.
   - Posibles extensiones (modelos más grandes, nuevos verificadores).

7. *Conclusión y trabajo futuro*
