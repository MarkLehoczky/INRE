
prompt = 'Clear ruleTable? [Y/N]';
str = input(prompt,'s');
if(upper(str)=='N')
    clearvars -except ruleTable
    disp(ruleTable)
else
    clear all;
    disp('ruleTable empty')
end
close all;

%% Basemaps
%map=imread('32b.png');
%map=imread('32c.png');
map=imread('32d.png');
%map=imread('32.png');
%map=imread('64x.png');
%map=imread('256.png');

%% "defines"
%cell values
emptyVal=0;
finishVal=-1;
robotVal=-2;
pathVal=-2.5;
obstacleVal=-3;

%rule table size (movement and direction possibilities - min: 4x4)
directions=4;
movements=4;

%directions (where is the finish cell)
dirRight=1;
dirLeft=2;
dirUp=3;
dirDown=4;

%movements (where to move)
moveRight=1;
moveLeft=2;
moveUp=3;
moveDown=4;

if exist('ruleTable')==0  
    ruleTable=eye(directions,movements);
end

%% get start and finish positions
%find R
startPos=[-1,-1]; %invalid
for i=1:size(map,1)
    for j=1:size(map,2)
        if reshape(map(i,j,:),[1 3])==[255,0,0] %red
            startPos=[i,j];
        end
    end
end

%find F
finishPos=[-1,-1]; %invalid
for i=1:size(map,1)
    for j=1:size(map,2)
        if reshape(map(i,j,:),[1 3])==[0,255,0] %green
            finishPos=[i,j];
        end
    end
end

disp(['start coords: ', num2str(startPos)]);
disp(['finish coords: ', num2str(finishPos)]); 

%% Replace start, finish, obstacle cell values
map=rgb2gray(map);
map=1-im2double(map);
map(finishPos(1), finishPos(2))=finishVal; %finish
map(startPos(1), startPos(2))=robotVal; %start
for i=1:size(map,1)
    for j=1:size(map,2)
        if map(i,j)==1
            map(i,j)=obstacleVal; %obstacle
        end
    end
end

%% let's learn!
robotPos=startPos;
pastStart=0;

while(norm(robotPos)~=norm(finishPos))
   
    newPos=robotPos;
    directionIndex=-1;

    % 1. feladat
    if (abs(robotPos(1) - finishPos(1)) > abs(robotPos(2) - finishPos(2)))
        if (robotPos(1) > finishPos(1))
            directionIndex = dirUp;
        else
            directionIndex = dirDown;
        end
    else
        if (robotPos(2) > finishPos(2))
            directionIndex = dirLeft;
        else
            directionIndex = dirRight;
        end
    end
    
    % 2. feladat
    [maxRuleVal, movementIndex] = max(ruleTable(directionIndex, :));

    % 3. feladat
    switch(movementIndex)
        case moveUp
            newPos(1) = newPos(1) - 1;
        case moveDown
            newPos(1) = newPos(1) + 1;
        case moveLeft
            newPos(2) = newPos(2) - 1;
        case moveRight
            newPos(2) = newPos(2) + 1;
    end

    % 4. feladat
    oldDistance = norm(robotPos-finishPos);
    newDistance = norm(newPos-finishPos);

    if (oldDistance > newDistance)
        ruleTable(directionIndex, movementIndex) = maxRuleVal + 1;
    else
        ruleTable(directionIndex, movementIndex) = maxRuleVal - 3;
    end
    
    %display movement
    
    if (map(newPos(1),newPos(2))==emptyVal) || (map(newPos(1),newPos(2))==finishVal) || (map(newPos(1),newPos(2))==pathVal)
        map(robotPos(1),robotPos(2))=pathVal;
        prevPos=robotPos;
        robotPos=newPos;
        map(robotPos(1),robotPos(2))=robotVal;
    else
        map(robotPos(1),robotPos(2))=pathVal;
        [robotPos,prevPos]=deal(prevPos,robotPos);
        map(robotPos(1),robotPos(2))=robotVal;
    end

    switch(directionIndex)
        case dirUp
            disp("dirUp")
        case dirDown
            disp("dirDown")
        case dirLeft
            disp("dirLeft")
        case dirRight
            disp("dirRight")
    end

    switch(movementIndex)
        case moveUp
            disp("moveUp")
        case moveDown
            disp("moveDown")
        case moveLeft
            disp("moveLeft")
        case moveRight
            disp("moveRight")
    end

    disp("oldDistance: " + oldDistance);
    disp("newDistance: " + newDistance);
    disp(ruleTable);
    imagesc(map);
    colormap(jet);
    pause(0.05);

 end

 %% Retry    
prompt = 'Retry? [Y/N]';
str = input(prompt,'s');
if(upper(str)=='Y')
    selflearn_student
end
