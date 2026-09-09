# Generator-critic
## STRUCTURE
A generator proposes a candidate and a critic returns bounded revision feedback.
## STATE TOPOLOGY
The controller owns candidate versions, feedback, and the round limit.
## COMMUNICATION TOPOLOGY
A feedback cycle connects generator and critic through the controller.
## ADVANTAGES
Explicit iteration can improve subjective or underspecified artifacts.
## FAILURE MODES
Unbounded loops, oscillation, agreeable critics, and regression between versions.
## TOKEN COST
Grows with every feedback round and repeated candidate context.
## LATENCY
Sequential generator/critic rounds dominate.
## BEST USE CASE
Drafts where critique quality can be judged and iteration is capped.
