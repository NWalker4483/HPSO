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
zero_particle.alive = true;
zero_particle.Position = zeros(1,Dim);
zero_particle.Velocity = zeros(1,Dim);
zero_particle.Cost = inf;
zero_particle.Best.Position = zeros(1,Dim);
zero_particle.Best.Cost = inf;
pop1 = SpawnPopulation(zero_particle,Explosive_Radius,InitialSwarmSize,50);
pop1.C1 = C1;
pop1.C2 = C2;
pop1.W = W;
populationQ = [pop1];
%% Main Loop
% parpool('local',2);
for i=1:epochs
    % for each population in queue
    for e = 1:length(populationQ)
        % for particle in population 
        % if particle explodes remove it from population members
        % if population has zero members remove from queue
        if populationQ(e).alive 
            %Kill and skip iteration 
            active = false;
            for n = 1:length(populationQ(e).member)
                % Skip to next particle
                if populationQ(e).member(n).alive
                    active = true;
                    populationQ(e).member(n).Velocity = populationQ(e).W * populationQ(e).member(n).Velocity ...
                        + populationQ(e).C1*rand(1,Dim) .* (populationQ(e).member(n).Best.Position - populationQ(e).member(n).Position)...
                        + populationQ(e).C2*rand(1,Dim) .* (populationQ(e).Best.Position - populationQ(e).member(n).Position);

                    populationQ(e).member(n).Position = populationQ(e).member(n).Position + populationQ(e).member(n).Velocity;
                    populationQ(e).member(n).Cost = CostFunction(populationQ(e).member(n).Position);  

                    %populationQ(e).History(n).push(populationQ(e).member(n).Cost)
                    if rand > .7 %populationQ(e).History(n).hasConverged
                        if populationQ(e).InitialCost -  populationQ(e).member(n).Cost > MinimalImprovementThresh
                            popn = SpawnPopulation(populationQ(e).member(n),Explosive_Radius,Explosive_Fragments,50);
                            popn.C1 = C1;
                            % Increase Social Component Per Layer
                            popn.C2 = populationQ(e).C2 + 1;
                            popn.W = populationQ(e).W
                            %append(populationQ,popn);
                            populationQ = [populationQ,popn];
                        end
                        % Remove Particle
                        populationQ(e).member(n).alive = false; 
                    end
                    if populationQ(e).member(n).Cost < populationQ(e).member(n).Best.Cost    
                        populationQ(e).member(n).Best.Position = populationQ(e).member(n).Position;
                        populationQ(e).member(n).Best.Cost = populationQ(e).member(n).Cost;
                    end
                end
            end
            populationQ(e).W = populationQ(e).W * D;
            for n = 1:length(populationQ(e).member)
                if populationQ(e).member(n).alive
                    if populationQ(e).member(n).Best.Cost < populationQ(e).Best.Cost
                        populationQ(e).Best = populationQ(e).member(n).Best;
                    end
                end
            end
            populationQ(e).alive = active;
        end
   end  
end
%% Cleanup
%% delete(gcp('nocreate'))
