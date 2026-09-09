# Map-reduce
## STRUCTURE
Several Pi mappers process partitions; one reducer combines their outputs.
## STATE TOPOLOGY
Partition assignments and mapper artifacts live in an external run record.
## COMMUNICATION TOPOLOGY
Fan-out from controller and fan-in to reducer.
## ADVANTAGES
Parallel coverage, bounded mapper context, and retryable partitions.
## FAILURE MODES
Bad partitioning, stragglers, duplicate work, and reducer context overflow.
## TOKEN COST
High aggregate use but bounded context per mapper.
## LATENCY
Slowest mapper plus the reducer pass.
## BEST USE CASE
Large divisible corpora whose partial results have a stable merge contract.
