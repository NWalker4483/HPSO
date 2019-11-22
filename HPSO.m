%% Problem Statement 
CostFunction = @(x) Magnitude(x);
%% HPSO Parameters
epochs = 1000;
InitialSwarmSize = 10; % Total Nodes in the Swarm 
Explosive_Radius = 5;
Explosive_Fragments = 10;
W = 1; %% Interia Coefficient 
D = .99; %% Inertia Damping Ratio
C1 = 1; %% Personal Coefficient 
C2 = 0.1; %% Social Coefficient
Dim = 5; %% Matrix size of decision variable 
MinimalImprovementThresh = 2 ;
%% Initialization 
zero_particle.Position = zeros(1,Dim);
zero_particle.Velocity = zeros(1,Dim);
zero_particle.Cost = inf;
zero_particle.Best.Position = zeros(1,Dim);
zero_particle.Best.Cost = inf;
pop1 = SpawnPopulation(zero_particle,Explosive_Radius,InitialSwarmSize);
pop1.C1 = C1;
pop1.C2 = C2;
populationQ = [pop1];
%% Main Loop
% parpool('local',2);
for i=1:epochs
    % for each population in queue
    for e = 1:length(populationQ)
        % for particle in population 
        % if particle explodes remove it from population members
        % if population has zero members remove from queue
        if length(populationQ(e).members) == 0 
            %Remove From Q and skip iteration 
        end
        
        for n = 1:length(populationQ(e).members) 
            populationQ(e).member(n).Velocity = populationQ(e).W * populationQ(e).member(n).Velocity ...
                + populationQ(e).C1*rand(1,Dim) .* (populationQ(e).member(n).Best.Position - populationQ(e).member(n).Position)...
                + populationQ(e).C2*rand(1,Dim) .* (populationQ(e).Best.Position - populationQ(e).member(n).Position);
            
            populationQ(e).member(n).Position = populationQ(e).member(n).Position + populationQ(e).member(n).Velocity;
            populationQ(e).member(n).Cost = CostFunction(populationQ(e).member(n).Position);  
            
            populationQ(e).History(n).push(populationQ(e).member(n).Cost)
            if populationQ(e).History(n).hasConverged
                if populationQ(e).InitialCost - populationQ(e).Best > MinimalImprovementThresh
                    popn = SpawnPopulation(Seed,S_radius,Explosive_Fragments,50);
                    popn.C1 = C1;
                    popn.C2 = popn.C2 + 1;
                    populationQ.push(popn)
                end
                populationQ(e).members.remove(populationQ(e).members(n))
                % Skip to next particle
            end
            if populationQ(e).member(n).Cost < populationQ(e).member(n).Best.Cost    
                populationQ(e).member(n).Best.Position = populationQ(e).member(n).Position;
                populationQ(e).member(n).Best.Cost = populationQ(e).member(n).Cost;
            end
        end
        populationQ(e).W = populationQ(e).W * D;
        for n = 1:length(populationQ(e).members)
            if populationQ(e).member(n).Best.Cost < populationQ(e).Best.Cost
                populationQ(e).Best = populationQ(e).member(n).Best;
            end
        end
    end
end
%% Cleanup
%% delete(gcp('nocreate'))
