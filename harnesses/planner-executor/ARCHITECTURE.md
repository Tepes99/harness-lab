# Planner-executor harness

**Composition:** a plan-mode Pi session followed by a fresh coding Pi session that receives the accepted plan.

The planner has inspection tools and cannot mutate. The executor gets bounded mutation tools and completion criteria. A controller owns the handoff, so a plan cannot silently become an action in the same phase.
