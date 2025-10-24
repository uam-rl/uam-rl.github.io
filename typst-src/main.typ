// Hybrid CSS-in-Typst + External CSS approach
#let theme = (
  colors: (
    primary: rgb("#667eea"),
    secondary: rgb("#764ba2"),
    text: rgb("#1d1d1d"),
  )
)

// CSS injection using html.elem (cleaner approach)
#let inject-css() = context {
  if sys.inputs.at("target", default: "pdf") == "html" {
    html.elem("style",
      "h1, h2, h3 { color: #667eea; font-weight: 700; } svg { margin: 1.5em auto; display: block; border-radius: 8px; } body { max-width: 65ch; margin: 0 auto; padding: 2rem; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif; } span svg { margin: 0; display: inline-block; vertical-align: middle; } a { color: #667eea; text-decoration: none; } a:hover { color: #764ba2; }"
    )
  }
}

// Automatic math equation handling with show rule
#show math.equation: it => context {
  if sys.inputs.at("target", default: "pdf") == "html" {
    // Use uncommon near-black color for HTML SVG generation
    // #0a0a0a is visually identical to black but uncommon enough for post-processing
    set text(fill: rgb("#0a0a0a"))
    if it.block {
      html.frame(it)           // Block: standalone SVG
    } else {
      box(html.frame(it))      // Inline: wrapped SVG
    }
  } else {
    it                         // PDF: native math (uses default color)
  }
}

// Apply CSS injection using html.elem
#inject-css()
#set text(size: 11pt)
#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 2.25em, weight: 700, fill: theme.colors.primary)
#show heading.where(level: 2): set text(size: 1.5em, weight: 600, fill: theme.colors.primary)

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

