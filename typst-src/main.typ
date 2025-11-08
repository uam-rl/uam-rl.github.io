// Hybrid CSS-in-Typst + External CSS approach
#let theme = (
  colors: (
    primary: rgb("#667eea"),
    secondary: rgb("#764ba2"),
    text: rgb("#1d1d1d"),
  )
)

// Import chapter configuration, sidebar, centralized CSS, and math fix
#import "chapters.typ": sidebar, inject-all-css, fix-math, chapter-nav

// Apply centralized math equation handling
#show math.equation: fix-math

// Apply CSS injection using html.elem
#inject-all-css()

// Set font for both PDF and HTML
#set text(font: "New Computer Modern", size: 11pt)

#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 2.25em, weight: 700, fill: theme.colors.primary)
#show heading.where(level: 2): set text(size: 1.5em, weight: 600, fill: theme.colors.primary)

// Render sidebar, no need for HTML conditional
#sidebar


= UAM RL

Welcome to the UAM Reinforcement Learning Organization.

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

#chapter-nav("main.typ")

