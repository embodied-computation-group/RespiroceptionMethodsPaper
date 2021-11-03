function responseConf = new_bin_ratings(slidingCon, Nbins)
% function responseConf = new_bin_ratings(slidingCon, Nbins)
%
% converts a vector of VAS confidence ratings to discrete ratings from
% 1:Nbins
%
% Input: 
%   slidingCon  vecor of VAS ratings *for a single subject & condition*
%   Nbins       number of bins to divide into (usually 4)
% Output:
%   responseConf    vector of dicrete confidence rartings

% Resample if quantiles are equal at high or low end to ensure proper
        % assignment of binned confidence
       % Nbins = 4;
        confBins = quantile(slidingCon,linspace(0,1,Nbins+1));
        if confBins(1) == confBins(2) & confBins(Nbins) == confBins(Nbins+1)
            error('Bad bins!')
        elseif confBins(Nbins) == confBins(Nbins+1)
            disp('Lots of high confidence ratings');
            % exclude high confidence trials and re-estimate
            hiConf = confBins(Nbins);
            temp{Nbins} = slidingCon == hiConf;
            confBins = quantile(slidingCon(~temp{Nbins}),linspace(0,1,Nbins));
            for b = 1:length(confBins)-1;
                temp{b} = slidingCon >= confBins(b) & slidingCon <= confBins(b+1);
                if b==length(confBins)-1
                    temp{b} = slidingCon >= confBins(b) & slidingCon <= confBins(b+1);
                end
            end
            out.confBins = [confBins hiConf];
            out.rebin = 1;
        elseif confBins(1) == confBins(2)
            disp('Lots of low confidence ratings');
            % exclude low confidence trials and re-estimate
            lowConf = confBins(2);
            temp{1} = slidingCon == lowConf;
            confBins = quantile(slidingCon(~temp{1}),linspace(0,1,Nbins));
            %for b = 2:length(confBins)-1;
            for b = 2:length(confBins); %JR
                temp{b} = slidingCon >= confBins(b-1) & slidingCon <= confBins(b);
                if b==length(confBins)
                    temp{b} = slidingCon >= confBins(b-1) & slidingCon <= confBins(b);
                end
            end
            out.confBins = [lowConf confBins];
            out.rebin = 1;
        else
            for b = 1:length(confBins)-1;
                temp{b} = slidingCon >= confBins(b) & slidingCon <= confBins(b+1);
                if b==length(confBins)-1
                    temp{b} = slidingCon >= confBins(b) & slidingCon <= confBins(b+1);
                end
            end
            out.confBins = confBins;
            out.rebin = 0;
        end
        
        for b = 1:Nbins
            responseConf(temp{b}) = b;
            out.binCount = sum(temp{b});
        end
        
end