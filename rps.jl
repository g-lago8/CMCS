using Statistics


" rock- paper-scissor population dynamics with global interactions"
# rps with global interactions
function RPS(N, epochs, P, initial)

    pop=zeros(Int,epochs, 3)
    env=zeros(Int, N)
    # initialization of the population.
    #1=rock, 2=paper, 3=scissor
    for i=1:N
        x=rand()
        if x<initial[1]
            env[i]=1; pop[1,1]+=1
        elseif x<initial[1]+initial[2]
            env[i]=2; pop[1,2]+=1
        else
            env[i]=3; pop[1,3]+=1
        end
    end
    # evolution of the population
    if epochs==1
        return env, pop
    end
    for epoch=1:epochs-1
        pop[epoch+1, :]=pop[epoch,:]
        for k=1:N
            i = rand(1:N)
            j = rand(1:N)
            p1 = env[i]
            p2 = env[j]
            
            if p1==p2+1 || p1==p2-2 # p1 wins
                r=rand()
                if r<P[p1]
                    env[j]=p1
                    pop[epoch+1,p1]+=1
                    pop[epoch+1, p2]-=1
                end

            elseif p1==p2-1 || p1==p2+2 # p2 wins
                r=rand()
                if r<P[p2]
                    env[i]=p2
                    pop[epoch+1,p2]+=1
                    pop[epoch+1, p1]-=1
                end
            end  
        end 
    end
    return env, pop
end

"rock- paper-scissor population dynamics with global interactions"
function RPSLattice(n, epochs, P, initial; interaction_range=1, mutation=[0, 0, 0], mutation_patience=0, mutation_type="none")
    env=zeros(Int, n,n)
    
    pop=zeros(Int,epochs, 3)

    aggressivity=zeros( n, n)

    for i = 1:n, j=1:n  # initialization of the population. 
                        # 1=paper, 2=rock, 3=scissor
        x=rand()
        if x<initial[1]
            env[i,j]=1; pop[1,1]+=1
            aggressivity[i,j]=P[1]
        elseif x<initial[1]+initial[2]
            env[i,j]=2; pop[1,2]+=1
            aggressivity[i,j]=P[2]
        else
            env[i,j]=3; pop[1,3]+=1
            aggressivity[i,j]=P[3]
        end
    end
    mean_aggr=[]
  
    # evolution of the population with short-range interactions
    if epochs==1
        return env, pop
    end 
    for epoch=1:epochs-1
        pop[epoch+1, :]=pop[epoch,:]
        for k=1:n*n
            i=rand(1:n)
            j=rand(1:n)
            # select a pair of indexes next to (i,j)
            # modify the code to make it periodic
            Δi=rand(range(-interaction_range, interaction_range))
            Δj=rand(range(-interaction_range, interaction_range))
            
            i2=i+Δi
            j2=j+Δj
            # periodic boundary conditions
            if i2<1; i2=n
            elseif i2>n; i2=1
            end

            if j2<1; j2=n   
            elseif j2>n; j2=1
            end 

            p1 = env[i, j]
            p2=env[i2,j2]
            if p1==p2+1 || p1==p2-2 # p1 wins
                r=rand()
                if r<aggressivity[i,j]
                    env[i2,j2]=p1
                    aggressivity[i2,j2]=aggressivity[i,j]
                    # mutation of aggressivity
                    if mutation_type=="random"
                        aggressivity[i2,j2]=min(1, aggressivity[i2,j2]+ mutation[p1]*randn()*(epoch>= mutation_patience))
                    elseif mutation_type=="disease"
                        aggressivity[i2,j2]=max(0.1, aggressivity[i2,j2]- mutation[p1]*rand()*(epoch>= mutation_patience))
                    end
                    pop[epoch+1,p1]+=1
                    pop[epoch+1, p2]-=1
                end
            end
            if p1==p2-1 || p1==p2+2 # p2 wins
                r=rand()
                if r<aggressivity[i2, j2]
                    env[i,j]=p2
                    aggressivity[i,j]=aggressivity[i2,j2]
                    # mutation of aggressivity
                    if mutation_type=="random"
                        aggressivity[i,j]=min(1, aggressivity[i,j]+ mutation[p2]*randn()*(epoch>= mutation_patience))
                    elseif mutation_type=="disease"
                        aggressivity[i,j]=max(0.1, aggressivity[i,j]- mutation[p2]*rand()*(epoch>= mutation_patience))
                    end
                    
                    pop[epoch+1,p2]+=1
                    pop[epoch+1, p1]-=1
                end
            end
        end
        append!(mean_aggr, mean(aggressivity[env.==1]))
    end
    return env, pop, aggressivity, mean_aggr
end



