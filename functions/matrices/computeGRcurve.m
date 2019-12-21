% Function that computes the deltaGR curve from the R and G matrices.
%========================================================================

function deltaGR = computeGRcurve(collapsedR,collapsedG)

if (length(collapsedR) < 264 || length(collapsedG) < 264)
    display('Cannot compute G/R curve. Region of interest must include at least 264 timepoints.');
    return;
end;

% G/R ratio
GRratio = collapsedG ./ collapsedR ;

% delta G/R
pre = mean( GRratio(1:264) );
deltaGR = (GRratio - pre) ./ pre;

end