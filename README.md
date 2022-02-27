# DaggerTimeDag

Integration between Dagger.jl and TimeDag.jl

## Usage

DaggerTimeDag works similarly to TimeDag; you construct a `TimeDag.Node` as
usual, pick `time_start` and `time_end`, and call
`DaggerTimeDag.evaluate(node, time_start, time_end)`. Unlike `TimeDag.evaluate`,
`DaggerTimeDag.evaluate` returns a `Dagger.EagerThunk`, so `fetch` needs to be
called on the result to fetch the results.

Here is an example of basic usage, copied from the TimeDag README:

```julia
using DaggerTimeDag, TimeDag, Dates

x = rand(pulse(Hour(2)))
y = rand(pulse(Hour(3)))
z = cov(x, lag(y, 2))

time_start = now()
time_end = now() + Hour(24)

e1 = evaluate(z, time_start, time_end)
e2 = fetch(DaggerTimeDag.evaluate(z, time_start, time_end))
@assert e1 == e2
```
