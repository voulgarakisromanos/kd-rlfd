using Robosuite
using CircularArrayBuffers
using BSON
using Flux
include("../utilities/hooks.jl")
include("../utilities/utils.jl")

image_size = 64
env = RoboticEnv(name="Lift", T=Float32, controller="OSC_POSE", enable_visual=true, show=false, horizon=200, image_size=image_size)

BSON.@load "agents/groundtruth/Lift" agent

stop_condition = StopAfterStep(10, is_show_progress=!haskey(ENV, "CI"));

hook = EfficientFramesHook(CircularArraySARTTrajectory(
    capacity = 30000,
    state = Vector{Float32} => (image_size,image_size,),
    action = Vector{Float32} => (7,)
))

actor_critic_agent = ActorCriticPolicy{false}(agent[:actor], agent[:critic]);

run(actor_critic_agent, env, stop_condition, hook)

# BSON.@save "datasets/lift_demo.bson" hook

hook = efficient_to_stacked(hook, frame_size=3)