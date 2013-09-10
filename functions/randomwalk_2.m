function y = randomwalk_2(x0,p,nsteps)

y    = zeros(1,nsteps);
y(1) = x0;
for istep = 2:nsteps
      y(istep) = y(istep-1) + step(p);
end

function y = step(p)

y = rand;
if ( rand < 1-p )
      y = -y; % variable step
end

% %% Generate and plot a random walk
% x = randomwalk(0,0.5,10000);
% plot(x)