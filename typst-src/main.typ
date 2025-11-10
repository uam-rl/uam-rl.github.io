#import "template.typ" as tp
#show: tp.cool-web-page.with(
  current-file: "main.typ",
)


= UAM RL

Welcome to the UAM Reinforcement Learning Organization.

View the source code for this page on github:
#box(image("github.svg", width: 1em), baseline: 0.1em)
#link("https://github.com/uam-rl/uam-rl.github.io")[github.com/uam-rl/uam-rl.github.io]

== About

This organization is dedicated to reinforcement learning research, implementations, and educational resources.

== Research Areas

Our research focuses on:

- *Deep Reinforcement Learning*: Applying deep neural networks to RL problems
- *Policy Optimization*: Developing efficient policy gradient methods
- *Multi-Agent RL*: Studying interactions between multiple learning agents
- *Sample Efficiency*: Improving data efficiency in RL algorithms

== Mathematical Foundations

The core of reinforcement learning revolves around the Bellman equation:

$ V(s) = max_a sum_(s') P(s' | s, a) [R(s, a, s') + gamma V(s')] $

Where:
- $V(s)$ is the value function
- $gamma$ is the discount factor
- $R(s, a, s')$ is the reward function

The expected return for a policy $pi$ can be written as:

$ J(pi) = EE_(tau tilde pi) [sum_(t=0)^infinity gamma^t r_t] $

== Get Involved

Visit our GitHub organization at https://github.com/uam-rl to explore our projects and contribute to our research.
