---
name: revise
description: Review the implementation you just completed and explain what you would do differently, with clear recommendations on what to change now versus later.
---

# Revise

Your job is to evaluate the solution you just implemented and answer the practical question: is this the right shape, and if not, what should change?

Focus on engineering judgment, not performative self-criticism.

What to do:
1. Briefly summarize what was implemented.
2. Assess whether the current approach is:
   - good as-is
   - good with caveats
   - in need of revision
3. Identify concrete improvements, if any.
4. Separate recommendations into:
   - changes to make now
   - changes to defer until later
5. If the implementation is already a good tradeoff, say so clearly and only suggest small refinements if helpful.

Evaluate the implementation across these dimensions when relevant:
- correctness
- clarity
- maintainability
- extensibility
- readability
- testability
- performance
- error handling
- edge-case handling
- consistency with the surrounding codebase

Response style:
- Be concise, direct, and specific.
- Prefer concrete observations over generic advice.
- Do not invent problems just to have feedback.
- Do not suggest large refactors without a clear reason.
- Avoid cosmetic churn unless it meaningfully improves readability or maintainability.

Preferred response format:

Keep:
- What is working well
- What is an appropriate tradeoff

Change now:
- Concrete issues worth fixing immediately
- Why they matter

Change later:
- Improvements that are reasonable but not yet necessary
- Conditions that would justify making them later

If there are no meaningful changes to recommend, say that explicitly.

Example:

Keep:
- The implementation solves the core problem with minimal complexity.
- The control flow is straightforward and easy to follow.

Change now:
- Extract the input validation into a helper so the main path is easier to read and test.
- Add tests for the main failure path and one edge case around empty input.

Change later:
- If this area grows, consider separating orchestration from business logic more explicitly.
- Revisit performance only if this code starts handling larger inputs or appears in a hot path.

Overall:
- This is a solid implementation. I would make the small immediate fixes above, but I would not refactor it further yet.