%% Problem Statement 
CostFunction = @(x) Magnitude(x);
Dim = 5; %% Matrix size of decision variable 
SearchMin = -10; 
SearchMax = 10; 
%% PSO Parameters
epochs = 1000;
InitialSwarmSize = 15; % Total Nodes in the Swarm 
W = 1; %% Interia Coefficient 
D = .99; %% Inertia Damping Ratio
C1 = 2; %% Personal Coefficient 
C2 = 2; %% Global Coefficient

GlobalBest.Cost = inf;
%% Initialization 
empty_particle.Position = [];
empty_particle.Velocity = [];
empty_particle.Cost = [];
empty_particle.Best.Position = [];
empty_particle.Best.Cost = [];
particle = repmat(empty_particle,InitialSwarmSize,1); 

for i=1:InitialSwarmSize
    particle(i).Position = unifrnd(SearchMin,SearchMax,1,Dim);
    particle(i).Velocity = zeros(1,Dim); 
    particle(i).Cost = CostFunction(particle(i).Position);
    particle(i).Best.Position = particle(i).Position;
    particle(i).Best.Cost = particle(i).Cost;
    if particle(i).Best.Cost < GlobalBest.Cost
        GlobalBest = particle(i).Best;
    end
end
%% Main Loop
%% parpool('local',2);
for i=1:epochs
    for n = 1:InitialSwarmSize 
        particle(n).Velocity = W * particle(n).Velocity ...
            + C1*rand(1,Dim) .* (particle(n).Best.Position - particle(n).Position)...
            + C2*rand(1,Dim) .* (GlobalBest.Position - particle(n).Position);
        
        particle(n).Position = particle(n).Position + particle(n).Velocity;
        particle(n).Cost = CostFunction(particle(n).Position);  
        if particle(n).Cost < particle(n).Best.Cost    
            particle(n).Best.Position = particle(n).Position;
            particle(n).Best.Cost = particle(n).Cost;
        end
    end
    W = W * D;
    for n = 1:InitialSwarmSize
        if particle(n).Best.Cost < GlobalBest.Cost
            GlobalBest = particle(n).Best;
        end
    end
end
%% Cleanup
%% delete(gcp('nocreate'))
