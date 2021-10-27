function simpleUDplot(stair)
% function simpleUDplot(stair)
%
% Make a simple plot for up-down staircase session
% Can take stair stucture fields for seperate staircases
%
% Project: RRS task, respiroception
%
% Niia Nikolova
% Last edit: 01/12/2020

origStairs = stair;
nStaircases = size(stair,2);

plotColours = {[0.85,0.33,0.10], [0.00,0.45,0.74], [], []};

%% Stim trace by trial
figure;
subplot(2,2,[1, 2]);

% Loop over the staircases
for thisStair = 1 : nStaircases
    
    stair = origStairs(thisStair);
    
    % Plot this staircase
    t = 1:length(stair.PM.x);%-1;               % trial #
    % plot line
    plot(t,stair.PM.x, 'Color', plotColours{thisStair}); hold on;
    % plot stims and responses
    plot(t(stair.PM.response == 1),stair.PM.x((stair.PM.response == 1)),'wo',...
        'MarkerSize',8,...
        'MarkerEdgeColor',plotColours{thisStair},...
        'MarkerFaceColor',plotColours{thisStair});%,...
%         'LineStyle', '-',...
%         'LineWidth',1,...
%         'Color', plotColours{thisStair});
    hold on
    
    plot(t(stair.PM.response == 0),stair.PM.x((stair.PM.response == 0)),'wo',...
        'MarkerSize',8,...
        'MarkerEdgeColor',plotColours{thisStair},...
        'MarkerFaceColor',[1 1 1]);%,...
%         'LineStyle', '-',...
%         'LineWidth',1,...
%         'Color', plotColours{thisStair});
end

% Add axis labels
title('Presented Stimuli by Trial');
% axis([0 (length(stair.PM.x)+5) 0 200]);
xlabel('Trial number','fontsize',10);
ylabel('Aperture obstruction (%)','fontsize',10);
set(gcf,'color','w');
hold on

%% Plot PMF

% Loop over the staircases
for thisStair = 1 : nStaircases
    
%     subplot(2,2,(thisStair+2));
   	subplot(2,2,3);

    stair = origStairs(thisStair);
    
    [SL, NP, OON] = PAL_PFML_GroupTrialsbyX(round(stair.PM.x(1:t)),stair.PM.response,ones(size(stair.PM.response)));
%     [SL, NP, OON] = PAL_PFML_GroupTrialsbyX(stair.PM.x(1:length(stair.PM.x)),stair.PM.response,ones(size(stair.PM.response)));
    for SR = 1:length(SL(OON~=0))
        % plot stim responses
        plot(SL(SR),NP(SR)/OON(SR),'wo','markerfacecolor',plotColours{thisStair},'markersize',20*sqrt(OON(SR)./sum(OON)));
        hold on
    end

    % Plot the pmf,    10.^stair.PM.beta
    plot([min(SL):.01:max(SL)], stair.PM.PF([stair.PM.xStaircase(end) 10.^(stair.beta) stair.PM.gamma stair.PM.lambda],min(SL):.01:max(SL)),'Color', plotColours{thisStair},'LineWidth',2)
    
    % Add axis names
    xlabel('Aperture obstruction (%)','fontsize',10);
    ylabel('\psi(\itx\rm; \alpha, \beta, \gamma, \lambda)','fontsize',10);
%     text(min(SL)+(max(SL)-min(SL))/4, .75, ['\beta: ', num2str(stair.PM.beta)],'color','k','Fontsize',8)
    set(gca,'yLim',[.5, 1]);
    
    drawnow
end

