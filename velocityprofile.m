% function velocityprofile

f = @(x,p) p(1) * (1-exp( -(x/p(2)).^p(3) ));
fd = @(x,p) p(1) * 1/p(2) * p(3) * (x/p(2)).^(p(3)-1) .* exp( -(x/p(2)).^p(3) );
l = @(y,yhat,s) sum((y-yhat).^2);

sacs = saccades(x,y);

for i = 1:size(sacs,1)
    b = sacs(i).bins(1)-40 : sacs(i).bins(1)+40;
    fx = x(b)-x(b(1));
    fy = y(b)-y(b(1));
    d = sqrt(fx.^2+fy.^2);
    t = (b-b(1))*p.sampRate;
    phat = fminsearch(@(p) l(d,f(t,p)), [d(end),1,2]);
    %     dist = fminsearch(@(p) l(f(t,[1 phat(2:3)]),gamcdf(t,p(1),p(2))), [1,2]);
    %     ss = gaminv([.025,.975],dist(1),dist(2));
    
    subplot(2,2,1); hold on;
    plot(fx,fy);xlabel('screen X position (\circ)');ylabel('screen Y position (\circ)');
    %     plot(fx(ss(1)<=t&t<=ss(2)),fy(ss(1)<=t&t<=ss(2)),'ko');
    %     plot(sacs(i).x-x(b(1)),sacs(i).y-y(b(1)),'rx');
    subplot(2,2,2); hold on;
    plot(t,d);xlabel('Time from Saccade Start (seconds)');ylabel('Displacement (\circ)');
    plot(t,f(t,phat))
    %     for j=1:numel(ss),plot([0,0]+ss(j),ylim,'k');end
    %     subplot(2,2,3); hold on;
    %     plot(t,gamcdf(t,dist(1),dist(2))); xlabel('Time from Saccade Start (seconds)');ylabel('Displacement (\circ)');
    %     plot(t,f(t,[1 phat(2:3)]))
    %     for j=1:numel(ss),plot([0,0]+ss(j),ylim,'k');end
    subplot(2,2,4); hold on;
    plot(t,v(b));xlabel('Time from Saccade Start (seconds)');ylabel('Velocity (\circ/second)');
    plot(t,fd(t,phat));
    %     for j=1:numel(ss),plot([0,0]+ss(j),ylim,'k');end
end