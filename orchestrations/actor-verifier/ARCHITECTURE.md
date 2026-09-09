# Actor-verifier
## STRUCTURE
An actor creates the result; a fresh read-only verifier judges evidence.
## STATE TOPOLOGY
The artifact and structured claim sit between isolated sessions.
## COMMUNICATION TOPOLOGY
Actor output flows to verifier; verifier returns pass, fail, or findings.
## ADVANTAGES
Independent inspection reduces self-approval and unsupported completion.
## FAILURE MODES
Correlated model errors, shallow checks, ambiguous criteria, and unverifiable work.
## TOKEN COST
Roughly actor plus verifier contexts.
## LATENCY
Two sequential workers unless verification components can parallelize.
## BEST USE CASE
Tasks with concrete artifacts and machine-observable acceptance criteria.
