using DifferentialEquations
function RPSOde!(du, u, par, t)
    nᵣ, nₚ, nₛ=u
    Pᵣ, Pₚ, Pₛ=par
    du[1]=nᵣ*(nₛ*Pᵣ- nₚ*Pₚ)
    du[2]=nₚ*(nᵣ*Pₚ- nₛ*Pₛ)
    du[3]=nₛ*(nₚ*Pₛ- nᵣ*Pᵣ)
end
