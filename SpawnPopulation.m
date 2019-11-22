function population = SpawnPopulation(Seed,S_radius,Size,Hist_Size)
Dim = 5;
population.Best = Seed;
population.member = repmat(Seed,Size,1); 
population.member(1) = Seed;
population.InitialCost = Seed.Cost;
population.alive = true;
population.History = repmat(inf(1,Hist_Size),Size,1);
for i=2:Size
    population.member(i).Position = population.member(i).Position + unifrnd(-S_radius,S_radius,1,Dim);
    population.member(i).Velocity = zeros(1,Dim); 
    %population.member(i).Cost = CostFunction(population.member(i).Position);
    %population.History(i).push(population.member(i).Cost);
    %population.member(i).Best.Position = population.member(i).Position;
    %population.member(i).Best.Cost = population.member(i).Cost;
    %if population.member(i).Best.Cost < population.Best.Cost
    %    population.Best = population.member(i).Best;
    %end
end
end
