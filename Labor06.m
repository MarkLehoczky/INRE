tic
GA_TARGET = 'Cheese factory'
GA_POP_SIZE=1000000;    %populáció méret
GA_MAX_ITER=1000;    %max iteráció
GA_ELITE_RATE=0.01;    %örökléshez használt elitráta
GA_MUTATION_RATE=0.2;   %mutációs ráta (gén=karater)

Generation=0;
%kezdeti értékek feltöltése, ASCII:
Population=randi([32 122], GA_POP_SIZE, length(GA_TARGET));
%kezdeti értékek feltöltése, Extended ASCII:
Population=randi([0, 255], GA_POP_SIZE, length(GA_TARGET));


%amíg el nem érjük a max iterációt:
while Generation<GA_MAX_ITER
    %jóság számítás = célértéktől való eltérés
    Difference=abs(Population-GA_TARGET); 
    Fitness=sum(Difference'); Generation=Generation+1;
    %fitness szerinti sorbarendezés:
    [Fitness, index]=sort(Fitness);
    Population=Population(index,:);
    %legjobb egyed kiírása:
    disp(sprintf('%d. generáció legjobb jósága: %d, %s', Generation, Fitness(1), char(Population(1,:))));
    if Fitness(1)==0
        break; %ha megtaláltuk, kilépünk
    end
    
    %öröklésben résztvevő elitek
    EliteSelection=Population(1:floor(GA_ELITE_RATE * GA_POP_SIZE),:);

    %véletlen keresztezés:
    for i=1:GA_POP_SIZE
        Parent1=randi([1 floor(GA_ELITE_RATE * GA_POP_SIZE)]); %egyik szülő 
        Parent2=randi([1 floor(GA_ELITE_RATE * GA_POP_SIZE)]);  %másik szülő
        CrossoverPoint=randi([0 1],1,length(GA_TARGET)); %véletlen gének
        Population(i,:)=EliteSelection(Parent1,:).*CrossoverPoint+EliteSelection(Parent2,:).*(1-CrossoverPoint);            
    end

    %mutáció, csak véletlen 1-1 gén mutálódik a teljes populáción belül
    for i=1:length(Population(:))*GA_MUTATION_RATE                      
       Population(randi(randi([1 GA_POP_SIZE]), [1 length(GA_TARGET)]))= randi(255);       
    end


end %while vége
toc
