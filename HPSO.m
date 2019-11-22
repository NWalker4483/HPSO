%% Problem Statement
CostFunction = @(x) Magnitude(x);
Dim = 5; %% Matrix size of decision variable
%% Helper Struct
zero_particle.alive = true;
zero_particle.Position = zeros(1,Dim);
zero_particle.Velocity = zeros(1,Dim);
zero_particle.Cost = inf;
zero_particle.Best.Position = zeros(1,Dim);
zero_particle.Best.Cost = inf;
debug = 0; 
%% HPSO Parameters
epochs = 10;
InitialSwarmSize = 1; % Total Nodes in the Swarm
Search_Radius = 10;
Explosive_Radius = 5;
Explosive_Fragments = 10;
W = 1; %% Interia Coefficient
D = .99; %% Inertia Damping Rate
C1 = 1; %% Personal Coefficient
C2 = 0.1; %% Initial Social Coefficient
C3 = 3.4; %% Social Growth Rate
MinimalImprovementThresh = 0;
%% Initialization
pop1 = SpawnPopulation(zero_particle,Search_Radius,InitialSwarmSize,50);
pop1.C1 = C1;
pop1.C2 = C2;
populationQ = [pop1];
%% Main Loop
% parpool('local');
for i=1:epochs
    % for each population in queue
    for e = 1:length(populationQ)
        % for particle in population
        % if particle explodes remove it from population members
        % if population has zero members remove from queue
        if populationQ(e).alive
            % Revive only if population has a live member
            populationQ(e).alive = false;
            for n = 1:length(populationQ(e).member)
                % Skip to next particle
                if populationQ(e).member(n).alive
                    populationQ(e).alive = true;
                    populationQ(e).member(n).Velocity = W * populationQ(e).member(n).Velocity ...
                        + populationQ(e).C1*rand(1,Dim) .* (populationQ(e).member(n).Best.Position - populationQ(e).member(n).Position)...
                        + populationQ(e).C2*rand(1,Dim) .* (populationQ(e).Best.Position - populationQ(e).member(n).Position);
                    
                    populationQ(e).member(n).Position = populationQ(e).member(n).Position + populationQ(e).member(n).Velocity;
                    populationQ(e).member(n).Cost = CostFunction(populationQ(e).member(n).Position);
                    
                    if populationQ(e).member(n).Cost < populationQ(e).member(n).Best.Cost
                        populationQ(e).member(n).Best.Position = populationQ(e).member(n).Position;
                        populationQ(e).member(n).Best.Cost = populationQ(e).member(n).Cost;
                    end
                    
                    %populationQ(e).History(n).push(populationQ(e).member(n).Cost)
                    if rand > .1 %populationQ(e).History(n).hasConverged
                        if (populationQ(e).InitialCost - populationQ(e).member(n).Cost) > MinimalImprovementThresh
                            % popn = SpawnPopulation(populationQ(e).member(n),Explosive_Radius,Explosive_Fragments,50);
                            %% Debug Line
                            popn = SpawnPopulation(populationQ(e).member(n),Explosive_Radius,length(populationQ(e).member(n))+1,50);
                      
                            popn.C1 = C1;
                            % Increase Social Component Per Layer
                            popn.C2 = populationQ(e).C2 * C3;
                            %append(populationQ,popn);
                            debug = debug + 1;
                            populationQ = [populationQ;popn];
                        end
                        % Kill Particles that have exploded
                        populationQ(e).member(n).alive = false;
                    end
                end
            end
            for n = 1:length(populationQ(e).member)
                if populationQ(e).member(n).alive
                    if populationQ(e).member(n).Best.Cost < populationQ(e).Best.Cost
                        populationQ(e).Best = populationQ(e).member(n).Best;
                    end
                end
            end
        end
    end
    W = W * D;
end
%% Cleanup
% delete(gcp('nocreate'))
