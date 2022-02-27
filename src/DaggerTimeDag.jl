module DaggerTimeDag

using Dagger
import TimeDag
import TimeDag: Node
import Dates: DateTime

function evaluate_internal(node::Node, time_start::DateTime, time_end::DateTime, args...)
    new_node = TimeDag.obtain_node(node.parents, node.op)
    state = TimeDag.start_at([node], time_start)
    TimeDag.evaluate_until!(state, time_end)
    return vcat(state.evaluated_node_to_blocks[node]...)
end
function evaluate(node::Node, time_start::DateTime, time_end::DateTime)
    to_transform = Node[node]
    node_to_task = IdDict{Node,Dagger.EagerThunk}()

    # Populate visit list
    while !isempty(to_transform)
        cur = popfirst!(to_transform)
        haskey(node_to_task, cur) && continue
        parent_tasks = Union{Node,Dagger.EagerThunk}[]
        for p in cur.parents
            push!(parent_tasks, get(node_to_task, p, p))
        end
        if !any(p->p isa Node, parent_tasks)
            # Ready to execute self
            task = Dagger.@spawn evaluate_internal(cur, time_start, time_end, parent_tasks...)
            node_to_task[cur] = task
        else
            # Need to revisit later
            # Push unprocessed parents first
            for p in filter(p->p isa Node, parent_tasks)
                push!(to_transform, p)
            end
            # Push self last
            push!(to_transform, cur)
        end
    end

    return node_to_task[node]
end

end # module
