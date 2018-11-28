function [cost]=fehCopiesCost(copies,unitColor,unitStarPool,legendary)
%fehCopiesCost(copies,unitColor,unitStarPool,legendary)
%      READ ME PLEASE.
%      Computes a cumulative density function that tells the frequent orb
%      cost of pulling multiple copies of an unit.
%
%      copies: how many copies you want;
%      unitColor: the color of the unit you want:
%                   'r'-red;
%                   'b'-blue;
%                   'g'-green;
%                   'c'-colorless.
%      unitStarPool: The pools that the target unit belongs to:
%                   ex.: [1 0 0 1] represents a unit that is in the focus
%                   pool and in the 3* pool;
%                   ex.: [0 1 1 0] represents a unit that is in the 5* pool
%                   and in the 4* pool.
%       legendary:  optional flag variable. Makes the function use a legendary banners'
%                   probabilities when assigned to true. DO NOT DECLARE IT IF IT IS A
%                   NORMAL BANNER. NOTHING WILL HAPPEN.
%
%       PS.:bannerFocusColors(line 37) and pool5,4 and 3 (line 28 to 30) must me changed when
%       using a different banner/new units added to the pool respectively


%           red          blue          green      colorless
%melee,bow,shuriken,tome,dragon,staff
pool5 = [31+0+1+7+1+0 13+0+0+11+2+0 8+0+0+7+4+0  0+6+3+0+0+8];
pool4 = [25+0+0+6+1+0 21+0+0+6+2+0  13+0+0+5+1+0 0+8+9+0+0+11];
pool3 = [22+0+0+5+1+0 19+0+0+4+2+0  12+0+0+5+1+0 0+8+7+0+0+10];

%number of repetitions of the experiment
repetitions=10^4;

%not legendary banner MUST DEFINE "bannerFocusColors"(line 37) BEFORE USAGE
if ~exist('legendary','var')
    bannerFocusColors=[1 1 1 1]; %how many units of each color are focus
                                 %this has 1 red, 2 blues,0 greens and 1 colorless
    
    %initial probability list
    P5F=0.03;
    P5=0.03;
    P4=0.58;
    P3=0.36;

    pity=0.005;
    chanceStars=[P5F P5+P5F P4+P5+P5F P3+P4+P5+P5F];

    amountUnits=[bannerFocusColors;
                 pool5;
                 pool4;
                 pool3];
    chanceUnits=cumsum(amountUnits,2);
    chanceUnits=chanceUnits.*chanceUnits(:,4).^-1;

    %costs
    pullCost=[5 4 4 4 3];

    for i=1:repetitions
        pulledCopies=0;
        cost(i)=0; %total orbs in each ith repetition 
        pityCount=0; %number of pulls without 5*

        while pulledCopies<copies
            %update probabilities with current pity
            p5F=0.03+floor(pityCount/5)*pity/2;
            p5=P5+floor(pityCount/5)*pity/2;
            p4=P4-floor(pityCount/5)*0.38*pity;
            p3=P5-floor(pityCount/5)*0.62*pity;
            chanceStars=[p5F p5+p5F p4+p5+p5F p3+p4+p5+p5F];

            pretendedColor=0;
            for j=1:5 %for each summon in summoning section
                rank=rand();
                color=rand();
                %assign rank/stars
                if rank<chanceStars(1) %5*focus
                    unknownUnit(j).stars=5.5; k=1;
                end
                if rank>=chanceStars(1) && rank<chanceStars(2) %5* 
                    unknownUnit(j).stars=5; k=2;
                end
                if rank>=chanceStars(2) && rank<chanceStars(3) %4*
                    unknownUnit(j).stars=4; k=3;
                end
                if rank>=chanceStars(3) %3*
                    unknownUnit(j).stars=3; k=4;
                end 
                %assign colors
                if k~=1 %if not 5*focus
                    if color<chanceUnits(k,1) %red
                        unknownUnit(j).color='r';
                        unknownUnit(j).colorIndex=1;
                    end
                    if color>=chanceUnits(k,1) && color<chanceUnits(k,2) %blue 
                        unknownUnit(j).color='b';
                        unknownUnit(j).colorIndex=2;
                    end
                    if color>=chanceUnits(k,2) && color<chanceUnits(k,3) %green
                        unknownUnit(j).color='g';
                        unknownUnit(j).colorIndex=3;
                    end
                    if color>=chanceUnits(k,3) %colorless
                        unknownUnit(j).color='c';
                        unknownUnit(j).colorIndex=4;
                    end     
                else %if 5*focus, must check if pool omits a color
                    if color<chanceUnits(k,1) && bannerFocusColors(1)>0 %red 
                        unknownUnit(j).color='r';
                        unknownUnit(j).colorIndex=1;
                    end
                    if color>=chanceUnits(k,1) && color<chanceUnits(k,2) && bannerFocusColors(2)>0 %blue
                        unknownUnit(j).color='b';
                        unknownUnit(j).colorIndex=2;
                    end
                    if color>=chanceUnits(k,2) && color<chanceUnits(k,3) && bannerFocusColors(3)>0 %green
                        unknownUnit(j).color='g';
                        unknownUnit(j).colorIndex=3;
                    end
                    if color>=chanceUnits(k,3) && bannerFocusColors(4)>0 %colorless
                        unknownUnit(j).color='c';
                        unknownUnit(j).colorIndex=4;
                    end 
                end
                
                if unknownUnit(j).color==unitColor %if summon has same color of target unit
                    pretendedColor=pretendedColor+1; %there is one more of the target color
                    indexTarget(j)=j;
                else
                    indexTarget(j)=NaN;
                end
            end

            if pretendedColor>0 %if summoning section has at least 1 possible summon
                l=0;
                for j=1:5 %go through all possible summons
                    if isnan(indexTarget(j)) %if not of the target color, skip to next summon 
                        continue;
                    end
                    l=l+1; % increments letter "l" LOL.
                    cost(i)=cost(i)+pullCost(l); 
                    switch unknownUnit(j).stars
                        case 5.5 %5* Focus
                            prob=unitStarPool(1)*1/amountUnits(1,unknownUnit(j).colorIndex);
                            pityCount=0;
                        case 5 %5*
                            prob=unitStarPool(2)*1/amountUnits(2,unknownUnit(j).colorIndex);
                            pityCount=0;
                        case 4 %4*
                            prob=unitStarPool(3)*1/amountUnits(3,unknownUnit(j).colorIndex);
                            pityCount=pityCount+1;
                        case 3 %3*
                            prob=unitStarPool(4)*1/amountUnits(4,unknownUnit(j).colorIndex);
                            pityCount=pityCount+1;     
                    end
                    if prob>rand() %if target unit was pulled
                        pulledCopies=pulledCopies+1;
                    end
                end
            else %no target color in summoning section, something must be picked
                switch unknownUnit(1).stars 
                    case 5.5 %5* Focus
                        prob=unitStarPool(1)*1/amountUnits(1,unknownUnit(1).colorIndex);
                        pityCount=0;
                    case 5 %5* 
                        prob=unitStarPool(2)*1/amountUnits(2,unknownUnit(1).colorIndex);
                        pityCount=0;
                    case 4 %4*
                        prob=unitStarPool(3)*1/amountUnits(3,unknownUnit(1).colorIndex);
                        pityCount=pityCount+1;
                    case 3 %3*
                        prob=unitStarPool(4)*1/amountUnits(4,unknownUnit(1).colorIndex);
                        pityCount=pityCount+1;     
                end
                cost(i)=cost(i)+5;
            end
        end
    end
else
    if legendary==true %if using a legendary banner
        P5=0.08;
        P4=0.58;
        P3=0.34;

        pity=0.005;
        chanceStars=[P5 P4+P5 P3+P4+P5];

        amountUnits=[3 3 3 3;
                     pool4;
                     pool3];
        chanceUnits=cumsum(amountUnits,2);
        chanceUnits=chanceUnits.*chanceUnits(:,4).^-1;

        %costs
        pullCost=[5 4 4 4 3];


        for i=1:repetitions
            pulledCopies=0;
            cost(i)=0; %total orbs in each repetition
            pityCount=0; %number of pulls without 5*

            while pulledCopies<copies
                %update probabilities with current pity
                p5=P5+floor(pityCount/5)*pity;
                p4=P4-floor(pityCount/5)*0.38*pity;
                p3=P5-floor(pityCount/5)*0.62*pity;
                chanceStars=[p5 p4+p5 p3+p4+p5];

                pretendedColor=0;
                for j=1:5 %for each summon in summoning section
                    rank=rand();
                    color=rand();
                    %assign rank/stars
                    if rank<chanceStars(1) %5*
                        unknownUnit(j).stars=5; k=1;
                    end
                    if rank>=chanceStars(1) && rank<chanceStars(2) %4*
                        unknownUnit(j).stars=4; k=2;
                    end
                    if rank>=chanceStars(2) %3*
                        unknownUnit(j).stars=3; k=3;
                    end 
                    
                    %assign color
                    if color<chanceUnits(k,1) %red
                        unknownUnit(j).color='r';
                        unknownUnit(j).colorIndex=1;
                    end
                    if color>=chanceUnits(k,1) && color<chanceUnits(k,2)%blue 
                        unknownUnit(j).color='b';
                        unknownUnit(j).colorIndex=2;
                    end
                    if color>=chanceUnits(k,2) && color<chanceUnits(k,3) %green
                        unknownUnit(j).color='g';
                        unknownUnit(j).colorIndex=3;
                    end
                    if color>=chanceUnits(k,3) %colorless
                        unknownUnit(j).color='c';
                        unknownUnit(j).colorIndex=4;
                    end   
                    
                    if unknownUnit(j).color==unitColor %if summon has same color of target unit
                        pretendedColor=pretendedColor+1;  %there is one more of the target color
                        indexTarget(j)=j;
                    else
                        indexTarget(j)=NaN;
                    end
                end

                if pretendedColor>0  %if summoning section has at least 1 possible summon
                    l=0;
                    for j=1:5 %go through all possible summons
                        if isnan(indexTarget(j)) %if not of the target color, skip to next summon 
                            continue;
                        end
                        l=l+1; % increments letter "l" LOL.
                        cost(i)=cost(i)+pullCost(l);
                        switch unknownUnit(j).stars
                            case 5 %5*
                                prob=unitStarPool(1)*1/amountUnits(1,unknownUnit(j).colorIndex);
                                pityCount=0;
                            case 4 %4*
                                prob=unitStarPool(2)*1/amountUnits(2,unknownUnit(j).colorIndex);
                                pityCount=pityCount+1;
                            case 3 %3*
                                prob=unitStarPool(3)*1/amountUnits(3,unknownUnit(j).colorIndex);
                                pityCount=pityCount+1;     
                        end
                        if prob>rand() %if target unit was pulled
                            pulledCopies=pulledCopies+1;
                        end
                    end
                else %if summoning section does not have target color, something must be chosen
                    switch unknownUnit(1).stars
                        case 5 %5*
                            prob=unitStarPool(1)*1/amountUnits(1,unknownUnit(1).colorIndex);
                            pityCount=0;
                        case 4 %4*
                            prob=unitStarPool(2)*1/amountUnits(2,unknownUnit(1).colorIndex);
                            pityCount=pityCount+1;
                        case 3 %3*
                            prob=unitStarPool(3)*1/amountUnits(3,unknownUnit(1).colorIndex);
                            pityCount=pityCount+1;     
                    end
                    cost(i)=cost(i)+5;
                end
            end
        end 
    end
end

%print histogram
histogram(cost,'Normalization','cdf');

if copies==1
    title(sprintf('%i Copy',copies));
else
    title(sprintf('%i Copies',copies));
end
xlabel('Min orbs required')
ylabel('Probability')
